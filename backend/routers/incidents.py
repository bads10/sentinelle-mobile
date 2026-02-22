"""
Incidents CVE - source : NVD (NIST) API 2.0 - gratuite, sans clé
https://nvd.nist.gov/developers/vulnerabilities
"""

import hashlib
from datetime import datetime, timezone, timedelta
from typing import Optional

import httpx
from fastapi import APIRouter, Query, HTTPException

router = APIRouter()

NVD_URL = "https://services.nvd.nist.gov/rest/json/cves/2.0"

_cache: dict = {}
CACHE_TTL = 900  # 15 min


def _cache_get(key: str):
    entry = _cache.get(key)
    if entry and (datetime.now().timestamp() - entry["ts"]) < CACHE_TTL:
        return entry["data"]
    return None


def _cache_set(key: str, data):
    _cache[key] = {"data": data, "ts": datetime.now().timestamp()}


def _cvss_to_severity(score: float) -> str:
    if score >= 9.0:
        return "critical"
    if score >= 7.0:
        return "high"
    if score >= 4.0:
        return "medium"
    if score > 0:
        return "low"
    return "info"


def _extract_cvss(metrics: dict) -> float:
    """Extrait le score CVSS (v3.1 > v3.0 > v2)."""
    for key in ("cvssMetricV31", "cvssMetricV30"):
        lst = metrics.get(key, [])
        if lst:
            return float(lst[0].get("cvssData", {}).get("baseScore", 0))
    lst = metrics.get("cvssMetricV2", [])
    if lst:
        return float(lst[0].get("cvssData", {}).get("baseScore", 0))
    return 0.0


def _format_nvd(item: dict) -> dict | None:
    """Convertit une entrée NVD au format attendu par l'app."""
    cve = item.get("cve", {})
    cve_id = cve.get("id", "")
    if not cve_id:
        return None

    # Résumé en anglais
    descriptions = cve.get("descriptions", [])
    summary = next(
        (d["value"] for d in descriptions if d.get("lang") == "en"),
        ""
    )
    if not summary or summary == "** RESERVED **" or len(summary) < 20:
        return None

    metrics = cve.get("metrics", {})
    cvss = _extract_cvss(metrics)

    published = cve.get("published", datetime.now(timezone.utc).isoformat())
    updated = cve.get("lastModified", published)

    # Références
    refs = [r.get("url", "") for r in cve.get("references", []) if r.get("url")][:10]

    # Produits affectés
    products = []
    for cfg in cve.get("configurations", []):
        for node in cfg.get("nodes", []):
            for cpe in node.get("cpeMatch", []):
                uri = cpe.get("criteria", "")
                parts = uri.split(":")
                if len(parts) > 4:
                    prod = f"{parts[3]} {parts[4]}".replace("_", " ").title()
                    if prod not in products:
                        products.append(prod)
    products = products[:10]

    # Patch URL (cherche dans les refs)
    patch_url = next(
        (r for r in refs if any(k in r for k in ["patch", "fix", "advisory", "github.com/advisories"])),
        None
    )

    return {
        "id": hashlib.md5(cve_id.encode()).hexdigest(),
        "cve_id": cve_id,
        "summary": summary[:500],
        "severity": _cvss_to_severity(cvss),
        "cvss_score": cvss,
        "published_at": published,
        "updated_at": updated,
        "affected_products": products,
        "references": refs,
        "vendor": None,
        "patch_url": patch_url,
    }


@router.get("/")
async def get_incidents(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    severity: Optional[str] = None,
    min_cvss: Optional[float] = None,
):
    cache_key = "incidents_recent"
    all_incidents = _cache_get(cache_key)

    if all_incidents is None:
        try:
            # Fenêtre de 30 jours
            now = datetime.now(timezone.utc)
            pub_start = (now - timedelta(days=30)).strftime("%Y-%m-%dT%H:%M:%S.000")
            pub_end = now.strftime("%Y-%m-%dT%H:%M:%S.000")
            async with httpx.AsyncClient(timeout=30) as client:
                resp = await client.get(
                    NVD_URL,
                    params={
                        "resultsPerPage": 100,
                        "startIndex": 0,
                        "pubStartDate": pub_start,
                        "pubEndDate": pub_end,
                    },
                    headers={"User-Agent": "Sentinelle-App/1.0"},
                    follow_redirects=True,
                )
                resp.raise_for_status()
                data = resp.json()
        except Exception as e:
            raise HTTPException(status_code=503, detail=f"NVD API indisponible: {e}")

        all_incidents = []
        for item in data.get("vulnerabilities", []):
            formatted = _format_nvd(item)
            if formatted:
                all_incidents.append(formatted)

        # Tri par score CVSS décroissant
        all_incidents.sort(key=lambda x: x["cvss_score"], reverse=True)
        _cache_set(cache_key, all_incidents)

    # Filtres
    filtered = all_incidents
    if severity:
        filtered = [i for i in filtered if i["severity"] == severity.lower()]
    if min_cvss is not None:
        filtered = [i for i in filtered if i["cvss_score"] >= min_cvss]

    # Pagination
    total = len(filtered)
    start = (page - 1) * page_size
    end = start + page_size

    return {
        "items": filtered[start:end],
        "total": total,
        "page": page,
        "page_size": page_size,
        "has_more": end < total,
    }


@router.get("/{incident_id}")
async def get_incident(incident_id: str):
    cache_key = "incidents_recent"
    all_incidents = _cache_get(cache_key)

    if all_incidents:
        for inc in all_incidents:
            if inc["id"] == incident_id:
                return inc

    raise HTTPException(status_code=404, detail="Incident non trouvé")

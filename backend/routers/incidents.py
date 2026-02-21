"""
Incidents CVE - source : CIRCL CVE Search API (gratuite, sans clé)
"""

import hashlib
from datetime import datetime
from typing import Optional

import httpx
from fastapi import APIRouter, Query, HTTPException

router = APIRouter()

CIRCL_BASE = "https://cve.circl.lu/api"

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


def _format_cve(entry: dict) -> dict | None:
    """Convertit une entrée CIRCL au format attendu par l'app."""
    cve_id = entry.get("id", "")
    if not cve_id:
        return None

    summary = entry.get("summary", "") or ""
    cvss = float(entry.get("cvss", 0) or entry.get("cvss3", 0) or 0)

    published = entry.get("Published", "") or entry.get("published", "") or datetime.now().isoformat()
    updated = entry.get("Modified", "") or entry.get("modified", "") or published

    references = entry.get("references", []) or []
    if isinstance(references, str):
        references = [references]

    # Produits affectés
    products = []
    for conf in (entry.get("vulnerable_configuration", []) or []):
        if isinstance(conf, dict):
            title = conf.get("title", "")
        else:
            title = str(conf)
        if title and title not in products:
            products.append(title)
    products = products[:10]

    return {
        "id": hashlib.md5(cve_id.encode()).hexdigest(),
        "cve_id": cve_id,
        "summary": summary[:500] if summary else "Aucun résumé disponible",
        "severity": _cvss_to_severity(cvss),
        "cvss_score": cvss,
        "published_at": published,
        "updated_at": updated,
        "affected_products": products,
        "references": [r for r in references if isinstance(r, str)][:10],
        "vendor": entry.get("vendor", None),
        "patch_url": None,
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
        # Récupère les 100 derniers CVE depuis CIRCL
        try:
            async with httpx.AsyncClient() as client:
                resp = await client.get(
                    f"{CIRCL_BASE}/last/100",
                    timeout=20,
                    follow_redirects=True,
                )
                resp.raise_for_status()
                data = resp.json()
        except Exception as e:
            raise HTTPException(status_code=503, detail=f"CIRCL API indisponible: {e}")

        all_incidents = []
        for entry in data:
            formatted = _format_cve(entry)
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

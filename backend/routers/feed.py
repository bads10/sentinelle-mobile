"""
Flux RSS - agrégation de sources cybersécurité
"""

import hashlib
import asyncio
from typing import Optional
from datetime import datetime

import feedparser
import httpx
from fastapi import APIRouter, Query

router = APIRouter()

# Sources RSS cybersécurité
RSS_SOURCES = [
    # Actualités générales
    {"name": "Krebs on Security",    "url": "https://krebsonsecurity.com/feed/"},
    {"name": "The Hacker News",      "url": "https://feeds.feedburner.com/TheHackersNews"},
    {"name": "BleepingComputer",     "url": "https://www.bleepingcomputer.com/feed/"},
    {"name": "Schneier on Security", "url": "https://www.schneier.com/feed/atom/"},
    {"name": "Dark Reading",         "url": "https://www.darkreading.com/rss.xml"},
    {"name": "SecurityWeek",         "url": "https://feeds.feedburner.com/securityweek"},
    {"name": "Threatpost",           "url": "https://threatpost.com/feed/"},
    {"name": "Naked Security",       "url": "https://nakedsecurity.sophos.com/feed/"},
    {"name": "Graham Cluley",        "url": "https://grahamcluley.com/feed/"},
    {"name": "Cyber Defense Mag",    "url": "https://www.cyberdefensemagazine.com/feed/"},
    # Threat intelligence
    {"name": "SANS Internet Storm",  "url": "https://isc.sans.edu/rssfeed_full.xml"},
    {"name": "Recorded Future",      "url": "https://www.recordedfuture.com/feed"},
    {"name": "Mandiant",             "url": "https://www.mandiant.com/resources/blog/rss.xml"},
    {"name": "Malwarebytes Labs",    "url": "https://www.malwarebytes.com/blog/feed/"},
    {"name": "Cisco Talos",          "url": "https://blog.talosintelligence.com/feeds/posts/default"},
    # CERT / gouvernementaux
    {"name": "CERT-FR",              "url": "https://www.cert.ssi.gouv.fr/feed/"},
    {"name": "US-CERT CISA",        "url": "https://www.cisa.gov/cybersecurity-advisories/all.xml"},
    {"name": "ENISA",                "url": "https://www.enisa.europa.eu/news/rss"},
    # Vulnérabilités
    {"name": "Rapid7",               "url": "https://blog.rapid7.com/rss/"},
    {"name": "Qualys Blog",          "url": "https://blog.qualys.com/feed"},
]

# Cache simple en mémoire (TTL 10 min)
_cache: dict = {}
CACHE_TTL = 600  # secondes


def _cache_get(key: str):
    entry = _cache.get(key)
    if entry and (datetime.now().timestamp() - entry["ts"]) < CACHE_TTL:
        return entry["data"]
    return None


def _cache_set(key: str, data):
    _cache[key] = {"data": data, "ts": datetime.now().timestamp()}


def _parse_date(entry) -> str:
    """Extrait et normalise la date d'une entrée RSS."""
    for attr in ("published", "updated", "created"):
        val = getattr(entry, attr, None)
        if val:
            return val
    return datetime.now().isoformat()


def _make_id(source: str, link: str) -> str:
    return hashlib.md5(f"{source}:{link}".encode()).hexdigest()


def _extract_tags(entry) -> list[str]:
    tags = []
    if hasattr(entry, "tags"):
        for t in entry.tags:
            label = getattr(t, "term", None) or getattr(t, "label", "")
            if label:
                tags.append(label.strip())
    return tags[:8]


async def _fetch_feed(source: dict, client: httpx.AsyncClient) -> list[dict]:
    """Télécharge et parse un flux RSS."""
    try:
        resp = await client.get(source["url"], timeout=10, follow_redirects=True)
        parsed = feedparser.parse(resp.text)
        items = []
        for entry in parsed.entries[:15]:
            link = getattr(entry, "link", "")
            desc = getattr(entry, "summary", "") or getattr(entry, "description", "")
            # Nettoyer le HTML basique dans la description
            import re
            desc = re.sub(r"<[^>]+>", "", desc)[:300]

            items.append({
                "id": _make_id(source["name"], link),
                "title": getattr(entry, "title", "Sans titre"),
                "link": link,
                "published_at": _parse_date(entry),
                "description": desc.strip() or None,
                "content": None,
                "author": getattr(entry, "author", None),
                "source_name": source["name"],
                "source_url": source["url"],
                "image_url": None,
                "tags": _extract_tags(entry),
                "categories": [],
                "is_read": False,
                "is_bookmarked": False,
            })
        return items
    except Exception as e:
        print(f"[feed] Erreur {source['name']}: {e}")
        return []


@router.get("/")
async def get_feed(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    source: Optional[str] = None,
):
    cache_key = "feed_all"
    all_items = _cache_get(cache_key)

    if all_items is None:
        async with httpx.AsyncClient() as client:
            results = await asyncio.gather(
                *[_fetch_feed(s, client) for s in RSS_SOURCES]
            )
        all_items = []
        for batch in results:
            all_items.extend(batch)

        # Tri par date décroissante (best-effort sur la string)
        all_items.sort(key=lambda x: x["published_at"], reverse=True)
        _cache_set(cache_key, all_items)

    # Filtre par source
    if source:
        filtered = [i for i in all_items if i["source_name"].lower() == source.lower()]
    else:
        filtered = all_items

    # Pagination
    total = len(filtered)
    start = (page - 1) * page_size
    end = start + page_size
    page_items = filtered[start:end]

    return {
        "items": page_items,
        "total": total,
        "page": page,
        "page_size": page_size,
        "has_more": end < total,
    }

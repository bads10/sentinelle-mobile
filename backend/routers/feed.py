"""
Flux RSS - agrégation de sources cybersécurité
"""

import hashlib
import asyncio
import re
from typing import Optional
from datetime import datetime

import feedparser
import httpx
from fastapi import APIRouter, Query
from routers.translate import translate_items

router = APIRouter()

# Sources RSS — toutes 100% spécialisées cybersécurité
RSS_SOURCES = [
    # ── Sources francophones (priorité) ──────────────────────────────────────
    {"name": "CERT-FR",              "url": "https://www.cert.ssi.gouv.fr/feed/",                                          "lang": "fr", "cyber_only": True},
    {"name": "ANSSI",                "url": "https://www.ssi.gouv.fr/feed/",                                               "lang": "fr", "cyber_only": True},
    {"name": "Global Security Mag",  "url": "https://www.globalsecuritymag.fr/rss.xml",                                    "lang": "fr", "cyber_only": True},
    {"name": "Le Monde Informatique","url": "https://www.lemondeinformatique.fr/flux-rss/thematique/securite/rss.xml",     "lang": "fr", "cyber_only": True},
    {"name": "Zataz",                "url": "https://www.zataz.com/feed/",                                                 "lang": "fr", "cyber_only": True},
    {"name": "IT-Connect",           "url": "https://www.it-connect.fr/feed/",                                             "lang": "fr", "cyber_only": False},
    {"name": "LeMagIT Sécurité",     "url": "https://www.lemagit.fr/rss/Securite",                                        "lang": "fr", "cyber_only": True},
    {"name": "ZDNet France",         "url": "https://www.zdnet.fr/feeds/rss/actualites/",                                  "lang": "fr", "cyber_only": False},
    # ── Sources anglophones ──────────────────────────────────────────────────
    {"name": "Krebs on Security",    "url": "https://krebsonsecurity.com/feed/",                                           "lang": "en", "cyber_only": True},
    {"name": "The Hacker News",      "url": "https://feeds.feedburner.com/TheHackersNews",                                 "lang": "en", "cyber_only": True},
    {"name": "BleepingComputer",     "url": "https://www.bleepingcomputer.com/feed/",                                      "lang": "en", "cyber_only": True},
    {"name": "Schneier on Security", "url": "https://www.schneier.com/feed/atom/",                                         "lang": "en", "cyber_only": True},
    {"name": "Dark Reading",         "url": "https://www.darkreading.com/rss.xml",                                         "lang": "en", "cyber_only": True},
    {"name": "SecurityWeek",         "url": "https://feeds.feedburner.com/securityweek",                                   "lang": "en", "cyber_only": True},
    {"name": "Naked Security",       "url": "https://nakedsecurity.sophos.com/feed/",                                      "lang": "en", "cyber_only": True},
    {"name": "Graham Cluley",        "url": "https://grahamcluley.com/feed/",                                              "lang": "en", "cyber_only": True},
    {"name": "SANS Internet Storm",  "url": "https://isc.sans.edu/rssfeed_full.xml",                                       "lang": "en", "cyber_only": True},
    {"name": "Mandiant",             "url": "https://www.mandiant.com/resources/blog/rss.xml",                             "lang": "en", "cyber_only": True},
    {"name": "Malwarebytes Labs",    "url": "https://www.malwarebytes.com/blog/feed/",                                     "lang": "en", "cyber_only": True},
    {"name": "Cisco Talos",          "url": "https://blog.talosintelligence.com/feeds/posts/default",                      "lang": "en", "cyber_only": True},
    {"name": "US-CERT CISA",         "url": "https://www.cisa.gov/cybersecurity-advisories/all.xml",                       "lang": "en", "cyber_only": True},
    {"name": "Rapid7",               "url": "https://blog.rapid7.com/rss/",                                               "lang": "en", "cyber_only": True},
]

# Mots-clés cyber — filtre pour les sources non-exclusivement cyber
CYBER_KEYWORDS = [
    # FR
    "sécurité", "cyberattaque", "ransomware", "piratage", "vulnérabilité",
    "malware", "phishing", "hacker", "fuite", "brèche", "RGPD", "cybermenace",
    "rançongiciel", "chiffrement", "authentification", "pare-feu", "intrusion",
    "CVE", "zero-day", "CISA", "CERT", "incident", "attaque", "cybersécurité",
    "données personnelles", "darkweb", "darknet", "botnet",
    # EN
    "security", "cyber", "breach", "hack", "exploit", "vulnerability",
    "malware", "ransomware", "phishing", "threat", "attack", "infosec",
    "password", "encryption", "firewall", "zero-day", "patch", "authentication",
    "data leak", "spyware", "trojan", "backdoor", "APT",
]

_CYBER_RE = re.compile(
    "|".join(re.escape(k) for k in CYBER_KEYWORDS),
    re.IGNORECASE,
)


def _is_cyber_relevant(title: str, description: str) -> bool:
    """Retourne True si l'article est lié à la cybersécurité."""
    text = f"{title} {description}"
    return bool(_CYBER_RE.search(text))

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


async def _fetch_og_image(url: str, client: httpx.AsyncClient) -> str | None:
    """Récupère l'og:image d'une page web."""
    try:
        resp = await client.get(url, timeout=5, follow_redirects=True,
                                headers={"User-Agent": "Mozilla/5.0"})
        # Cherche og:image" content="URL" ou og:image' content='URL'
        idx = resp.text.find("og:image")
        if idx == -1:
            return None
        chunk = resp.text[idx:idx+300]
        match = re.search(r'content=["\']([^"\']+)["\']', chunk)
        if match:
            img = match.group(1).strip()
            if img.startswith("http"):
                return img
    except Exception:
        pass
    return None


def _extract_image(entry, desc_raw: str) -> str | None:
    """Extrait l'image depuis media:content, enclosure, ou le HTML de la description."""
    # 1. media:content (standard RSS media)
    media = getattr(entry, "media_content", None)
    if media and isinstance(media, list) and media[0].get("url"):
        url = media[0]["url"]
        if any(url.lower().endswith(ext) for ext in (".jpg", ".jpeg", ".png", ".webp", ".gif")):
            return url

    # 2. media:thumbnail
    thumb = getattr(entry, "media_thumbnail", None)
    if thumb and isinstance(thumb, list) and thumb[0].get("url"):
        return thumb[0]["url"]

    # 3. enclosure (podcast/image attachments)
    enclosures = getattr(entry, "enclosures", None)
    if enclosures:
        for enc in enclosures:
            t = enc.get("type", "")
            if "image" in t:
                return enc.get("href") or enc.get("url")

    # 4. <img src="..."> dans le HTML de la description
    match = re.search(r'<img[^>]+src=["\']([^"\']+)["\']', desc_raw, re.IGNORECASE)  # noqa
    if match:
        url = match.group(1)
        if url.startswith("http"):
            return url

    return None


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
        lang = source.get("lang", "en")
        cyber_only = source.get("cyber_only", True)
        items = []
        for entry in parsed.entries[:15]:
            link = getattr(entry, "link", "")
            desc_raw = getattr(entry, "summary", "") or getattr(entry, "description", "")
            desc = re.sub(r"<[^>]+>", "", desc_raw)[:300]
            title = getattr(entry, "title", "Sans titre")

            # Pour les sources non-exclusivement cyber, filtrer par mots-clés
            if not cyber_only and not _is_cyber_relevant(title, desc):
                continue

            image_url = _extract_image(entry, desc_raw)

            items.append({
                "id": _make_id(source["name"], link),
                "title": title,
                "link": link,
                "published_at": _parse_date(entry),
                "description": desc.strip() or None,
                "content": None,
                "author": getattr(entry, "author", None),
                "source_name": source["name"],
                "source_url": source["url"],
                "image_url": image_url,
                "language": lang,
                "tags": _extract_tags(entry),
                "categories": [],
                "is_read": False,
                "is_bookmarked": False,
            })
        return items
    except Exception as e:
        print(f"[feed] Erreur {source['name']}: {e}")
        return []


@router.post("/refresh")
async def refresh_feed():
    """Vide le cache et force un rechargement."""
    _cache.clear()
    return {"status": "cache cleared"}


@router.get("/")
async def get_feed(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    source: Optional[str] = None,
    translate: bool = Query(False, description="Traduire les articles EN→FR"),
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

        # Tri : FR en premier, puis par date décroissante
        fr_items = sorted([i for i in all_items if i.get("language") == "fr"], key=lambda x: x["published_at"], reverse=True)
        en_items = sorted([i for i in all_items if i.get("language") != "fr"], key=lambda x: x["published_at"], reverse=True)
        all_items = fr_items + en_items

        # Mise en cache immédiate (sans og:images) pour éviter les requêtes concurrentes
        _cache_set(cache_key, all_items)

        # Récupérer og:image en arrière-plan pour les articles sans image (max 30)
        no_img = [i for i in all_items if not i.get("image_url")][:30]
        print(f"[feed] {len(no_img)} articles sans image, fetch og:image...")
        if no_img:
            async with httpx.AsyncClient() as og_client:
                og_images = await asyncio.gather(
                    *[_fetch_og_image(i["link"], og_client) for i in no_img],
                    return_exceptions=True,
                )
            found = 0
            for item, img in zip(no_img, og_images):
                if isinstance(img, str):
                    item["image_url"] = img
                    found += 1
            print(f"[feed] og:image trouvées : {found}/{len(no_img)}")
            # Mettre à jour le cache avec les og:images trouvées
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

    # Traduction EN→FR à la demande (sur la page courante seulement)
    if translate:
        async with httpx.AsyncClient() as tr_client:
            page_items = await translate_items(list(page_items), tr_client)

    return {
        "items": page_items,
        "total": total,
        "page": page,
        "page_size": page_size,
        "has_more": end < total,
    }

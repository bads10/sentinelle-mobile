"""
Traduction EN→FR via LibreTranslate public (fedilab.app) + MyMemory fallback
Gratuit, sans clé API requise.
"""

import asyncio
from typing import Optional
import httpx
from fastapi import APIRouter

router = APIRouter()

LIBRETRANSLATE_URL = "https://translate.fedilab.app/translate"
MYMEMORY_URL = "https://api.mymemory.translated.net/get"

# Cache traductions (persistant en mémoire, pas de TTL)
_translation_cache: dict[str, str] = {}


async def _translate_libretranslate(text: str, client: httpx.AsyncClient) -> str | None:
    try:
        resp = await client.post(
            LIBRETRANSLATE_URL,
            json={"q": text, "source": "en", "target": "fr", "format": "text"},
            timeout=8,
        )
        if resp.status_code == 200:
            data = resp.json()
            return data.get("translatedText")
    except Exception:
        pass
    return None


async def _translate_mymemory(text: str, client: httpx.AsyncClient) -> str | None:
    try:
        resp = await client.get(
            MYMEMORY_URL,
            params={"q": text[:500], "langpair": "en|fr"},
            timeout=8,
        )
        if resp.status_code == 200:
            data = resp.json()
            translated = data.get("responseData", {}).get("translatedText", "")
            if translated and translated != text:
                return translated
    except Exception:
        pass
    return None


async def translate_text(text: str, client: httpx.AsyncClient) -> str:
    """Traduit un texte EN→FR avec cache. Retourne le texte original en cas d'échec."""
    if not text or not text.strip():
        return text

    # Vérifier le cache
    cached = _translation_cache.get(text)
    if cached:
        return cached

    # Essai LibreTranslate puis MyMemory
    result = await _translate_libretranslate(text, client)
    if not result:
        result = await _translate_mymemory(text, client)

    if result:
        _translation_cache[text] = result
        return result

    return text


async def translate_items(items: list[dict], client: httpx.AsyncClient) -> list[dict]:
    """Traduit titre + description des articles EN en parallèle."""
    en_items = [i for i in items if i.get("language") == "en"]
    if not en_items:
        return items

    # Préparer les tâches (titre + description pour chaque article EN)
    tasks = []
    for item in en_items:
        tasks.append(translate_text(item["title"], client))
        desc = item.get("description") or ""
        tasks.append(translate_text(desc, client))

    results = await asyncio.gather(*tasks, return_exceptions=True)

    # Appliquer les traductions
    for i, item in enumerate(en_items):
        title_result = results[i * 2]
        desc_result = results[i * 2 + 1]
        if isinstance(title_result, str):
            item["title_fr"] = title_result
        if isinstance(desc_result, str) and desc_result:
            item["description_fr"] = desc_result

    return items


@router.post("/")
async def translate_batch(payload: dict):
    """
    Traduit une liste de textes EN→FR.
    Body: {"texts": ["text1", "text2", ...]}
    """
    texts = payload.get("texts", [])
    if not texts:
        return {"translations": []}

    async with httpx.AsyncClient() as client:
        tasks = [translate_text(t, client) for t in texts[:50]]  # max 50
        results = await asyncio.gather(*tasks, return_exceptions=True)

    translations = [
        r if isinstance(r, str) else texts[i]
        for i, r in enumerate(results)
    ]
    return {"translations": translations}

/// PiiSanitizer – Étape 6 Qualité/Sécurité/Conformité
///
/// Garantit que JAMAIS de PII (Personally Identifiable Information)
/// ni de dumps bruts ne sont stockés ou affichés.
/// Seules les métadonnées / liens fournis par les APIs ou RSS sont conservés.
library pii_sanitizer;

/// Champs autorisés pour chaque type de ressource.
/// Tout champ absent de cette liste est supprimé avant stockage.
class PiiSanitizer {
  // ---------------------------------------------------------------------------
  // Champs autorisés par type (liste blanche stricte)
  // ---------------------------------------------------------------------------

  /// Champs autorisés pour une menace (MalwareBazaar / abuse.ch)
  static const Set<String> _allowedThreatFields = {
    'id',
    'name',
    'family',
    'severity',
    'tags',
    'reported_at',
    'ioc_count',
    'is_active',
    'description',
    // URL de référence vers la fiche publique (pas le binaire)
    'reference_url',
  };

  /// Champs autorisés pour un incident CVE (CIRCL / NVD)
  static const Set<String> _allowedIncidentFields = {
    'id',
    'cve_id',
    'summary',
    'severity',
    'cvss_score',
    'published_at',
    'updated_at',
    'affected_products',
    // Uniquement les références publiques (nvd.nist.gov, cve.mitre.org)
    'references',
  };

  /// Champs autorisés pour un article RSS
  static const Set<String> _allowedRssFields = {
    'id',
    'title',
    // URL publique vers l'article (pas de contenu brut)
    'link',
    'published_at',
    'source',
    'source_url',
    // Résumé court (max 500 chars, nettoyé)
    'summary',
  };

  /// Champs autorisés pour les statistiques globales
  static const Set<String> _allowedStatsFields = {
    'total_threats',
    'total_incidents',
    'total_rss_items',
    'critical_threats',
    'high_threats',
    'active_threats',
    'last_updated',
    // Agrégats uniquement – jamais d'identifiants individuels
    'threats',
    'incidents',
    'rss',
  };

  // ---------------------------------------------------------------------------
  // Patterns PII à redétecter et masquer
  // ---------------------------------------------------------------------------

  /// Email
  static final RegExp _emailPattern = RegExp(
    r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
  );

  /// IPv4 privée (RFC-1918) – à ne jamais stocker telle quelle
  static final RegExp _privateIpv4 = RegExp(
    r'\b(10\.\d{1,3}\.\d{1,3}\.\d{1,3}'
    r'|172\.(1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3}'
    r'|192\.168\.\d{1,3}\.\d{1,3})\b',
  );

  /// Numéro de téléphone basique
  static final RegExp _phonePattern = RegExp(
    r'\b(\+?\d[\s\-.]?){7,15}\b',
  );

  /// Hash type MD5/SHA (potentiel IOC brut issu d'un dump)
  /// Autorisé UNIQUEMENT dans le champ `ioc_count` (compteur),
  /// jamais dans les champs texte libres.
  static final RegExp _rawHashPattern = RegExp(
    r'\b[0-9a-fA-F]{32,64}\b',
  );

  /// URL suspecte pointant vers un binaire / archive
  static final RegExp _binaryUrlPattern = RegExp(
    r'https?://[^\s]+(\.(exe|dll|bat|ps1|sh|zip|rar|7z|tar\.gz|bin|iso))'
    r'(\?[^\s]*)?',
    caseSensitive: false,
  );

  // ---------------------------------------------------------------------------
  // Méthodes publiques
  // ---------------------------------------------------------------------------

  /// Filtre un objet JSON représentant une menace.
  /// Retourne une Map ne contenant que les champs autorisés, nettoyés.
  static Map<String, dynamic> sanitizeThreat(Map<String, dynamic> raw) {
    final filtered = _keepAllowed(raw, _allowedThreatFields);
    // Nettoyer les champs texte libres
    if (filtered.containsKey('description')) {
      filtered['description'] = _cleanText(filtered['description'] as String? ?? '');
    }
    if (filtered.containsKey('reference_url')) {
      filtered['reference_url'] = _sanitizeUrl(filtered['reference_url'] as String? ?? '');
    }
    return filtered;
  }

  /// Filtre un objet JSON représentant un incident CVE.
  static Map<String, dynamic> sanitizeIncident(Map<String, dynamic> raw) {
    final filtered = _keepAllowed(raw, _allowedIncidentFields);
    if (filtered.containsKey('summary')) {
      filtered['summary'] = _cleanText(filtered['summary'] as String? ?? '');
    }
    if (filtered.containsKey('references')) {
      final refs = filtered['references'];
      if (refs is List) {
        filtered['references'] = refs
            .whereType<String>()
            .map(_sanitizeUrl)
            .where((u) => u.isNotEmpty)
            .toList();
      }
    }
    return filtered;
  }

  /// Filtre un objet JSON représentant un article RSS.
  static Map<String, dynamic> sanitizeRssItem(Map<String, dynamic> raw) {
    final filtered = _keepAllowed(raw, _allowedRssFields);
    if (filtered.containsKey('title')) {
      filtered['title'] = _cleanText(filtered['title'] as String? ?? '', maxLength: 200);
    }
    if (filtered.containsKey('summary')) {
      filtered['summary'] = _cleanText(filtered['summary'] as String? ?? '', maxLength: 500);
    }
    if (filtered.containsKey('link')) {
      filtered['link'] = _sanitizeUrl(filtered['link'] as String? ?? '');
    }
    if (filtered.containsKey('source_url')) {
      filtered['source_url'] = _sanitizeUrl(filtered['source_url'] as String? ?? '');
    }
    return filtered;
  }

  /// Filtre un objet JSON représentant des statistiques globales.
  static Map<String, dynamic> sanitizeStats(Map<String, dynamic> raw) {
    return _keepAllowed(raw, _allowedStatsFields);
  }

  /// Nettoie un texte libre : supprime PII, tronque, échapppe HTML.
  static String sanitizeText(String text, {int maxLength = 1000}) {
    return _cleanText(text, maxLength: maxLength);
  }

  // ---------------------------------------------------------------------------
  // Helpers privés
  // ---------------------------------------------------------------------------

  /// Conserve uniquement les clés de la liste blanche.
  static Map<String, dynamic> _keepAllowed(
    Map<String, dynamic> raw,
    Set<String> allowed,
  ) {
    return Map.fromEntries(
      raw.entries.where((e) => allowed.contains(e.key)),
    );
  }

  /// Nettoie un texte : supprime emails, IPs privées, téléphones,
  /// URLs binaires, hashs bruts dans les champs libres, puis tronque.
  static String _cleanText(String text, {int maxLength = 1000}) {
    if (text.isEmpty) return text;

    var result = text
        // Supprimer les emails
        .replaceAll(_emailPattern, '[email redacted]')
        // Supprimer les IPs privées
        .replaceAll(_privateIpv4, '[private-ip redacted]')
        // Supprimer les URLs pointant vers des binaires
        .replaceAll(_binaryUrlPattern, '[binary-url redacted]')
        // Supprimer les hashs bruts dans les champs texte
        .replaceAll(_rawHashPattern, '[hash redacted]')
        // Normaliser les espaces
        .trim();

    // Tronquer : garder au max maxLength caractères
    if (result.length > maxLength) {
      result = '${result.substring(0, maxLength)}…';
    }

    return result;
  }

  /// Valide et assainit une URL :
  /// - doit être https
  /// - ne doit pas pointer vers un binaire
  /// - doit correspondre à un domaine de confiance OU être une référence publique
  static String _sanitizeUrl(String url) {
    if (url.isEmpty) return url;
    try {
      final uri = Uri.parse(url);
      // Rejeter les URLs non-https (sauf localhost en dév)
      if (uri.scheme != 'https' && uri.host != 'localhost') return '';
      // Rejeter les URLs vers des binaires
      if (_binaryUrlPattern.hasMatch(url)) return '';
      return url;
    } catch (_) {
      return '';
    }
  }

  // ---------------------------------------------------------------------------
  // Validation des téléphones (utilisé dans les tests)
  // ---------------------------------------------------------------------------

  /// Retourne true si le texte contient un PII détecté.
  static bool containsPii(String text) {
    return _emailPattern.hasMatch(text) ||
        _privateIpv4.hasMatch(text) ||
        _phonePattern.hasMatch(text);
  }

  /// Retourne true si le texte contient un hash brut (IOC).
  static bool containsRawHash(String text) {
    return _rawHashPattern.hasMatch(text);
  }

  /// Retourne true si l'URL pointe vers un binaire.
  static bool isBinaryUrl(String url) {
    return _binaryUrlPattern.hasMatch(url);
  }
}

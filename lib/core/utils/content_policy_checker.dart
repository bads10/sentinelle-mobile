/// Résultat d'une vérification de conformité du contenu.
class ContentPolicyResult {
  final bool isCompliant;
  final List<String> violations;

  const ContentPolicyResult({
    required this.isCompliant,
    required this.violations,
  });

  factory ContentPolicyResult.ok() =>
      const ContentPolicyResult(isCompliant: true, violations: []);

  factory ContentPolicyResult.blocked(List<String> violations) =>
      ContentPolicyResult(isCompliant: false, violations: violations);

  @override
  String toString() =>
      isCompliant ? 'OK' : 'BLOCKED: ${violations.join(", ")}';
}

/// Vérificateur de conformité pour le contenu affiché dans l'app.
///
/// Garantit que l'app reste "store-friendly" :
///   - Pas de liens directs vers du contenu illégal ou malveillant
///   - Pas de contenu adulte ou choquant
///   - Pas de hash bruts / données sensibles exposés
///   - Respect des règles Apple App Store / Google Play
class ContentPolicyChecker {
  ContentPolicyChecker._();
  static final ContentPolicyChecker instance = ContentPolicyChecker._();

  // ---------------------------------------------------------------------------
  // Patterns de violation
  // ---------------------------------------------------------------------------

  /// Schémas d'URL pointant vers du contenu illégal ou malveillant connu.
  static final RegExp _illegalSchemePattern = RegExp(
    r'^(ftp|telnet|gopher|data):',
    caseSensitive: false,
  );

  /// Extensions de binaires exécutables ou archives potentiellement malveillantes.
  static final RegExp _binaryExtPattern = RegExp(
    r'\.(exe|bat|cmd|sh|ps1|msi|deb|rpm|dmg|apk|ipa|bin|dll|so|dylib|zip|rar|7z|tar\.gz)$',
    caseSensitive: false,
  );

  /// Domaines / mots-clés explicitement blacklistés (téléchargement de malware, etc.).
  static final RegExp _blacklistPattern = RegExp(
    r'(malware-traffic-analysis\.net|vxvault\.net|virusshare\.com|bazaar\.abuse\.ch/download)',
    caseSensitive: false,
  );

  /// Détecte les liens "magnet:" (torrents).
  static final RegExp _magnetPattern = RegExp(
    r'^magnet:',
    caseSensitive: false,
  );

  /// Hash bruts (MD5 / SHA-1 / SHA-256 / SHA-512) dans un texte.
  static final RegExp _rawHashInTextPattern = RegExp(
    r'\b([0-9a-fA-F]{32}|[0-9a-fA-F]{40}|[0-9a-fA-F]{64}|[0-9a-fA-F]{128})\b',
  );

  /// Mots-clés liés à du contenu adulte explicite.
  static final RegExp _adultKeywordPattern = RegExp(
    r'\b(porn|xxx|adult.?content|nude|explicit.?sexual)\b',
    caseSensitive: false,
  );

  /// Contenu promouvant la haine ou l'extrémisme.
  static final RegExp _hateSpeechPattern = RegExp(
    r'\b(jihad.?attack|kill.?all|genocide.?now|terror.?recruit)\b',
    caseSensitive: false,
  );

  // ---------------------------------------------------------------------------
  // API publique
  // ---------------------------------------------------------------------------

  /// Vérifie l'URL d'un article / lien avant affichage.
  ContentPolicyResult checkUrl(String url) {
    final violations = <String>[];
    final lower = url.toLowerCase();

    if (_illegalSchemePattern.hasMatch(url)) {
      violations.add('schéma interdit: ${url.split(":").first}');
    }
    if (_binaryExtPattern.hasMatch(lower)) {
      violations.add('lien vers un binaire exécutable');
    }
    if (_blacklistPattern.hasMatch(lower)) {
      violations.add('domaine blacklisté (distribution de malware)');
    }
    if (_magnetPattern.hasMatch(url)) {
      violations.add('lien magnet interdit');
    }

    return violations.isEmpty
        ? ContentPolicyResult.ok()
        : ContentPolicyResult.blocked(violations);
  }

  /// Vérifie le texte d'une description ou d'un titre avant affichage.
  ContentPolicyResult checkText(String text) {
    final violations = <String>[];

    if (_adultKeywordPattern.hasMatch(text)) {
      violations.add('contenu adulte détecté');
    }
    if (_hateSpeechPattern.hasMatch(text)) {
      violations.add('discours haineux / extrémisme détecté');
    }

    return violations.isEmpty
        ? ContentPolicyResult.ok()
        : ContentPolicyResult.blocked(violations);
  }

  /// Vérifie si un texte contient des hash bruts qui ne devraient pas être
  /// affichés directement (IOC bruts à masquer ou tronquer).
  bool containsRawHash(String text) => _rawHashInTextPattern.hasMatch(text);

  /// Vérification complète (URL + texte) pour un item d'actualité.
  ContentPolicyResult checkNewsItem({
    required String url,
    required String title,
    String description = '',
  }) {
    final urlResult = checkUrl(url);
    final titleResult = checkText(title);
    final descResult = checkText(description);

    final allViolations = [
      ...urlResult.violations,
      ...titleResult.violations,
      ...descResult.violations,
    ];

    return allViolations.isEmpty
        ? ContentPolicyResult.ok()
        : ContentPolicyResult.blocked(allViolations);
  }

  /// Renvoie une version expurgée du texte en remplaçant les hash bruts
  /// par un placeholder.
  String redactRawHashes(String text, {String placeholder = '[IOC]'}) =>
      text.replaceAllMapped(_rawHashInTextPattern, (_) => placeholder);
}

# Fiche store – Sentinelle Cyber

> Document de référence pour App Store Connect (iOS) et Google Play Console (Android).
> Tous les textes ci-dessous sont prêts à copier/coller dans les interfaces de soumission.

---

## Identité de l’application

| Champ | Valeur |
|---|---|
| **Nom de l’app** | Sentinelle Cyber |
| **Sous-titre (iOS, 30 car.)** | Veille cybersécurité en direct |
| **Identifiant bundle** | `com.bads10.sentinellecyber` |
| **Catégorie principale** | Utilitaires |
| **Catégorie secondaire** | Actualités |
| **Langue principale** | Français (fr-FR) |
| **Prix** | Gratuit |
| **Classement âge** | 12+ (contenu thématique cybersécurité) |

---

## Description courte (80 caractères – Google Play)

```
Veille cybersécurité : menaces, CVE, alertes et flux RSS en temps réel.
```

---

## Description longue (4 000 caractères max)

```
Sentinelle Cyber est votre tableau de bord mobile de veille cybersécurité.
Aggérez en un seul endroit les informations critiques publiées par les
principales sources mondiales et restez informé en temps réel, même hors-ligne.

⭐ FONCTIONNALITÉS PRINCIPALES

• Timeline unifiée – Menaces ransomware (MalwareBazaar / abuse.ch), incidents
  CVE (NVD / NIST), alertes IOC (AlienVault OTX) et flux RSS spécialisés
  (Krebs on Security, The Hacker News, BleepingComputer…) regroupés dans
  une seule vue chronologique.

• Fiches d’incidents détaillées – Score CVSS, vecteur d’attaque, CVE liés,
  description technique, lien vers la source officielle.

• Alertes ransomware – Noms de fichiers, hashes, familles de malware et
  indicateurs de compromission (IOC) issus des plateformes abuse.ch.

• Filtres avancés – Par source, par niveau de gravité (CVSS Critical /
  High / Medium / Low), par mots-clés.

• Mode hors-ligne – Cache local chiffré (TTL 24 h) pour consulter les
  dernières actualités sans connexion.

• Notifications push – Alertes locales pour les nouvelles menaces critiques
  (CVSS ≥ 9.0) dès leur publication.

• Thème sombre natif – Interface optimisée pour la lecture nocturne.

🔒 CONFIDENTIALITÉ & SÉCURITÉ

Sentinelle Cyber ne collecte aucune donnée personnelle. Pas de compte, pas
de publicité, pas de trackers. Toutes les communications réseau s’effectuent
en HTTPS. Les liens non-sécurisés ou malveillants sont automatiquement
filtrés avant affichage.

🎯 POUR QUI ?

• Professionnels de la sécurité (SOC, RSSI, pentesters)
• Administrateurs système et réseau
• Étudiants et passionnés de cybersécurité
• Journalistes spécialisés tech/sécurité

🔗 Sources utilisées
NVD (NIST) • AlienVault OTX • MalwareBazaar • abuse.ch • Krebs on Security
• The Hacker News • BleepingComputer • CERT-FR

Open source – https://github.com/bads10/sentinelle-mobile
```

---

## Mots-clés (App Store – 100 caractères max)

```
cybersecurite,menace,CVE,ransomware,alerte,IOC,securite,veille,CERT,malware
```

---

## URL obligatoires

| Type | URL |
|---|---|
| Politique de confidentialité | `https://bads10.github.io/sentinelle-mobile/privacy_policy` |
| Support | `https://github.com/bads10/sentinelle-mobile/issues` |
| Site marketing (optionnel) | `https://github.com/bads10/sentinelle-mobile` |

---

## Informations de contact (App Review / Play Console)

| Champ | Valeur |
|---|---|
| Prénom / Nom | bads10 |
| E-mail de contact | sentinelle-cyber-privacy@proton.me |
| Téléphone | (compléter avant soumission) |
| Adresse | Strasbourg, France |

---

## Screenshots requis

### Sujets recommandés (dans l’ordre)

| # | Écran | Description |
|---|---|---|
| 1 | Timeline principale | Liste unifiée : menaces + CVE + flux RSS, avec badges de gravité colorés |
| 2 | Fiche d’incident CVE | Détail d’une vulnérabilité : score CVSS, vecteur, description |
| 3 | Panneau de filtres | Sélection source + gravité + mot-clé |
| 4 | Alertes ransomware | Liste MalwareBazaar avec famille + hash tronqué |
| 5 | Notifications push | Exemple d’alerte CVSS Critical reçue |

### Formats requis

| Plateforme | Format | Dimensions |
|---|---|---|
| iPhone 6.9″ (requis) | PNG/JPEG | 1320 × 2868 px |
| iPhone 6.5″ (requis) | PNG/JPEG | 1284 × 2778 px |
| iPad Pro 13″ (recommandé) | PNG/JPEG | 2064 × 2752 px |
| Android téléphone | PNG/JPEG | 1080 × 1920 px min |
| Android tablette 7″ | PNG/JPEG | 1080 × 1920 px min |

### Icone

| Plateforme | Taille |
|---|---|
| App Store (iOS) | 1024 × 1024 px PNG sans transparence |
| Google Play | 512 × 512 px PNG |
| Feature graphic (Play) | 1024 × 500 px |

> Les fichiers source sont à placer dans `fastlane/metadata/` (voir structure ci-dessous).

---

## Notes de version initiale (What’s New)

```
Version 1.0.0 – Première version publique

• Timeline unifiée : menaces, CVE, IOC et flux RSS
• Filtres par source et par gravité CVSS
• Mode hors-ligne (cache 24 h)
• Notifications locales pour les menaces critiques
• Thème sombre natif
• Zéro collecte de données personnelles
```

---

## Classification du contenu

### Apple App Store
- Contenu généré par l’utilisateur : **Non**
- Contacts / localisation / caméra : **Non**
- Achats intégrés : **Non**
- Encryption : **Oui** (HTTPS standard, exempte d’export ECCN 5E002)
- Réponse CCATS requise : **Non** (chiffrement standard US)

### Google Play
- Accès à l’API de sensibilité élevée : **Non**
- Application ciblant les enfants : **Non**
- Déclaration de sécurité des données : **Aucune donnée collectée ni partagée**

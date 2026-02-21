# Politique de confidentialité – Sentinelle Cyber

**Dernière mise à jour : 21 février 2026**

URL publique : `https://bads10.github.io/sentinelle-mobile/privacy_policy`

---

## 1. Présentation de l’application

**Sentinelle Cyber** (ci-après « l’Application ») est une application mobile de veille
cybersecurité gratuite, disponible sur iOS (App Store) et Android (Google Play).
Elle agrège des informations publiques issues de flux RSS, d’API ouvertes (NVD,
AlienVault OTX, MalwareBazaar) et les affiche sous forme de timeline, de fiches
d’incidents et d’alertes.

Éditeur : bads10  
Contact : <sentinelle-cyber-privacy@proton.me>

---

## 2. Données collectées

### 2.1 Données collectées par l’Application

L’Application **ne collecte, ne stocke et ne transmet aucune donnée personnelle**
concernant ses utilisateurs. Plus précisément :

| Type de donnée | Collecté ? | Justification |
|---|---|---|
| Nom, prénom, e-mail | Non | Pas de compte utilisateur |
| Localisation GPS | Non | Fonctionnalité non requise |
| Contacts, agenda | Non | Fonctionnalité non requise |
| Identifiants publicitaires (IDFA/GAID) | Non | Pas de publicité |
| Données de santé ou biométriques | Non | Fonctionnalité non requise |
| Historique de navigation | Non | L’app affiche uniquement du contenu public |
| Journaux de crash (anonymes) | Oui (opt-in système) | Via les mécanismes natifs iOS/Android |

### 2.2 Données en cache local

L’Application conserve en cache local (Hive / SharedPreferences), sur le seul
appareil de l’utilisateur, les flux récemment téléchargés (titres, URLs publiques,
métadonnées d’articles) pour permettre une consultation hors-ligne. Ces données :

- sont **strictement locales** (jamais envoyées à un serveur tiers) ;
- ne contiennent **aucune information personnelle identifiable (PII)** – les champs
  potentiellement sensibles sont automatiquement expurgés par le module
  `PiiSanitizer` avant tout stockage ;
- sont automatiquement supprimées après un délai (TTL paramétrable, 24 h par défaut).

---

## 3. Sources de données tiers

L’Application consulte des API et flux publics. Les conditions d’utilisation de
chaque source s’appliquent indépendamment :

| Source | URL des CGU / politique |
|---|---|
| NVD (NIST) | https://nvd.nist.gov/general/privacy |
| AlienVault OTX | https://otx.alienvault.com/assets/legal/tos |
| MalwareBazaar (abuse.ch) | https://abuse.ch/privacy/ |
| Krebs on Security (RSS) | https://krebsonsecurity.com/privacy-policy/ |
| The Hacker News (RSS) | https://thehackernews.com/p/privacy-policy.html |

L’Application respecte scrupuleusement les limitations de débit (rate-limiting) et
les clés API préconnisées par chaque fournisseur.

---

## 4. Autorisations système demandées

| Permission | Plateforme | Utilisation |
|---|---|---|
| `INTERNET` | Android | Accès aux flux et API publics |
| `ACCESS_NETWORK_STATE` | Android | Détection de la connectivité |
| `RECEIVE_BOOT_COMPLETED` | Android (optionnel) | Repétition périodique des alertes |
| Notifications push | iOS + Android | Alertes locales (programmation interne, pas de serveur push tiers) |

Aucune permission donnant accès à des données personnelles (localisation,
contacts, micro, caméra…) n’est demandée.

---

## 5. Publicité, analytique et trackers

L’Application **n’intègre aucun SDK publicitaire, aucune analytique tierce
(Firebase Analytics, Mixpanel, etc.) et aucun tracker**.

---

## 6. Sécurité

- Toutes les requêtes réseau s’effectuent en **HTTPS** (TLS 1.2 minimum).
- Les URLs non-HTTPS sont rejetées avant affichage.
- Les liens pointant vers des binaires exécutables ou des domaines blacklistés
  sont automatiquement filtrés (`ContentPolicyChecker`).
- Aucun token, clé API ou information d’authentification n’est stocké en clair dans
  le code source (les clés sont injectées via variables d’environnement à la
  compilation).

---

## 7. Droits des utilisateurs (RGPD)

L’Application ne traitant aucune donnée personnelle au sens du RGPD
(Règlement UE 2016/679), les droits d’accès, rectification et suppression ne
s’appliquent pas matériellement. Pour toute question, contactez :
<sentinelle-cyber-privacy@proton.me>

---

## 8. Mineurs

L’Application est destinée à un public adulte (professionnels et passionnés de
cybersecurité). Elle n’est pas conçue pour collecter des données provenant
d’enfants de moins de 13 ans (COPPA) ou de moins de 16 ans (RGPD).

---

## 9. Modifications de la présente politique

Toute modification sera publiée sur cette page avec mise à jour de la date en tête
de document. En cas de changement substantiel, une notification sera affichée dans
l’Application lors de la première ouverture après mise à jour.

---

## 10. Contact

Pour toute question relative à la présente politique :  
📧 <sentinelle-cyber-privacy@proton.me>  
🔗 https://github.com/bads10/sentinelle-mobile

---

*Ce document est rédigé en français. En cas de divergence avec une traduction,
la version française fait foi.*

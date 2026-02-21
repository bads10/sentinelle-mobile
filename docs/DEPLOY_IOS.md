# Guide de déploiement iOS – Sentinelle Cyber

> Pré-requis : macOS, Xcode 15+, compte Apple Developer actif (99 $/an).

---

## 1. Préparation de l’environnement

```bash
# Installer Flutter (si absent)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Vérifier l’installation
flutter doctor -v

# Installer les dépendances du projet
cd sentinelle-mobile
flutter pub get
```

---

## 2. Configurer l’identité de l’application

### 2.1 Bundle Identifier

Ouvrir `ios/Runner.xcworkspace` dans Xcode :

1. Sélectionner la cible **Runner**
2. Onglet **General** → Identity :
   - **Bundle Identifier** : `com.bads10.sentinellecyber`
   - **Version** : `1.0.0`
   - **Build** : `1`

### 2.2 Signing & Capabilities

1. Onglet **Signing & Capabilities**
2. Cocher **Automatically manage signing**
3. **Team** : sélectionner votre équipe Apple Developer
4. Xcode créera automatiquement le provisioning profile

### 2.3 Variables d’environnement (clés API)

Créer un fichier `.env` **non versionné** à la racine :

```bash
# .env (NE PAS commiter – déjà dans .gitignore)
OTX_API_KEY=votre_clé_alienvault_otx
NVD_API_KEY=votre_clé_nvd_optionnelle
```

Dans `lib/core/constants/api_constants.dart`, les clés sont lues via :
```dart
static const String otxApiKey =
    String.fromEnvironment('OTX_API_KEY', defaultValue: '');
```

Build avec injection :
```bash
flutter build ipa \
  --dart-define=OTX_API_KEY=$OTX_API_KEY \
  --dart-define=NVD_API_KEY=$NVD_API_KEY
```

---

## 3. Build de production (IPA)

```bash
# Nettoyer et builder en mode release
flutter clean
flutter build ipa --release \
  --dart-define=OTX_API_KEY=$OTX_API_KEY \
  --dart-define=NVD_API_KEY=$NVD_API_KEY

# L'IPA est généré dans :
# build/ios/archive/Runner.xcarchive
# build/ios/ipa/sentinelle_mobile.ipa
```

---

## 4. Distribution via TestFlight

### 4.1 Uploader avec Transporter ou xcrun

```bash
# Option A – ligne de commande (xcrun altool)
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/sentinelle_mobile.ipa \
  --username "votre@apple.com" \
  --password "@keychain:AC_PASSWORD"

# Option B – App Transporter (GUI macOS)
# Télécharger depuis : https://apps.apple.com/app/transporter/id1450874784
# Glisser-déposer l’IPA puis cliquer Délivrer
```

### 4.2 App Store Connect

1. Se connecter sur https://appstoreconnect.apple.com
2. Créer une nouvelle app :
   - Nom : **Sentinelle Cyber**
   - Bundle ID : `com.bads10.sentinellecyber`
   - Langue principale : Français
   - SKU : `sentinelle-cyber-v1`
3. Onglet **TestFlight** → sélectionner le build uploadé
4. Ajouter les testeurs internes (jusqu’à 100 personnes)
5. Activer les testeurs externes → soumettre pour examen Beta App Review

### 4.3 Informations Beta Review requis

| Champ | Valeur à saisir |
|---|---|
| Notes for Review | "App de veille cybersecurité consommant des flux RSS et API publics (NVD, OTX). Pas de login requis." |
| Contact email | sentinelle-cyber-privacy@proton.me |
| Contact phone | (votre numéro) |

---

## 5. Soumission App Store (production)

### 5.1 Remplir la fiche

Dans App Store Connect → onglet **Distribution** :

- Recopier les éléments de `docs/store_listing.md`
- Ajouter 5 screenshots (voir formats dans `store_listing.md`)
- Icône 1024×1024 px (sans transparence)
- URL politique de confidentialité :
  `https://bads10.github.io/sentinelle-mobile/privacy_policy`

### 5.2 Questionnaire de conformité export

- Uses encryption : **Yes** (HTTPS standard)
- Exempt from French export laws : **Yes** (algorithmes standard)
- CCATS : **Non requis**

### 5.3 Soumettre pour examen

1. Sélectionner le build TestFlight validé
2. Cliquer **Add for Review**
3. Délai d’examen Apple : 1 à 3 jours ouvrés

---

## 6. Automatisation avec Fastlane (optionnel)

```bash
# Installer fastlane
gem install fastlane

# Initialiser dans le répertoire ios/
cd ios && fastlane init
```

`ios/fastlane/Fastfile` :

```ruby
default_platform(:ios)

platform :ios do
  desc "Déployer sur TestFlight"
  lane :beta do
    build_app(
      scheme: "Runner",
      export_method: "app-store",
      xcargs: "-allowProvisioningUpdates"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Soumettre sur l’App Store"
  lane :release do
    build_app(
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      force: true
    )
  end
end
```

```bash
# Lancer le déploiement TestFlight
cd ios && fastlane beta
```

---

## 7. Checklist finale avant soumission

- [ ] Bundle identifier configuré : `com.bads10.sentinellecyber`
- [ ] Version et build incrémentés
- [ ] Clés API injectées via `--dart-define` (jamais en dur)
- [ ] Build `flutter build ipa --release` sans erreur
- [ ] 5 screenshots ajoutés (formats valides)
- [ ] Icône 1024×1024 ajoutée
- [ ] Description (copier depuis `docs/store_listing.md`)
- [ ] URL politique de confidentialité renseignée
- [ ] Questionnaire chiffrement rempli
- [ ] TestFlight validé par au moins 2 testeurs internes
- [ ] Soumis pour App Review

---

## 8. Références

- App Store Connect : https://appstoreconnect.apple.com
- Flutter iOS release : https://docs.flutter.dev/deployment/ios
- Fastlane docs : https://docs.fastlane.tools
- App Review Guidelines : https://developer.apple.com/app-store/review/guidelines/

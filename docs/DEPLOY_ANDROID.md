# Guide de déploiement Android – Sentinelle Cyber

> Pré-requis : JDK 17+, Android Studio (ou ligne de commande), compte Google Play Console actif (25 $ unique).

---

## 1. Préparation de l’environnement

```bash
# Vérifier Flutter et Android SDK
flutter doctor -v

# Installer les dépendances
cd sentinelle-mobile
flutter pub get
```

S’assurer que `android/local.properties` contient :
```properties
sdk.dir=/Users/VOTRE_USER/Library/Android/sdk
```

---

## 2. Configurer la signature (Keystore)

### 2.1 Générer un keystore de production

```bash
# Générer le keystore (une seule fois – conserver précieusement)
keytool -genkey -v \
  -keystore sentinelle-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias sentinelle-key
```

> **Important** : ne jamais commiter `sentinelle-release.jks` dans le dépôt.
> Ajouter `*.jks` et `key.properties` à `.gitignore`.

### 2.2 Fichier `android/key.properties`

```properties
storePassword=VOTRE_MOT_DE_PASSE_STORE
keyPassword=VOTRE_MOT_DE_PASSE_CLE
keyAlias=sentinelle-key
storeFile=/chemin/absolu/vers/sentinelle-release.jks
```

### 2.3 Configurer `android/app/build.gradle`

Ajouter avant `android {` :

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Dans `android { ... signingConfigs { ... } }` :

```groovy
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ?
            file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
            'proguard-rules.pro'
    }
}
```

---

## 3. Configurer l’identité de l’application

Dans `android/app/build.gradle`, bloc `defaultConfig` :

```groovy
defaultConfig {
    applicationId "com.bads10.sentinellecyber"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode 1
    versionName "1.0.0"
}
```

---

## 4. Variables d’environnement (clés API)

```bash
# .env (NE PAS commiter)
OTX_API_KEY=votre_clé_alienvault_otx
NVD_API_KEY=votre_clé_nvd_optionnelle
```

---

## 5. Build du bundle de production (AAB)

```bash
# Build Android App Bundle (recommandé pour Google Play)
flutter clean
flutter build appbundle --release \
  --dart-define=OTX_API_KEY=$OTX_API_KEY \
  --dart-define=NVD_API_KEY=$NVD_API_KEY

# Fichier généré :
# build/app/outputs/bundle/release/app-release.aab

# Alt : build APK (pour distribution directe / tests)
flutter build apk --release --split-per-abi \
  --dart-define=OTX_API_KEY=$OTX_API_KEY

# APKs générés :
# build/app/outputs/apk/release/app-arm64-v8a-release.apk
# build/app/outputs/apk/release/app-armeabi-v7a-release.apk
# build/app/outputs/apk/release/app-x86_64-release.apk
```

---

## 6. Publication sur Google Play Console

### 6.1 Créer l’application

1. Se connecter sur https://play.google.com/console
2. **Créer une application**
3. Renseigner :
   - Nom : **Sentinelle Cyber**
   - Langue par défaut : Français
   - App ou jeu : **Application**
   - Gratuit ou payant : **Gratuit**

### 6.2 Remplir la fiche store

Dans **Fiche Play Store** → **Principale** :

- Recopier les textes de `docs/store_listing.md`
- Icône 512×512 px
- Feature graphic 1024×500 px
- 2 à 8 screenshots téléphone (voir formats dans `store_listing.md`)

### 6.3 Déclaration de confidentialité

Dans **Politique de confidentialité** :
```
https://bads10.github.io/sentinelle-mobile/privacy_policy
```

### 6.4 Déclaration sécurité des données

Dans **Sécurité des données** :
- Collecte de données : **Non**
- Partage de données : **Non**
- Pratiques de sécurité : cocher « Les données sont chiffrées lors du transfert »
- Engagement envers la politique Families : **Non applicable**

### 6.5 Classification du contenu

Remplir le questionnaire de classification (section **Classification du contenu**) :
- Langue et violence : niveau bas
- Programme pour les familles : Non
- Obtenir la notation PEGI / ESRB (automatique après le questionnaire)

### 6.6 Publier en test interne (Internal Testing)

1. **Tests** → **Tests internes** → Créer une version
2. Téléverser `app-release.aab`
3. Ajouter des testeurs (e-mail Google)
4. Partager le lien de test opt-in

### 6.7 Publier en production

1. **Production** → **Créer une version**
2. Téléverser `app-release.aab`
3. Notes de version (copier depuis `store_listing.md`)
4. Cliquer **Envoyer pour examen**
5. Délai d’examen Google : quelques heures à 7 jours

---

## 7. Automatisation avec Fastlane Supply (optionnel)

```bash
# Installer fastlane
gem install fastlane

# Initialiser dans le répertoire android/
cd android && fastlane init
```

`android/fastlane/Fastfile` :

```ruby
default_platform(:android)

platform :android do
  desc "Déployer sur Internal Testing"
  lane :internal do
    gradle(
      task: "bundle",
      build_type: "Release"
    )
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab"
    )
  end

  desc "Promouvoir en production"
  lane :production do
    upload_to_play_store(
      track: "production",
      track_promote_to: "production"
    )
  end
end
```

```bash
# Lancer le déploiement internal testing
cd android && fastlane internal
```

---

## 8. Checklist finale avant soumission

- [ ] `applicationId` configuré : `com.bads10.sentinellecyber`
- [ ] `versionCode` et `versionName` incrémentés
- [ ] Keystore généré et sauvegardé hors dépôt
- [ ] `key.properties` ajouté au `.gitignore`
- [ ] Clés API injectées via `--dart-define`
- [ ] Build `flutter build appbundle --release` sans erreur
- [ ] AAB signé vérifié : `jarsigner -verify app-release.aab`
- [ ] Screenshots + icône + feature graphic ajoutés
- [ ] Déclaration données sécurité complétée
- [ ] Classification du contenu obtenue
- [ ] Politique de confidentialité URL renseignée
- [ ] Testé sur appareil physique et émulateur API 21+
- [ ] Soumis en Internal Testing puis Production

---

## 9. Références

- Google Play Console : https://play.google.com/console
- Flutter Android release : https://docs.flutter.dev/deployment/android
- Fastlane Supply : https://docs.fastlane.tools/actions/supply/
- Android App Bundle : https://developer.android.com/guide/app-bundle

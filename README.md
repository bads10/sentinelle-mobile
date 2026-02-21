# sentinelle-mobile

> Application mobile Flutter – Veille cybersécurité temps réel. MVP Sentinelle.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI](https://github.com/bads10/sentinelle-mobile/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/bads10/sentinelle-mobile/actions/workflows/flutter_ci.yml)

---

## Description

`sentinelle-mobile` est l'application mobile Flutter du projet **Sentinelle** – une plateforme de veille cybersécurité temps réel. Elle consomme l'API REST du backend `sentinelle-backend` (FastAPI) pour afficher :

- Alertes ransomware (via MalwareBazaar, abuse.ch)
- Incidents cybersécurité (via CIRCL CVE, NVD)
- Flux RSS cybersécurité (Krebs on Security, The Hacker News, etc.)
- Statistiques et tendances en temps réel

---

## Architecture

```
sentinelle-mobile/
├── .github/
│   └── workflows/
│       └── flutter_ci.yml      # CI/CD GitHub Actions
├── lib/
│   ├── main.dart               # Point d'entrée
│   ├── app.dart                # Configuration app + thème
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── routes/
│   │       └── app_routes.dart
│   ├── models/
│   │   ├── threat.dart
│   │   ├── incident.dart
│   │   ├── rss_item.dart
│   │   └── stats.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── threat_service.dart
│   │   ├── incident_service.dart
│   │   ├── rss_service.dart
│   │   ├── cache_service.dart      # Cache Hive TTL
│   │   └── notification_service.dart # Push locales Android/iOS
│   ├── providers/
│   │   ├── threat_provider.dart
│   │   ├── incident_provider.dart
│   │   ├── rss_provider.dart
│   │   ├── stats_provider.dart
│   │   ├── cache_provider.dart     # StateNotifier cache
│   │   └── notification_provider.dart # StateNotifier notifications
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── threats/
│   │   │   ├── threats_screen.dart
│   │   │   └── threat_detail_screen.dart
│   │   ├── incidents/
│   │   │   ├── incidents_screen.dart
│   │   │   └── incident_detail_screen.dart
│   │   └── feed/
│   │       └── feed_screen.dart
│   └── widgets/
│       ├── threat_card.dart
│       ├── incident_card.dart
│       ├── rss_card.dart
│       ├── severity_badge.dart
│       └── stats_widget.dart
├── test/
│   ├── models/
│   │   ├── threat_test.dart
│   │   └── incident_test.dart
│   └── providers/
│       └── notification_state_test.dart
├── pubspec.yaml
├── .gitignore
└── README.md
```

## Stack technique

| Technologie | Usage |
|---|---|
| Flutter 3.x | Framework mobile cross-platform |
| Dart 3.x | Langage |
| Riverpod 2.x | State management |
| Dio | Client HTTP |
| Go Router | Navigation |
| Freezed | Modèles immutables |
| Hive | Cache local offline |
| flutter_local_notifications | Notifications push locales |
| fl_chart | Graphiques statistiques |
| intl | Internationalisation |

## Backend API

Consomme `sentinelle-backend` en FastAPI :

```
GET /api/v1/threats/       # Liste des menaces
GET /api/v1/threats/{id}   # Détail menace
GET /api/v1/incidents/     # Liste incidents CVE
GET /api/v1/incidents/{id} # Détail incident
GET /api/v1/feed/          # Flux RSS
GET /api/v1/stats/         # Statistiques globales
GET /health                # Health check
```

## Installation

```bash
# Cloner le repo
git clone https://github.com/bads10/sentinelle-mobile.git
cd sentinelle-mobile

# Installer les dépendances
flutter pub get

# Générer les fichiers Freezed
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer l'app (simulateur/device connecté)
flutter run
```

### Configuration

Copier `.env.example` vers `.env` :

```env
API_BASE_URL=http://localhost:8000
API_VERSION=v1
```

## Tests

```bash
# Lancer tous les tests
flutter test

# Avec couverture de code
flutter test --coverage

# Analyse statique
flutter analyze
```

## Roadmap MVP

- [x] Étape 0 – Initialisation du repo
- [x] Étape 1 – Structure Flutter + navigation
- [x] Étape 2 – Modèles de données + services API
- [x] Étape 3 – Écrans principaux (Home, Threats, Incidents, Feed)
- [x] Étape 4 – State management Riverpod
- [x] Étape 5 – Cache offline Hive
- [x] Étape 6 – Notifications push
- [x] Étape 7 – Tests + CI/CD
- [x] Étape 8 – Qualité, sécurité, conformité (PII, retry, rate-limit, store-friendly)

## Licence

MIT – voir [LICENSE](LICENSE)

> Projet Sentinelle – Veille cybersécurité automatisée

# sentinelle-mobile

> Application mobile Flutter – Veille cybersécurité temps réel. MVP Sentinelle.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

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
├── lib/
│   ├── main.dart                  # Point d'entrée
│   ├── app.dart                   # Configuration app + thème
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart # URLs API, endpoints
│   │   │   └── app_constants.dart # Constantes globales
│   │   ├── theme/
│   │   │   └── app_theme.dart     # Thème dark cybersécurité
│   │   └── routes/
│   │       └── app_routes.dart    # Navigation routes
│   ├── models/
│   │   ├── threat.dart            # Modèle Threat/Ransomware
│   │   ├── incident.dart          # Modèle Incident CVE
│   │   ├── rss_item.dart          # Modèle flux RSS
│   │   └── stats.dart             # Modèle statistiques
│   ├── services/
│   │   ├── api_service.dart       # Client HTTP Dio
│   │   ├── threat_service.dart    # Service threats
│   │   ├── incident_service.dart  # Service incidents
│   │   └── rss_service.dart       # Service RSS
│   ├── providers/
│   │   ├── threat_provider.dart   # State threats (Riverpod)
│   │   ├── incident_provider.dart # State incidents
│   │   └── rss_provider.dart      # State RSS
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart   # Écran principal
│   │   ├── threats/
│   │   │   ├── threats_screen.dart
│   │   │   └── threat_detail_screen.dart
│   │   ├── incidents/
│   │   │   ├── incidents_screen.dart
│   │   │   └── incident_detail_screen.dart
│   │   └── feed/
│   │       └── feed_screen.dart   # Flux RSS
│   └── widgets/
│       ├── threat_card.dart       # Carte menace
│       ├── incident_card.dart     # Carte incident
│       ├── rss_card.dart          # Carte article RSS
│       ├── severity_badge.dart    # Badge sévérité
│       └── stats_widget.dart      # Widget statistiques
├── pubspec.yaml
├── .gitignore
└── README.md
```

---

## Stack technique

| Technologie | Usage |
|---|---|
| Flutter 3.x | Framework mobile cross-platform |
| Dart 3.x | Langage |
| Riverpod 2.x | State management |
| Dio | Client HTTP |
| Go Router | Navigation |
| Freezed | Modèles immutables |
| Hive | Cache local |
| fl_chart | Graphiques statistiques |
| intl | Internationalisation |

---

## Backend API

Consomme `sentinelle-backend` en FastAPI :

```
GET /api/v1/threats/          # Liste des menaces
GET /api/v1/threats/{id}      # Détail menace
GET /api/v1/incidents/        # Liste incidents CVE
GET /api/v1/incidents/{id}    # Détail incident
GET /api/v1/feed/             # Flux RSS
GET /api/v1/stats/            # Statistiques globales
GET /health                   # Health check
```

---

## Installation

```bash
# Cloner le repo
git clone https://github.com/bads10/sentinelle-mobile.git
cd sentinelle-mobile

# Installer les dépendances
flutter pub get

# Générer les fichiers Freezed
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer l'app (émulateur/device connecté)
flutter run
```

### Configuration

Copier `.env.example` vers `.env` :

```
API_BASE_URL=http://localhost:8000
API_VERSION=v1
```

---

## Roadmap MVP

- [x] Étape 0 – Initialisation du repo
- [x] Étape 1 – Structure Flutter + navigation
- [x] Étape 2 – Modèles de données + services API
- [x] Étape 3 – Écrans principaux (Home, Threats, Incidents, Feed)
- [x] Étape 4 – State management Riverpod
- [ ] Étape 5 – Cache offline Hive
- [ ] Étape 6 – Notifications push
- [ ] Étape 7 – Tests + CI/CD

---

## Licence

MIT – voir [LICENSE](LICENSE)

---

*Projet Sentinelle – Veille cybersécurité automatisée*

# Migration Guide: Refactoring `prana/lib` into `frontend/` and `shared/`

This guide explains how to safely refactor the current Flutter app into the new organized structure without breaking the running app during the hackathon.

1. Keep `prana/` as the canonical app while you refactor incrementally.
2. Copy files you intend to refactor into `shared/` (models, services, constants) and `frontend/` (pages, widgets).
3. Replace secrets in `lib/constants/api_keys.dart` with environment variables stored in `configs/environments/.env.*` and update code to read them.
4. Update imports gradually and run the app after each change.
5. Once refactor is stable, move the `lib/` folder inside `prana/` to `frontend/prana_app/lib` and update `pubspec.yaml` if needed.

Notes:
- Avoid moving files that are required to run the app until the corresponding imports are updated.
- Use feature branches for each major refactor to keep the hackathon pace fast and reversible.

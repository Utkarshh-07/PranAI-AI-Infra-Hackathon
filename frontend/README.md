# Frontend (Flutter)

The existing Flutter app is located in the `prana/` folder and is the canonical runnable app for now.

This `frontend/` directory is intended to host a refactored, modular frontend for faster collaboration. For hackathon speed we keep the original `prana/` app untouched and create refactor branches that import shared code from `shared/`.

Quick run (from project root):

```bash
cd prana
flutter pub get
flutter run
```

Recommended next steps:
- Move pieces from `prana/lib/` into `frontend/` incrementally.
- Update imports to use `package:shared/...` or relative paths.
- Replace secret-bearing files with environment-managed values (see `configs/environments`).

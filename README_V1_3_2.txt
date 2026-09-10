BAND FIT HOME v1.3.2

This package fixes the Internet/AI food scanner path explicitly.

UPLOAD TO GITHUB REPO ROOT:
- lib/
- assets/
- pubspec.yaml
- .github/workflows/build-apk.yml

Keep repository secret:
GEMINI_API_KEY

Then:
Actions > Build Android APK > Run workflow

The workflow will FAIL if INTERNET/CAMERA permissions are not present after patching.
Artifact name after success:
BandFitHome-v1.3.2-APK

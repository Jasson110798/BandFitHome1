# BandFit Home v1.1 — Exercise Illustrations + AI Calories

## What changed
- Procedural exercise illustrations for every workout item.
- Large exercise illustration shown during active workout timer.
- New **AI Calo** bottom tab.
- Camera and gallery image picker.
- Gemini multimodal analysis returns estimated dish, portions, calories, protein, carbs and fat.
- Clear warning that photo nutrition values are estimates.

## Enable AI food analysis
Create a Gemini API key, then in GitHub repository:

Settings → Secrets and variables → Actions → New repository secret

Name:
`GEMINI_API_KEY`

Value:
your Gemini API key

Then run **Build Android APK** again.

## Important
The current MVP injects the API key into the APK for convenient personal testing. An APK can be reverse-engineered, so for a public/store release, move AI calls behind a server/Firebase Function proxy and keep the key server-side.

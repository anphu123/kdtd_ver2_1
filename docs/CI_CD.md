# CI/CD Guide

This guide covers the Continuous Integration and Continuous Deployment (CI/CD) setup for the KDTD project. We currently use **Codemagic** (primary) and **GitHub Actions** (secondary/Android-only).

---

## 🚀 Codemagic CI/CD (Primary)

Codemagic is our primary CI/CD platform for building both Android and iOS apps.

### Workflows

The `codemagic.yaml` configuration includes the following workflows:

| Workflow | Platform | Trigger | Output | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **android-debug** | Android | Push to `develop` | Debug APK | Testing |
| **android-release** | Android | Push to `main` or tag `v*` | Release APKs | Production |
| **android-appbundle** | Android | Tag `release-*` | AAB | Play Store |
| **ios-debug** | iOS | Push to `develop` | Debug IPA | Testing |
| **ios-testflight** | iOS | Push to `main` or tag `ios-*` | Release IPA | TestFlight Beta |
| **ios-appstore** | iOS | Tag `appstore-*` | Release IPA | App Store |

### Setup Instructions

1.  **Register**: Sign up at [codemagic.io](https://codemagic.io).
2.  **Add App**: Connect your repository and select Flutter project type.
3.  **Workflows**: The system will automatically detect `codemagic.yaml`.

### Configuration Details

#### Android Signing
For release builds, you need to set up the keystore:
1.  **Upload Keystore**: Go to **App settings** -> **Code signing identities** -> **Android** and upload your `upload-keystore.jks`.
2.  **Environment Variables**: In **Teams** -> **Environment variables**, create a group `android_credentials` with:
    -   `CM_KEYSTORE_PASSWORD`
    -   `CM_KEY_PASSWORD`
    -   `CM_KEY_ALIAS` (typically `upload`)

#### iOS Signing
For iOS builds, we recommend **Automatic Code Signing**:
1.  **App Store Connect API Key**: Generate an API Key in App Store Connect (Users and Access -> Keys).
2.  **Add to Codemagic**: In **Teams** -> **Integrations** -> **App Store Connect**, add your Issuer ID, Key ID, and `.p8` private key file.
3.  **Enable Signing**: In **App settings** -> **Code signing identities** -> **iOS**, enable "Automatic code signing" and select your key.

#### Google Play Publishing
To automate Play Store uploads:
1.  Create a **Service Account** in Google Cloud Console with "Google Play Android Developer" access.
2.  Download the JSON key.
3.  In Codemagic **Environment variables**, create group `google_play` and add `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` (paste the JSON content).

### Free Tier Optimization
If you are on the Codemagic Free Tier (500 mins/month), follow these tips:
-   **Trigger sparingly**: Use tags to trigger builds instead of every push.
-   **Split Config**: Consider using a separate `codemagic-free.yaml` that limits triggers if you are running low on minutes.
-   **Build Time**: Android builds take ~8-12m, iOS builds take ~15-20m.
-   **Instance**: Free tier uses Linux (slow for Android) and Mac Mini M1 (standard for iOS).

---

## 🤖 GitHub Actions (Android Only)

We also have a backup workflow for Android in `.github/workflows/android-ci.yml`.

### Features
-   Builds Debug and Release APKs on push to `main` or `develop`.
-   Uploads APKs as valid artifacts.
-   Can create GitHub Releases automatically.

### Usage
-   **Auto-run**: Pushing code triggers the workflow.
-   **Artifacts**: Download the built APKs from the "Actions" tab summary page.

---

## 📦 Build Commands

For manual triggers via Git:

```bash
# Debug Build
git checkout develop && git push origin develop

# iOS TestFlight
git tag ios-1.0.0 && git push origin ios-1.0.0

# Android Play Store
git tag release-1.0.0 && git push origin release-1.0.0
```

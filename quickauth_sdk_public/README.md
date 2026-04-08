# CirightPro Flutter SDK (`quick_auth_sdk`)

White-label Flutter SDK for CirightPro QuickAuth.

This package performs **native network verification** on-device and sends the resulting **authorization code** to your backend. Your backend exchanges the code and returns your app’s **JWT/session**.

## Install

Add the package dependency the way your team distributes it (path/git). Then import:

```dart
import 'package:quick_auth_sdk/quick_auth_sdk.dart';
```

## Quick start

### 1) Initialize (once)

```dart
QuickAuthSDK.init(
  apiKey: "<your_api_key>",
  apiBaseUrl: "https://api.ciright.pro",
  cirightProClientId: "<your_cirightpro_client_id>",
  redirectUri: "https://get-started.ciright.pro/callback",
  testMode: false, // set true on simulator/CI
);
```

### 2) Login

```dart
final result = await QuickAuthSDK.login(
  "999123456789",
  onProgress: (msg) => print(msg),
);

if (result.success) {
  print("JWT: ${result.token}");
} else {
  print("Error: ${result.message}");
}
```

## Required app configuration

### Android deep link + redirect activity

Your Android app must include the provider redirect activity + an intent-filter that matches your `redirectUri` host/path.

## What the SDK sends to your backend

The SDK includes tenant headers for backend policy enforcement:
- `x-api-key`
- `x-qa-client-id` (from `cirightProClientId`)
- `x-qa-redirect-uri` (from `redirectUri`)

## Backend requirements

Your backend must:
- exchange the authorization code with the underlying provider
- return your app’s JWT/session
- validate the tenant headers against your `apiKey`



# quick_auth_sdk (QuickAuthSDK) - White-label Phone Authentication

This package provides a simple interface for phone authentication while keeping the IPification details hidden.

## Public API

### 1) Initialize

Call once when your app starts:

```dart
QuickAuthSDK.init(
  apiKey: "client_123",
  apiBaseUrl: "http://<backend-ip>:3000",
  ipificationClientId: "<ipification_client_id>",
  redirectUri: "https://get-started.ciright.pro/callback",
  testMode: false, // only use true on simulator
);
```

### 2) Login

```dart
final result = await QuickAuthSDK.login("999123456789");

if (result.success) {
  print(result.token);
} else {
  print(result.message);
}
```

`AuthResult`:

- `success: bool`
- `message: String`
- `token: String?`
- `user: Map<String, dynamic>?`

## Android integration requirements

Your app must include the IPification redirect activity + deep link intent-filter.
In this repo it is implemented in:

- `quickauth_demo_app/android/app/src/main/AndroidManifest.xml`

Use the same pattern:

- `android:name="com.ipification.mobile.sdk.im.ui.IMVerificationActivity"`
- intent filter with:
  - `android:scheme="https"`
  - `android:host="get-started.ciright.pro"`

If your `redirectUri` host/path changes, update the manifest filter accordingly.

## What configuration is inside the SDK?

Inside the SDK, `src/services/ip_service.dart` configures the native IPification plugin:

- `setEnv(ENV.SANDBOX)`
- `setClientId(ipificationClientId)`
- `setRedirectUri(redirectUri)`
- scope: `openid ip:phone_verify`

The SDK does NOT store IPification secrets.

For SaaS policy checks, SDK also sends tenant metadata headers to backend:

- `x-qa-client-id` (from `ipificationClientId`)
- `x-qa-redirect-uri` (from `redirectUri`)

Backend can enforce these per `apiKey`.

## What configuration must be done in your backend?

The backend exchanges the authorization code with IPification and issues JWT.
It must have:

- `.env` with:
  - `MONGO_URI`, `JWT_SECRET`
  - `IPIFICATION_CLIENT_ID`, `IPIFICATION_CLIENT_SECRET`
  - `IPIFICATION_BASE_URL`, `REDIRECT_URI`
  - `HOST` set to a reachable value (usually `0.0.0.0` for dev)
- A MongoDB `clients` document with your `apiKey`

## Common issues

### Simulator fails with `MissingPluginException`
Fix: run on a real device or set `testMode: true` during init.

### Login hangs / slow
Fix: confirm:
 - phone and Mac are on the same network
 - `apiBaseUrl` points to the correct Mac IP
 - backend can reach IPification

### `Phone verification mismatch`
Fix:
- backend compares digits-only normalization for `login_hint`
- phone should be digits-only (7–15 digits)


# Taxi Collectif — Flutter Mobile App

Taxi Collectif is a Flutter client for passengers who need to find collective taxi departures and reserve seats. The app lets a signed-in user browse stations, view routes and upcoming departures, select seats, and submit a reservation. It also includes account registration, sign-in, password recovery, a profile screen, and a history screen placeholder.

This repository contains the **client application only**. The backend API, database, deployment configuration, and account provisioning are maintained separately. The app expects a JSON API with the endpoints and response shapes described below.

## Contents

- [Application flow](#application-flow)
- [Features and current scope](#features-and-current-scope)
- [Technology and architecture](#technology-and-architecture)
- [Requirements](#requirements)
- [Run the app locally](#run-the-app-locally)
- [Configure the backend](#configure-the-backend)
- [Backend API contract](#backend-api-contract)
- [State, networking, and session behavior](#state-networking-and-session-behavior)
- [Project structure](#project-structure)
- [Validation and error handling](#validation-and-error-handling)
- [Build commands](#build-commands)
- [Troubleshooting](#troubleshooting)
- [Known limitations and follow-up work](#known-limitations-and-follow-up-work)

## Application flow

### Startup and sign-in

1. `main()` initializes Flutter and starts `TaxiCollectifApp`.
2. The root widget registers the app-wide providers and applies the shared Material theme.
3. `SplashScreen` checks for an existing session through `GET /api/auth/me`.
4. A valid session opens the main navigation; otherwise, the user is directed to sign-in.

Sign-in accepts an email address or username and a password. Registration collects an email, username, first and last name, phone number, and password. When registration succeeds, the app tries to sign in automatically. If that sign-in attempt fails, the account creation remains successful and the user can sign in manually. The forgot-password form submits an email address to the backend.

### Browse and reserve

The main navigation currently contains four destinations:

| Destination | Screen | Purpose |
| --- | --- | --- |
| Accueil | `AccueilScreen` | Home greeting, station preview, and entry point to station browsing. |
| Stations | `StationsListScreen` | Search and select a station. Search is debounced before the API request. |
| History | `HistoryPlaceholderScreen` | Empty-state placeholder for past rides and reservations. |
| Profile | `ProfileScreen` | Show account details and sign out. |

The reservation journey is:

1. Choose a station from the station list.
2. Review routes associated with that station in `StationLinesScreen`.
3. Choose a route to view matching, not-yet-departed vehicles in `AvailableVehiclesScreen`.
4. Select seats in `SeatReservationScreen` and review the calculated fare.
5. Submit the reservation and view the result in `ReservationSuccessDialog`.

The station route screen joins route and entrance data using the route IDs exposed by vehicle data. The vehicle screen loads reservation data for each matching entrance to estimate occupancy and remaining seats. The reservation provider enforces the client-side capacity and selection limit and submits the entrance ID and requested seat count.

## Features and current scope

- Cookie-authenticated sign-in, registration, session lookup, and sign-out.
- Forgot-password request, plus service methods for password reset and authenticated password change.
- Station browsing with debounced text search.
- Station route and departure browsing, fare/status display, and seat availability estimates.
- Local selection of up to four seats and reservation submission.
- Shared Material theme, reusable text fields and checkbox, and a social sign-in presentation button.
- Flutter runner folders are present for Android, iOS, web, Windows, macOS, and Linux.

The social sign-in button is currently presentation only: this project does not include a Google authentication SDK or a connected OAuth flow.

## Technology and architecture

The app is implemented in Dart with Flutter Material widgets. Runtime packages declared in `pubspec.yaml` are:

| Package | Use |
| --- | --- |
| `provider` | App state through `ChangeNotifier` providers. |
| `dio` | HTTP client and request configuration. |
| `cookie_jar`, `dio_cookie_manager` | Store and send authentication cookies. |
| `path_provider` | Find the native app documents directory for persistent cookies. |
| `google_fonts` | Inter typography and text styling. |
| `cupertino_icons` | Cupertino icon glyphs. |

`flutter_test` and `flutter_lints` are development dependencies. Material icons are enabled. No bundled application image assets or local font files are declared in the Flutter section of `pubspec.yaml`.

### Data flow

Screens render provider state and call provider methods in response to user actions. Providers call service classes, which use the shared `ApiClient`. Services decode JSON into model objects, and providers expose loading, error, and result state to the screens.

The root providers registered in `lib/main.dart` are:

| Provider | Responsibility |
| --- | --- |
| `AuthProvider` | Current session and user; sign-in, registration, logout, and password-reset request state. |
| `StationsProvider` | Station list, search query, loading/error state, and unauthorized-session state. |
| `StationLinesProvider` | Load a station's routes and entrances and prepare route-card data. |
| `AvailableVehiclesProvider` | Load matching departures and reservation data and prepare departure display data. |
| `SeatReservationProvider` | Seat selection, capacity and availability, fare calculation, and reservation submission. |

The services are `AuthService`, `StationService`, `RouteService`, `EntranceService`, and `ReservationService`. Models include users, stations, routes, entrances, vehicles, drivers, reservations, reservation seat references, and pagination. `StationLineCardVm` and `VehicleDepartureVm` shape backend data for presentation.

## Requirements

- Flutter SDK installed and available on `PATH`.
- A Dart SDK satisfying the package constraint in `pubspec.yaml` (`^3.13.2`).
- A running Taxi Collectif API compatible with the client contract below.
- A supported target device or desktop environment. For iOS builds, use macOS with the required Apple tooling; platform-specific build tools are required for the other native targets as well.

## Run the app locally

From the repository root:

```sh
flutter doctor
flutter pub get
flutter run
```

`flutter doctor` reports missing platform tooling. Once a device or emulator is available, list the detected targets with `flutter devices` and select one with `flutter run -d <device-id>` if needed.

The default API address is for an Android emulator. Before running on another target, check [Configure the backend](#configure-the-backend). The backend must be running and reachable from the selected device.

## Configure the backend

The base URL is set in [`lib/config/api_config.dart`](lib/config/api_config.dart):

```dart
static String baseUrl = 'http://10.0.2.2:3000';
```

Use an address that the app's runtime environment can reach:

| Target | Typical local development URL |
| --- | --- |
| Android emulator | `http://10.0.2.2:3000` (current default; routes to the host machine) |
| iOS simulator | `http://localhost:3000` |
| Physical phone/tablet | `http://<development-machine-LAN-IP>:3000` |
| Web browser | A browser-reachable backend URL; the API must allow the web app's origin through CORS. |

Change the value in `ApiConfig.baseUrl` to match your backend. `ApiClient.updateBaseUrl()` can also update the configured URL at runtime if called by application code, but no environment/flavor selection UI is currently provided. For a deployed app, use the appropriate HTTPS API address and platform network configuration.

The client sends JSON using `Content-Type: application/json` and `Accept: application/json`. Connection and receive timeouts are each 15 seconds. The configured Dio client allows responses through for service-level handling, so HTTP failures are mapped into the app's API error model instead of being rejected automatically by Dio.

## Backend API contract

The client currently uses these endpoints. All paths are appended to the configured base URL.

| Operation | Method and path | Request/query details |
| --- | --- | --- |
| Sign in | `POST /api/auth/login` | `email` or `username`, plus `password`. |
| Register | `POST /api/users` | Passenger details and backend-required role/status values. |
| Current user | `GET /api/auth/me` | Uses the session cookie. |
| Sign out | `POST /api/auth/logout` | Ends the server session; the local cookie jar is also cleared. |
| Change password | `PATCH /api/auth/change-password` | `currentPassword` and `newPassword`. Service method exists; no dedicated screen is listed in the current flow. |
| Request password reset | `POST /api/auth/forgot-password` | `email` and a redirect URI. |
| Reset password | `POST /api/auth/reset-password` | `token` and `newPassword`. Service method exists; no separate reset screen is listed in the current flow. |
| Stations | `GET /api/stations` | Optional `page`, `limit`, `search`, `governorate`, and `city`. |
| Routes | `GET /api/routes` | Optional `stationId`, `page`, `limit`, and `search`. |
| Entrances | `GET /api/entrances` | Optional `stationId`, `page`, `limit`, and `status`. |
| Reservations | `GET /api/reservations` | Optional `entranceId`, `page`, and `limit`. |
| Create reservation | `POST /api/reservations` | `entranceId` and `numberOfSeats`. |

Collection endpoints are expected to return an envelope with `success: true`, a `data` list, and optional `pagination`. Authentication responses use `data` as a user object. Error parsing recognizes `message`, `error`, and field-level `errors`, and has fallback messages for common HTTP status codes. Model parsing supports numeric values supplied as either numbers or strings and applies defaults to missing optional fields.

Registration sends `role: "Passanger"`, `status: "active"`, and `stationId: null`; the role spelling is retained to match the value expected by the backend implementation. Confirm that your backend uses the same contract if you change it.

## State, networking, and session behavior

`ApiClient` is a singleton shared by service classes. It configures Dio with the API base URL, JSON headers, and timeouts, then attaches a cookie manager. On native platforms, cookies are stored persistently under the app documents directory when storage initialization succeeds. On web, cookies use an in-memory jar. If persistent storage initialization fails, the client falls back to an in-memory cookie jar.

Sign-out attempts the server logout and clears local cookies even if that request fails. Protected-data requests can flag an unauthorized session; the browsing and reservation screens use that signal to sign out and send the user back to sign-in. Cookie behavior can differ by platform and browser policy, so verify the backend cookie attributes and CORS credentials configuration when using web.

## Project structure

```text
lib/
├── main.dart                       App entry point, theme, and provider registration
├── config/
│   └── api_config.dart             API base URL, endpoint paths, and timeouts
├── core/
│   ├── network/
│   │   ├── api_client.dart         Shared Dio client and cookie persistence
│   │   └── api_exception.dart      API/network error representation
│   ├── theme/
│   │   └── app_theme.dart          Shared colors, typography, and component styles
│   └── utils/
│       └── validators.dart         Form validation helpers
├── models/                         JSON models and UI-oriented view models
├── providers/                      ChangeNotifier state and UI operations
├── screens/                        Full-page UI and user flows
├── services/                       Backend API calls and response parsing
└── widgets/                        Reusable form and social-login presentation widgets

test/
└── widget_test.dart                Basic splash-screen widget test

android/, ios/, web/, windows/, macos/, linux/
                                    Flutter platform runners and configuration
```

Notable screens include `SplashScreen`, `SignInScreen`, `RegisterScreen`, `ForgotPasswordScreen`, `StationsListScreen`, `StationLinesScreen`, `AvailableVehiclesScreen`, `SeatReservationScreen`, `ProfileScreen`, and `HistoryPlaceholderScreen`.

## Validation and error handling

`Validators` provides checks for email format, username length and characters, required first and last names, phone number shape, password length (8–128 characters), password confirmation, and sign-in identifier format. The backend remains responsible for authoritative validation.

Station search waits roughly 300 milliseconds after typing before making a request. Route and entrance data load together for a station. An entrance-loading failure is treated as non-fatal in the route list except when it indicates an unauthorized session. In the vehicle list, if reservation loading fails for an individual entrance, that departure is still shown with an empty reservation list. This means the displayed availability is an estimate and depends on the response data successfully loaded by the client.

## Build commands

Examples (each target still requires its platform's local tooling and signing setup):

```sh
flutter build apk
flutter build appbundle
flutter build ios
flutter build web
flutter build windows
flutter build macos
flutter build linux
```

For a local debug run, use `flutter run`. The app version and build number are declared in `pubspec.yaml` and can be overridden by Flutter build options such as `--build-name` and `--build-number`.

## Troubleshooting

### The app cannot connect to the API

- Confirm that the backend is running and listening on the expected port.
- Check that `ApiConfig.baseUrl` matches the target. `localhost` inside an Android emulator points to the emulator itself; use `10.0.2.2` to reach the development host.
- For a physical device, use the host machine's LAN IP and ensure both devices are on a network that permits the connection.
- For web, check browser console messages, CORS origin settings, and whether credentialed requests/cookies are allowed by the backend.

### The app repeatedly returns to sign-in

Verify that the login endpoint sets the expected session cookie and that `/api/auth/me` accepts it. On native targets, persistent storage requires access to the app documents directory. On web, cookies are in-memory and may be subject to browser cookie policy.

### Stations or departures do not appear

Check the backend collection envelope (`success`, `data`, and optional `pagination`), query parameter support, and the nested route/vehicle IDs used to connect station entrances to routes. Inspect the app's visible error message and backend logs for response details.

## Known limitations and follow-up work

- Ride history currently displays a placeholder; there is no user-facing reservation-history flow.
- Selected seat numbers are local UI state. Reservation creation sends a seat count, so the backend performs authoritative seat allocation.
- The client requests reservation lists separately for matching entrances while building the available-departure list. A station with many departures can therefore trigger multiple requests.
- Correct route/entrance association depends on the backend returning the nested vehicle and route IDs the client expects.
- The API URL is a source-code setting, not a build-time environment or flavor configuration.
- Google sign-in visuals are not connected to an authentication provider.
- Change-password and reset-password service operations are not represented by dedicated screens in the current screen list.
- The repository does not include the API service, database, schema management, or deployment setup.

## Contributing and quality checks

Keep UI rendering in screens/widgets, API calls in services, and screen-facing state in providers. When changing an endpoint or response shape, update the corresponding service/model and verify the affected flow against the backend contract.

The repository includes a basic widget test in `test/widget_test.dart` and uses `flutter_lints` through `analysis_options.yaml`. Useful local checks include:

```sh
flutter analyze
flutter test
```

Potential test areas include model parsing, API response/error mapping, provider state transitions, availability calculations, and the full station-to-reservation journey.

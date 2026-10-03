# Taxi Collectif Mobile App — Project Overview

## 1. What this project is

This repository contains the Flutter client for **Taxi Collectif**, a passenger-facing application for finding collective taxi departures and reserving seats. A signed-in passenger can browse stations, inspect the routes served by a station, view vehicle entrances/departures associated with a route, choose seats, and send a reservation to the backend. The app also includes account registration, sign-in, password recovery, profile, and a ride-history screen shell.

The client is written in Dart and uses Flutter's Material widgets. The application title and visible navigation labels are a mixture of English and French (for example, “Accueil” for home). The backend is a separate service: no server implementation is included in this repository. The client expects a JSON API and session cookies from that service.

## 2. User experience and main flows

### Startup and authentication

1. `main()` initializes Flutter bindings and starts `TaxiCollectifApp`.
2. `MultiProvider` creates the app-wide authentication, station, route/entrance, vehicle, and reservation state objects.
3. `SplashScreen` asks the authentication service for the current session using `GET /api/auth/me`.
4. If a user is returned, the app opens the main navigation shell; otherwise it opens sign-in.

The sign-in form accepts an email address or username. Registration collects an email, username, first and last name, phone number, and password. After creating an account, the app attempts to sign in automatically. If automatic sign-in fails, registration remains successful and the user is left unauthenticated so they can sign in manually. The forgot-password screen sends the email address to the password-reset request endpoint. The auth service also has methods for applying a reset token and changing an authenticated user's password, though these operations are not represented by a separate reset/change-password screen in the current screen list.

### Browse and reserve a trip

The main navigation has four tabs:

| Tab | Screen | Current purpose |
| --- | --- | --- |
| Accueil | `AccueilScreen` | Greeting, station preview, and navigation into station browsing. |
| Stations | `StationsListScreen` | Search and select a station. Search requests are debounced. |
| History | `HistoryPlaceholderScreen` | Placeholder empty state for past trips and reservations. |
| Profile | `ProfileScreen` | Displays account details and offers sign-out. |

Selecting a station opens `StationLinesScreen`. That screen loads routes and station entrances, associates entrances with routes using vehicle route IDs, and shows a route card with destination/description, fare, and a status label. Selecting a route opens `AvailableVehiclesScreen`, which filters station entrances to the selected route and excludes departed vehicles. It loads reservations for each entrance to estimate occupancy and remaining seats.

Selecting a departure opens `SeatReservationScreen`. The seat view is initialized with the vehicle capacity, occupied-seat count, and route fare. The provider supports selecting up to four seats, prevents selecting occupied seats, calculates the total price from seat count and fare, and submits the reservation. The backend request contains the entrance ID and number of seats. On success the app shows `ReservationSuccessDialog` with the resulting reservation information.

### Authentication/session behavior

The API client stores cookies through Dio's cookie manager. Native platforms use a persistent cookie jar under the app documents directory when that storage can be initialized; web uses an in-memory cookie jar. Logout calls the server and clears the local cookie jar even if the server request fails. When protected data requests report an unauthorized session, the browsing/reservation screens handle the provider's unauthorized flag by signing out and returning to sign-in.

## 3. Technical architecture

The code is organized by responsibility under `lib/`:

```text
lib/
├── main.dart                     App entry point and provider registration
├── config/
│   └── api_config.dart           Backend URL, endpoints, and timeouts
├── core/
│   ├── network/
│   │   ├── api_client.dart       Shared Dio client and cookie persistence
│   │   └── api_exception.dart    API/network error representation
│   ├── theme/
│   │   └── app_theme.dart        Shared color, typography, and input/button theme
│   └── utils/
│       └── validators.dart       Form field validation helpers
├── models/                       JSON models and screen view models
├── providers/                     ChangeNotifier application state
├── screens/                       Full-page UI and user flows
├── services/                      Backend API operations
└── widgets/                       Reusable form and social-login presentation widgets
```

### State and data flow

The app uses the `provider` package with `ChangeNotifier`. The five root providers are created in `TaxiCollectifApp`:

| Provider | Responsibility |
| --- | --- |
| `AuthProvider` | Session state, current user, sign-in, registration, logout, and password-reset request state. |
| `StationsProvider` | Station list, search query, loading/error state, and unauthorized-session state. |
| `StationLinesProvider` | Loads a station's routes and entrances and builds route-card view models. |
| `AvailableVehiclesProvider` | Loads route-matching entrances and reservation data, then builds departure view models. |
| `SeatReservationProvider` | Selected seats, capacity/availability, pricing, and reservation submission state. |

Screens generally read data through providers and call provider methods in response to lifecycle events or user input. Providers call service classes; services use the shared `ApiClient`; JSON maps are converted into model objects. This keeps widgets focused on rendering and user interaction while data loading and error state live in the providers.

### Services and models

The API services are `AuthService`, `StationService`, `RouteService`, `EntranceService`, and `ReservationService`. The associated domain models include `UserModel`, `StationModel`, `RouteModel`, `EntranceModel`, `VehicleModel`, `DriverModel`, `ReservationModel`, `ReservationSeatRefModel`, and `PaginationModel`. `StationLineCardVm` and `VehicleDepartureVm` adapt backend data into values convenient for the UI, such as labels, fare, departure time, occupancy, and whether a departure can be reserved.

Most model factories tolerate numeric values supplied as either numbers or strings and use defaults for missing optional fields. API collection services expect a response envelope with `success: true`, a `data` list, and optional `pagination`. Authentication responses use `data` as a user object.

## 4. Backend API contract used by the client

The configured API root is defined in [`lib/config/api_config.dart`](lib/config/api_config.dart). The default is `http://10.0.2.2:3000`, which addresses the host machine from an Android emulator. The client currently uses these endpoint paths:

| Operation | Method and path | Client behavior |
| --- | --- | --- |
| Sign in | `POST /api/auth/login` | Sends either `email` or `username`, plus `password`. |
| Register | `POST /api/users` | Sends passenger details and backend-required role/status values. |
| Current user | `GET /api/auth/me` | Reads the cookie-authenticated session. |
| Sign out | `POST /api/auth/logout` | Ends server session, then clears stored cookies. |
| Change password | `PATCH /api/auth/change-password` | Sends `currentPassword` and `newPassword`. |
| Request password reset | `POST /api/auth/forgot-password` | Sends `email` and a redirect URI. |
| Reset password | `POST /api/auth/reset-password` | Sends `token` and `newPassword`. |
| Stations | `GET /api/stations` | Supports `page`, `limit`, `search`, `governorate`, and `city`. |
| Routes | `GET /api/routes` | Supports `stationId`, `page`, `limit`, and `search`. |
| Entrances | `GET /api/entrances` | Supports `stationId`, `page`, `limit`, and `status`. |
| Reservations | `GET /api/reservations` | Supports `entranceId`, `page`, and `limit`. |
| Create reservation | `POST /api/reservations` | Sends `entranceId` and `numberOfSeats`. |

The client sends JSON with `Content-Type` and `Accept` headers and configures 15-second connection and receive timeouts. Dio is configured to return responses for all HTTP status codes so services can translate status/body data into `ApiException` instances themselves. Error parsing recognizes `message`, `error`, and field-level `errors`, and provides readable fallback messages for common status codes.

Registration currently sends `role: "Passanger"` (this spelling is intentional in the client because the backend is documented in code as requiring that exact value), `status: "active"`, and `stationId: null`. Reservation creation is by seat count; selected seat numbers are currently a UI representation and are not sent as individual numbers in the create request.

## 5. Configuration and local development

### Requirements

- Flutter SDK with a Dart SDK satisfying the constraint in `pubspec.yaml` (`^3.13.2`).
- A running compatible Taxi Collectif API backend.
- An emulator, simulator, browser, or physical device supported by the selected Flutter target.

### Install packages and run

From the repository root:

```sh
flutter pub get
flutter run
```

To build for a specific platform, use the corresponding Flutter command, such as `flutter build apk`, `flutter build ios`, or `flutter build web`, subject to that platform's local tooling and signing setup.

### Set the backend address

Edit `ApiConfig.baseUrl` in `lib/config/api_config.dart` to match the environment:

- Android emulator: `http://10.0.2.2:3000` (the current default).
- iOS simulator: use the host-accessible local address, typically `http://localhost:3000`.
- Physical device: use the development machine's reachable LAN IP and ensure both devices can reach the backend.

The service must allow the device to make HTTP requests. For production, configure a secure HTTPS endpoint and review platform network-security settings. This project does not currently load the API URL from a build flavor or environment file; it is a Dart configuration value.

### Dependencies

Runtime packages declared in `pubspec.yaml`:

- `dio` for HTTP requests.
- `cookie_jar` and `dio_cookie_manager` for session-cookie handling.
- `path_provider` for locating a native app documents directory used for persistent cookies.
- `provider` for `ChangeNotifier` state management.
- `google_fonts` for Inter typography and related UI text styling.
- `cupertino_icons` for Cupertino icon glyphs.

The development dependencies include `flutter_test` and `flutter_lints`. Flutter Material icons are enabled. No application asset or custom-font directories are currently declared in the Flutter section of `pubspec.yaml`.

## 6. Interface and reusable components

`AppTheme` defines the shared warm off-white background, yellow primary action color, dark text, muted text, rounded input fields, and rounded buttons. Typography is based on Inter through `google_fonts`. Screen layouts use standard Flutter Material widgets, with some Cupertino controls/icons used where they suit the design.

Reusable widgets currently include:

- `CustomTextField`: labelled form field, optional validation, keyboard configuration, change callback, and password visibility toggle.
- `CustomCheckbox`: styled checkbox row with a caller-supplied label.
- `SocialButton` and `GoogleLogo`: presentation for a “Continue with Google” option.

The social button is a UI component; this repository does not declare a Google sign-in/authentication SDK or show a backend OAuth flow connected to it.

## 7. Validation and error handling

`Validators` supplies form-level checks for email format, username character/length rules, required first and last names, a basic phone-number character/length check, password length (8–128 characters), password confirmation, and sign-in identifier format. These checks improve form feedback but do not replace backend validation.

Providers expose loading and error state to the screens. Station search waits about 300 milliseconds after typing before issuing a request. Station, route, entrance, and reservation loading errors are converted to visible messages; unauthorized responses are tracked separately to trigger reauthentication. Route/entrance loading is performed together. Entrance failure is treated as non-fatal in the station route list except for unauthorized responses, allowing configured routes to appear without live entrance status. In the vehicle list, reservation-fetch failure for an individual entrance is logged and that departure is still represented with an empty reservation list.

## 8. Current scope and known implementation boundaries

- Ride history is currently a placeholder empty state. Although reservations can be read by entrance to calculate availability, there is no user-facing reservation-history service/provider flow in the current UI.
- The passenger trip flow is implemented around browsing station → route → departure → seat selection → reservation submission.
- Seat numbers are selected and displayed locally; the create-reservation API call submits only a seat count. Backend reservation seat allocation is therefore authoritative.
- The client fetches reservation lists separately for each matching entrance when assembling available departures. This can result in multiple requests for a station with many departures.
- The route and entrance responses need to include enough nested vehicle/route data for the client-side joins described above.
- `ApiConfig.baseUrl` is a source-code setting with an emulator-oriented default; it should be switched for other environments.
- The project contains standard Flutter platform folders for Android, iOS, web, Windows, macOS, and Linux. The primary implemented product flow is not tied to only one platform, though network addressing and platform builds need environment-specific configuration.
- This repository contains only the mobile client; API deployment, database setup, and backend schema management are outside its scope.

## 9. Repository map

| Path | Contents |
| --- | --- |
| `lib/main.dart` | App entry point, root widget, provider setup, theme, and initial splash route. |
| `lib/screens/` | Splash, sign-in, registration, forgot-password, home, stations, route, vehicle, reservation, profile, navigation, and history placeholder UI. |
| `lib/providers/` | UI-facing state and operations built on `ChangeNotifier`. |
| `lib/services/` | API requests and response parsing. |
| `lib/models/` | Domain JSON models and display-oriented view models. |
| `lib/core/network/` | Shared HTTP/cookie client and API exception mapping. |
| `lib/config/` | Base URL, endpoint constants, and timeout values. |
| `lib/core/theme/` | Shared visual design tokens and Material theme. |
| `lib/core/utils/` | Reusable form validators. |
| `lib/widgets/` | Shared form controls and social-login visual elements. |
| `test/widget_test.dart` | A basic widget test that pumps the app and checks the splash title. |
| `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` | Flutter platform runners and platform-specific configuration. |

## 10. Quality checks and future work

The repository includes a single basic widget test in `test/widget_test.dart` and uses the standard Flutter lint set through `analysis_options.yaml`. A practical next step for development is to add tests around model parsing, API response/error mapping, provider state transitions, seat availability calculations, and the station-to-reservation flow. Other natural follow-ups include implementing the ride-history screen, connecting or removing the Google sign-in presentation, moving backend URLs into per-environment configuration, and deciding whether seat allocation should expose selected seat numbers in the backend API.


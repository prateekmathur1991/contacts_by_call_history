# Copilot / Agent Instructions — contacts_by_call_history

Purpose: give coding agents the minimum, actionable knowledge to be productive in this Flutter repo.

Quick context
- This is a Flutter app (root entry: `lib/main.dart`) that ranks phone contacts by call history.
- Core idea: merge device call logs and contacts, normalize phone numbers, count calls per contact, and show least-used contacts.

Key files & locations
- `lib/main.dart` — app entry and MaterialApp config.
- `lib/home_page.dart` — primary logic: requests permissions, reads contacts and call logs, normalizes numbers with `dlibphonenumber`, builds `ContactHistoryWrapper` list, sorts ascending, and renders with a `FutureBuilder`.
- `lib/contact_history_wrapper.dart` — small DTO storing a `flutter_contacts` `Contact` and an integer `callCount`.
- `pubspec.yaml` — important dependencies: `call_log`, `flutter_contacts`, `permission_handler`, `dlibphonenumber`, plus `flutter_lints` for style.
- Platform folders: `android/`, `ios/`, `windows/`, `macos/` — native plugin code and platform builds live here.

Architecture & data flow (concise)
- At runtime `HomePage` calls `fetchContactsWithCallHistory()` which:
  - requests contacts permission via `permission_handler`;
  - calls `FlutterContacts.getContacts(withProperties: true, withPhoto: true)`;
  - calls `CallLog.get()` to fetch call records;
  - uses `PhoneNumberUtil.instance` (from `dlibphonenumber`) to parse/format phone numbers to E.164 for matching;
  - builds a `Map<String,int>` of call counts keyed by normalized phone number and aggregates per contact;
  - returns a sorted `List<ContactHistoryWrapper>` (least-used first) used by the UI.

Project-specific conventions & important patterns
- Phone parsing: country code is hard-coded as `'IN'` in parsing calls. Preserve this assumption unless explicitly changing normalization logic — flag it in PRs because it affects matching.
- Error handling: number parse errors are intentionally swallowed (caught `NumberParseException`) — maintain this pattern or explicitly surface parse failures with comments.
- Permissions: permission denial results in an exception from `fetchContacts()`; UI presently shows the exception text. Consider adding a user-facing permission flow if changing behavior.
- UI: uses `FutureBuilder` (not provider/state management in current UI) — avoid introducing global state unless implemented consistently across screens.

Build / run / dev workflows (verified from repo)
- Get dependencies: `flutter pub get`.
- Debug locally via VS Code Flutter extension or: `flutter run` (specify device with `-d`).
- Build Android release (documented in repo README):

  flutter pub get
  flutter build apk --release

- Tests & analysis: repo includes `flutter_test` and `analysis_options.yaml` with `flutter_lints` — run `flutter analyze` and `flutter test` before PRs.

Integration & native considerations
- The app depends on platform plugins that require platform builds to validate (call_log, flutter_contacts, permission_handler). Changes to native code under `android/` or `ios/` must be validated by building the corresponding platform.
- Many generated artifacts appear under `build/` — do not commit build outputs.

When editing code, look for these concrete examples to follow
- To change normalization or parsing: edit `lib/home_page.dart` where `PhoneNumberUtil.instance.parse(..., 'IN')` and `.format(..., PhoneNumberFormat.e164)` are used.
- To change display or list behavior: update `ListView.builder` / `ListTile` in `lib/home_page.dart`.
- To add fields to the DTO: update `lib/contact_history_wrapper.dart` and call sites in `home_page.dart`.

> Agent rules (practical, repository-specific)
- Do not modify native platform folders without a platform build verification step (add a note in PR explaining how you validated it).
- Preserve the current phone normalization country code (`'IN'`) unless the change includes tests or a config option.
- Keep parse exceptions local (continue to catch `NumberParseException`) unless you add user-visible error handling.
- Run `flutter analyze` and `flutter test` locally; include commands and outputs in PR description when possible.

What I couldn't infer (ask the human)
- Preferred CI workflow (which platforms to build in CI), release tagging, and whether to support other locales by default.

If anything here is unclear or you want additional sections (CI steps, changelog rules, PR checklist), tell me which to expand and I will iterate.

# PawPal

PawPal is an Android-first, light-only pet-care organizer for dog and cat households. It is designed to keep personal pet information on the device and remain useful without an account.

## Implemented in this foundation

- Five primary destinations: Home, Discover, My Pets, Saved and Settings.
- Multiple local pet profiles with add/edit/delete, species, breed/mix, birthday, weight and notes.
- Local persistence using SharedPreferences JSON snapshots, with a schema version.
- Pet switching and a pet-specific home dashboard.
- User-created care reminders with task type, due date/time and basic repeat labels.
- Complete/reopen reminders and remove reminders.
- Owner-entered care timeline entries for weight, feeding, activity, grooming, training, behavior, vet visits, vaccination, preventive care and medication administration.
- JSON backup preview from Settings.
- Light-only Material 3 visual foundation and basic accessibility-friendly labels/controls.
- Educational and privacy disclaimers.

## Architecture and privacy

Flutter + Riverpod. Personal profiles, reminders and logs are persisted locally. There is no login, backend, Firebase, cloud sync or personal-data upload. Discover currently contains bundled starter topic cards; the public read-only GitHub editorial manifest/cache integration is not yet connected.

## Important implementation status

This commit is the first functional foundation, not the complete product plan. The following planned systems still need implementation before a release: SQLite/Drift migrations and transactional backup restore; robust recurrence and Android local notifications; record vault attachments; feeding/activity-specific forms and summaries; reusable checklists; editable emergency/contact cards and verified US resources; sitter handoff preview/export; search, breed directory, favorites/collections/reading history; GitHub manifest validation/checksums/atomic updates; content editorial metadata; full localization, accessibility and QA coverage; and consent-aware ads (only on approved non-critical browse surfaces). No medical advice, dosage or diagnosis features should be added.

## Run

- flutter pub get
- flutter analyze
- flutter test
- flutter run

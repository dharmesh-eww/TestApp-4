# PawPal

PawPal is an Android-first, light-only pet-care organizer for dog and cat households. It is designed to work without an account and keep personal pet information on the device.

## Project structure

The app follows the feature-first organization used in TestApp-3. `main.dart` only initializes the database and starts the app.

```text
lib/
  app/                       # App widget and navigation shell
  core/
    data/                    # SQLite database, repository, legacy migration
    domain/                  # Shared pet and care entities
    providers/               # Riverpod app state
    services/                # Notifications and private attachments
    theme/                   # Light-only design tokens and theme
  features/
    activity/                # Activity journal
    breeds/                  # Breed directory
    care/                    # Reminders, calendar, timeline and recurrence
    checklists/               # Reusable care checklists
    contacts/                 # Vet, caregiver and emergency resources
    discover/                 # Article catalog and GitHub content updater
    feeding/                 # Feeding journal
    home/                    # Dashboard
    onboarding/              # Local-first setup
    pets/                    # Pet list, profile and editor
    records/                 # Health record organizer and attachments
    saved/                   # Favorites, collections and reading history
    settings/                # Preferences, privacy, backups and content updates
    sharing/                 # Pet-sitter handoff
    training/                # Reward-based lesson starters
  shared/widgets/             # Reusable UI components
assets/content/               # Bundled offline starter content
test/                         # Widget and domain tests
```

## Implemented

- Material 3 light-only UI and five main destinations: Home, Discover, My Pets, Saved and Settings.
- Skippable onboarding, US customary defaults and configurable weight, distance and temperature units.
- SQLite local database, repository layer, schema versioning and one-time migration from the first SharedPreferences JSON store.
- Multiple pet profiles with add/edit/archive/restore/permanent-delete, profile details and private pet photos.
- Pet-specific home dashboard with overdue, today and upcoming reminders, activity summaries and quick actions.
- Care reminders with once, daily, weekly, selected-weekday, monthly and every-N-days rules; month-end policy; edit, pause, snooze, skip, completion and history.
- Android local notifications with contextual permission request, device timezone handling, reboot rescheduling, and configurable quiet hours. Notifications use inexact scheduling; Android battery controls can still delay delivery.
- Care timeline, feeding journal, activity journal and owner-entered health-record organizer.
- Private photo/PDF attachments for health records. Attachment bytes remain in app-private storage.
- Editable local veterinarian, emergency-clinic and caregiver contacts.
- US poison-control resource links and phone numbers, with provider details and a verification date shown in-app. Verify coverage and fees with providers.
- Reusable starter checklists with custom items and completion state.
- Searchable bundled guide catalog, article details, species filters, favorites and reading history.
- Starter dog/cat breed list and step-by-step positive-reinforcement lesson ideas.
- Local collections and a review-before-share pet-sitter handoff.
- Versioned JSON export, validated merge/replace import, transactional SQLite restore, v1 backup conversion and pre-restore local backup.
- Local data and cache deletion controls.
- HTTPS-only, SHA-256-verified GitHub content-pack updater with allowlisted paths, file-size limits, staging and last-known-good activation.

## Privacy and safety boundaries

- No login, account, backend, Firebase, analytics or cloud sync.
- Pet data is not sent to GitHub. GitHub is used only for public, read-only editorial JSON when a manifest URL is configured.
- Photos and attachments are stored locally. JSON backups intentionally omit attachment bytes and local file paths.
- Medication entries are owner-entered only. PawPal does not suggest medication doses, diagnoses, treatment or vaccination schedules.
- Editorial starter guides are marked `editorial_review_required`. They are not veterinary-reviewed advice.
- No ads are included. Ad monetization remains disabled until consent, privacy, legal and placement requirements are implemented and configured.

## Configure public content updates

The app currently ships with bundled starter articles. To enable remote editorial updates, create a public GitHub repository containing `manifest.json` and the listed JSON files, then build with:

```sh
flutter build apk --release \
  --dart-define=PAWPAL_CONTENT_MANIFEST_URL=https://raw.githubusercontent.com/OWNER/REPOSITORY/main/manifest.json
```

See [docs/content-manifest.md](docs/content-manifest.md) for the manifest contract, validation rules and article schema. No content repository URL is hard-coded into the app.

## Run and verify locally

```sh
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
```

The repository does not currently include a GitHub Actions workflow; it was intentionally left absent after the earlier project-creation workflow was removed. Run the commands above locally or add a separate Android build workflow when requested.

## Remaining release work

- Connect and populate the production public content repository.
- Expand the starter guide and breed catalogs to the planned breadth, with citations, editorial owners and qualified veterinary review for health/safety topics.
- Complete manual accessibility, screen-reader, text-scaling, localization and device-compatibility QA.
- Test notification delivery across Android API levels, OEM battery restrictions, timezone changes and reboot on physical devices.
- Decide and implement attachment backup/export policy; the current JSON backup excludes attachment bytes.
- Review privacy policy, terms, data-retention copy and emergency resource availability before public release.
- Ads are intentionally out of scope until a consent-compliant provider and approved placements are configured.


# PawPal public content manifest

PawPal can optionally fetch public editorial JSON from a GitHub raw-content URL. The app does not authenticate, write to GitHub, send pet data, or upload device identifiers.

## Configure the app

Build with a manifest URL that points to a public file on `raw.githubusercontent.com`:

```sh
flutter build apk --release \
  --dart-define=PAWPAL_CONTENT_MANIFEST_URL=https://raw.githubusercontent.com/OWNER/REPOSITORY/main/manifest.json
```

If the define is omitted, PawPal continues to use the bundled offline starter guides.

## Manifest schema

The manifest must be a JSON object with `schema_version: 1`, a non-empty `content_version`, and a `files` array. Each file entry has:

- `path`: relative JSON path under one of `categories/`, `articles/`, `breeds/`, `training/`, or `safety/`.
- `sha256`: lowercase or uppercase SHA-256 hex digest of the exact file bytes.
- `size_bytes`: exact byte length.

Example shape (replace the placeholder digest and size with real values):

```json
{
  "schema_version": 1,
  "content_version": "2026.11.18.1",
  "files": [
    {
      "path": "articles/index.json",
      "sha256": "REPLACE_WITH_64_HEX_CHAR_SHA256",
      "size_bytes": 1234
    }
  ]
}
```

## Runtime validation

- HTTPS only; host must be `raw.githubusercontent.com`.
- Redirects to a different host are rejected.
- Manifest maximum: 256 KiB; maximum 80 files.
- Each JSON file maximum: 1 MiB; complete pack maximum: 8 MiB.
- Paths are allowlisted, traversal segments and duplicate paths are rejected.
- File size and SHA-256 must match the manifest.
- Files must parse as JSON objects.
- Files are staged in app-private storage and only activated after all downloads validate. A failed update leaves the previous active pack untouched.

## Article index

The current app reads `articles/index.json` with `schema_version: 1` and an `articles` array. Each article includes:

- `id`, `title`, `summary`
- `species`, `tags`, `reading_minutes`
- `review_status`, `reviewer`, `reviewed_at`, `updated_at`, `safety_level`
- `body_blocks`: an array of `paragraph`, `heading`, or `callout` blocks with a `text` field.

Starter articles are explicitly marked `editorial_review_required`. Do not mark medical or safety content as reviewed unless the named qualified reviewer has actually reviewed it. Include sources and review metadata in the editorial workflow before publishing production content.

## Privacy

Only public content files are requested. No pet profiles, names, photos, records, reminders, notes, favorites, contacts or backup data are sent to the content host.


# Local Storage Lab — Flutter & SQLite

**Mobile Application Development | In-Class Activities 08 & 09 | Section 2**

**Student:** Akshitha Sainath Sanagarapu  
**Student ID:** 003027780  
**Pathway:** Graduate  
**Project:** `local_storage_lab`

## 1. Project Overview

This Flutter application demonstrates local data persistence using SQLite.

Activity 08 introduced the Fall Festival Roster, which stores guest records in a local SQLite database. Activity 09 extends the same application with a Card Catalogue containing folders and cards.

The main objective is to add a relational database structure without losing the original Activity 08 records.

The application provides two features:

- **Fall Festival Roster:** Create, read, update, and delete fictional guest records.
- **Card Catalogue:** Create folders, organize cards by folder, edit cards by ID, and delete cards or folders.

## 2. Development Environment

| Component | Details |
|---|---|
| Flutter | 3.47.2 (stable) |
| Dart | 3.13.2 |
| IDE | Visual Studio Code |
| Operating system | macOS |
| Test device | Pixel 10 Android Emulator |
| Android version | Android 17, API 37 |
| Database | SQLite |
| Packages | sqflite, path_provider, path |
| Pathway | Graduate |

### Setup and Run

Open the project directory and run:

```bash
flutter pub get
flutter devices
flutter run -d emulator-5554
```

The emulator ID may differ on another machine.

### Static Analysis

```bash
mkdir -p evidence
flutter analyze 2>&1 | tee evidence/analysis_output.txt
```

### Release APK

```bash
flutter build apk --release
```

Flutter generates the APK at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The submission copy is named:

```text
Activity09_Sanagarapu_Akshitha.apk
```

The release APK was built successfully and installed on the Pixel 10 emulator using `adb install -r`. Installation returned `Success`. A separate confirmation of the release application's screens and data is still needed to complete the smoke test.

## 3. Project Structure

| File | Responsibility |
|---|---|
| `lib/main.dart` | Home navigation and Activity 08 roster |
| `lib/database_helper.dart` | SQLite initialization, versioning, and roster operations |
| `lib/folder.dart` | Folder model |
| `lib/card_record.dart` | CardRecord model |
| `lib/catalogue_repository.dart` | Folder and card database operations |
| `lib/catalogue_screen.dart` | Card Catalogue interface and dialogs |
| `pubspec.yaml` | Dependencies and Flutter configuration |
| `pubspec.lock` | Resolved dependency versions |
| `README.md` | Setup, architecture, tests, evidence, and limitations |
| `evidence/` | Screenshots and analyzer output |

The Card Catalogue uses a repository layer to separate SQLite operations from Flutter interface widgets.

## 4. Database Architecture

### Existing Database

**Database filename:** `MyDatabase.db`

**Activity 08 schema version:** 1  
**Activity 09 schema version:** 2

The version-2 database contains three application tables:

- `my_table`
- `folders`
- `cards`

### Original Guest Table

The existing `my_table` stores Activity 08 guest records.

| Column | Type | Purpose |
|---|---|---|
| `_id` | INTEGER PRIMARY KEY | Guest identity |
| `name` | TEXT | Guest name |
| `age` | INTEGER | Guest age |

The original table is retained during the version-2 migration.

### Folders Table

The `folders` table contains:

| Column | Type |
|---|---|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT |
| `name` | TEXT NOT NULL UNIQUE |
| `created_at` | TEXT NOT NULL |

Each folder has a unique ID and can contain multiple cards.

### Cards Table

The `cards` table contains:

| Column | Type |
|---|---|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT |
| `title` | TEXT NOT NULL |
| `suit` | TEXT NOT NULL |
| `notes` | TEXT NOT NULL DEFAULT '' |
| `image_ref` | TEXT, nullable |
| `folder_id` | INTEGER NOT NULL |

The relationship is defined using:

```sql
FOREIGN KEY (folder_id)
REFERENCES folders(id)
ON DELETE CASCADE
```

An index on `cards(folder_id)` supports folder-filtered queries.

### Relationship

```text
Folder
  |
  +-- Card 1
  +-- Card 2
  +-- Card 3
```

Each card belongs to one folder through its `folder_id`.

The schema uses `ON DELETE CASCADE` because cards are treated as children of their folders. Deleting a folder is intended to remove its associated cards.

In applications containing billing records, audit logs, or other records requiring retention, restricting deletion, reassignment, or soft deletion would be safer alternatives.

### Versioned Migration

The original application used database version 1.

Activity 09 increases the version to 2 and adds the new tables without dropping `my_table`.

The database helper provides:

- An `onCreate` path for creating the complete schema on a fresh installation.
- An `onUpgrade` path for adding the catalogue schema to an existing version-1 database.
- Foreign-key configuration on the database connection.

The upgraded installation retained its original guest records. A separate disposable fresh-install test and read-only PRAGMA verification remain outstanding.

## 5. Models and Repository

The application uses typed `Folder` and `CardRecord` models.

The models convert between SQLite rows and Dart objects using mapping methods.

The repository provides database operations for:

- Creating folders.
- Reading folders with card counts.
- Reading cards belonging to a selected folder.
- Creating cards.
- Updating cards by ID.
- Deleting cards by ID.
- Deleting folders by ID.

Card queries use the selected folder's integer ID rather than its name or screen position.

Database-generated IDs are important because multiple cards can have the same title.

## 6. Application Features

### Fall Festival Roster

The original Activity 08 interface supports:

- Adding guests.
- Viewing guest names, ages, and IDs.
- Editing guests by ID.
- Canceling edits.
- Deleting records with confirmation.
- Refreshing the roster.
- Validating names and ages.

The age range accepted by the original application is 0 through 130.

### Card Catalogue

The Activity 09 interface supports:

- Creating folders.
- Displaying folders and card counts.
- Opening a folder to view its cards.
- Adding cards with a title, suit, notes, and optional image URL.
- Editing existing cards.
- Selecting a card's folder.
- Deleting cards by ID.
- Deleting folders with confirmation.
- Showing empty-state feedback.
- Displaying a suit-symbol fallback when artwork is missing or unavailable.

### Input Validation

The interface validates required fields before saving.

A card title containing only whitespace is rejected.

Folder names are intended to be nonempty after trimming, and the database schema enforces unique folder names.

The duplicate-folder and blank-folder validation cases have not yet been separately recorded as completed manual tests.

### Image Handling

The application stores an optional image reference rather than embedding image bytes in the database.

For this implementation, image references are URLs.

A remote URL keeps the database small, but artwork may be unavailable because of network failures or invalid links.

When an image reference is missing or cannot be loaded, the card displays its suit symbol:

- Hearts: ♥
- Diamonds: ♦
- Clubs: ♣
- Spades: ♠

An unavailable image does not require deleting the card or its notes.

## 7. Activity 08 Data Preservation

The original roster records observed after upgrading were:

| Guest ID | Name | Age |
|---|---|---|
| 2 | River | 35 |
| 3 | Acorn | 0 |
| 4 | Oak | 130 |

**Observed result:** All three records remained visible with their original IDs and values after Activity 09 was installed.

This supports successful preservation on the tested upgraded installation.

The available Activity 09 migration screenshot was captured after the upgrade. It is not a substitute for a screenshot captured before migration.

## 8. Activity 09 Test Matrix

The following table distinguishes completed observations from unverified portions of the prescribed tests.

| Test | Expected result | Actual observation | Status |
|---|---|---|---|
| T1a: Upgrade | Original records remain; new catalogue available | River ID 2, Acorn ID 3, and Oak ID 4 remained visible; catalogue opened | PASS for observed upgrade |
| T1b: Fresh install | Complete version-2 schema created on a disposable fresh target | Not separately tested | NOT VERIFIED |
| T2: Create | Atlas has two Compass cards; Harbor has one Signal card | Atlas contained Compass IDs 1 and 2; Harbor contained Signal ID 3 | PASS |
| T3: Edit | Editing one ID leaves the other unchanged; Cancel writes nothing | ID 1 changed; ID 2 remained unchanged | PARTIAL — edit cancellation not verified |
| T4: Restart | Records persist after an Android system Force stop and relaunch | Records were observed after stopping and relaunching the app | PARTIAL — exact Force stop procedure not documented |
| T5: Delete | Cancel leaves records unchanged; card deletion and Atlas cascade work | Compass ID 2 deleted; Harbor removed through folder deletion workflow | PARTIAL — different folder deleted; cancel and direct cascade checks not verified |
| T6: Validation | Invalid inputs do not create records; missing artwork uses fallback | Blank card title rejected; invalid URL displayed suit symbol | PARTIAL — blank and duplicate folder tests not verified |

### T1 — Upgrade and Data Preservation

The existing Activity 08 database was extended from version 1 to version 2.

After the upgrade, the original roster displayed:

| ID | Name | Age |
|---|---|---|
| 2 | River | 35 |
| 3 | Acorn | 0 |
| 4 | Oak | 130 |

The Card Catalogue was accessible.

**Observed outcome:** The original guest records were preserved on the upgraded installation.

**Not yet verified:** Fresh-install schema creation, `PRAGMA user_version`, `PRAGMA foreign_keys`, `PRAGMA foreign_key_list(cards)`, and `PRAGMA index_list(cards)`.

### T2 — Folder and Card Creation

Two folders were created:

- Atlas
- Harbor

Three cards were added:

| Card ID | Title | Suit | Folder |
|---|---|---|---|
| 1 | Compass | Hearts | Atlas |
| 2 | Compass | Spades | Atlas |
| 3 | Signal | Diamonds | Harbor |

**Expected:** Atlas count 2; Harbor count 1; three distinct card IDs.

**Observed:** The folders displayed the expected cards and counts. The two Compass cards received separate IDs despite sharing a title.

**Result:** PASS.

### T3 — Editing by Identity

Card ID 1 was edited:

| Field | Before | After |
|---|---|---|
| Title | Compass | Compass Updated |
| Suit | Hearts | Clubs |
| Notes | Empty | Edited first Compass card |

Card ID 2 remained Compass with the Spades suit.

**Expected:** Only the selected card changes.

**Observed:** Card ID 1 displayed its updated values while card ID 2 remained unchanged.

**Result:** PASS for targeted editing. The separate edit-and-cancel subtest was not verified.

### T4 — Restart Persistence

After editing, the application was stopped and relaunched on the same emulator without clearing its data.

The following cards were observed:

| ID | Title | Suit | Folder |
|---|---|---|---|
| 1 | Compass Updated | Clubs | Atlas |
| 2 | Compass | Spades | Atlas |

The edited values and IDs remained available.

**Observed result:** Data persisted across the recorded relaunch.

**Limitation:** The exact Android system **App info → Force stop** procedure was not documented, so the stricter assignment-specific cold-restart test remains unverified.

### T5 — Deletion

**Individual card deletion:**

Compass ID 2 was deleted.

Compass Updated ID 1 remained in Atlas.

**Folder deletion:**

Harbor was deleted after previously containing Signal ID 3.

Harbor disappeared from the folder list, while Atlas remained.

**Observed result:** The interface reflected the individual card deletion and folder deletion.

**Limitations:**

- The prescribed test specifies deleting Atlas and retaining Harbor, whereas the performed test deleted Harbor.
- Delete-cancellation cases were not separately confirmed.
- Direct SQL verification of cascading child deletion was not recorded.
- The observed UI state alone does not establish the exact database-level deletion mechanism.

### T6 — Validation and Image Fallback

**Blank title test:**

An attempt was made to save a card without a title.

The application displayed:

```text
Title cannot be empty
```

No new card was created.

**Invalid image reference test:**

A temporary card was created with:

| Field | Value |
|---|---|
| Title | Image Test |
| Suit | Diamonds |
| Folder | Atlas |
| Image URL | `https://example.invalid/missing.png` |

The card displayed the Diamonds fallback symbol without crashing.

**Observed result:** PASS for the blank-title and invalid-image cases.

**Not yet verified:** Separate blank-folder and duplicate-folder-name validation tests.

### Final Test Data Cleanup

The following temporary records were removed:

- Compass ID 2.
- Harbor and its associated Signal card through the folder deletion workflow.
- Image Test.
- Test Folder.

The final observed Card Catalogue state was:

| Folder | Card | Card ID | Suit |
|---|---|---|---|
| Atlas | Compass Updated | 1 | Clubs |

## 9. Evidence Inventory

The following files were confirmed as tracked by Git:

| File | Description |
|---|---|
| `evidence/activity09/T1_migration.png` | Original guest records observed after the version-2 upgrade |
| `evidence/activity09/T2_folders.png` | Later catalogue state showing Atlas with one remaining card |
| `evidence/activity09/T4_after.png` | Catalogue after relaunch, including Compass Updated ID 1 |
| `evidence/T4_before.png` | Earlier Activity 08 screenshot |
| `evidence/T4_after.png` | Earlier Activity 08 screenshot |
| `evidence/T6_invalid.png` | Previously captured invalid-input evidence |
| `evidence/analysis_output.txt` | Saved Flutter analyzer output |

### Required Evidence Not Fully Available

The official assignment requests:

1. `evidence/T1_before.png` — captured before upgrading the original database.
2. `evidence/T2_cards.png` — showing the T2 catalogue state.
3. `evidence/T4_after.png` — showing the Activity 09 post-restart state.

The current repository does not contain genuine screenshots under all three required root-level filenames.

In particular:

- `T1_migration.png` was captured after the upgrade and cannot establish the pre-upgrade state.
- `T2_folders.png` shows a later catalogue state, not the original two-folder, three-card T2 setup.
- The Activity 09 post-relaunch screenshot is under `evidence/activity09/`, and the precise system Force stop procedure has not been verified.

These limitations are disclosed rather than presenting unrelated screenshots as evidence of tests that were not captured.

### Static Analysis

The recorded analyzer output was:

```text
Analyzing local_storage_lab...
No issues found! (ran in 0.9s)
```

**Result:** PASS for static analysis.

Static analysis checks Dart and Flutter code but does not prove database migration correctness or runtime behavior.

## 10. Database Design Decisions

### Why Use Integer IDs?

Names and titles are not reliable row identifiers.

Two cards named Compass were created with different IDs.

Editing ID 1 did not change ID 2.

This supports using primary keys for updates and deletes.

### Why Use Foreign Keys?

A card's `folder_id` identifies its parent folder.

This allows the application to retrieve only the cards belonging to a selected folder and provides a defined relationship between parent and child rows.

### Why Use Cascading Deletion?

For this fictional card catalogue, deleting a folder is intended to delete its associated cards.

For records that must be retained, such as clinic billing or audit history, cascading deletion could cause unacceptable data loss.

Alternatives include:

- `ON DELETE RESTRICT` to prevent deleting a parent with children.
- Soft deletion to retain records while hiding them from active views.
- Reassignment to a different parent.
- A transactional snapshot-and-restore mechanism for limited undo.

### Why Store Image References?

A URL is smaller than storing image bytes inside SQLite.

However, remote images depend on network availability and the continued validity of the URL.

The application keeps the card usable by displaying a suit-symbol fallback when artwork cannot be loaded.

## 11. Graduate Reflection and AI Alchemist's Lab

The separate Critical Thinking document is intended to contain:

- Student name, student ID, and Graduate pathway.
- Prompt 1: Failure reconstruction.
- Prompt 2: Delete policy trade-off.
- Prompt 3: Image forensics.
- Prompt 4: Version-3 migration design.
- Graduate AI Lab G1: Migration time-loop.
- Graduate AI Lab G2: Cascade bargain.
- Personal test observations and evidence references.
- AI assistance disclosure.

### Graduate Prompt 4 — Version-3 Design Scope

The version-3 migration is a design exercise, not an implemented application feature.

The proposed change adds:

- A favorite flag with a safe default for existing rows.
- A nullable review date.

A complete design should explain migration version gates, defaults or backfill, transaction behavior, failure recovery, and old-database and fresh-install tests.

No version-3 migration has been implemented as part of this Activity 09 submission.

### G1 — Migration Time-Loop

The selected challenge evaluates the claim that a migration error can be caught and ignored while missing tables are recreated later.

The safer approach is to preserve transactional migration behavior, propagate failures, and verify database invariants before allowing normal application operations.

A fault-injection test on a disposable database is a proposed future verification, not a completed test.

### G2 — Cascade Bargain

The selected challenge evaluates the claim that undoing folder deletion only requires reinserting the folder name.

Restoring the name alone does not necessarily restore deleted cards, original IDs, foreign-key references, or related metadata.

The design compares restricted deletion, soft deletion, and snapshot-based undo, including consistency and retention trade-offs.

No undo feature has been implemented or tested.

**Note:** The complete graduate answers must be verified in the separately submitted Critical Thinking DOCX. This README describes the selected topics but does not replace that document.

## 12. Known Limitations

- Data is stored locally on the installed device.
- There is no cloud synchronization.
- There is no user authentication or database encryption.
- Image URLs may become unavailable.
- A separate disposable fresh-install schema test remains outstanding.
- Read-only PRAGMA verification has not been recorded.
- Direct SQL verification of cascading deletion has not been recorded.
- Some required T3, T5, and T6 cancellation/validation cases remain unverified.
- The recorded restart does not document the exact Android system Force stop procedure.
- Some required pre-test screenshots were not captured or are not available in the tracked evidence.
- Release APK installation succeeded, but an independent screen/data smoke-test confirmation remains outstanding.

## 13. Attribution and AI Assistance

The original SQLite helper and Activity 08 foundation were developed using the course-provided materials.

The project uses Flutter, Dart, SQLite, and the `sqflite`, `path_provider`, and `path` packages.

**ChatGPT assisted with implementation planning, debugging, and test planning.**

Assistance also included organizing the repository documentation and reviewing the assignment requirements.

The separately submitted graduate reflection should identify the AI tool/model, date, relevant prompt, short response excerpt, and the claim evaluated against actual application evidence.

Only personally observed tests are reported as completed. Proposed tests and hypothetical outcomes are identified separately.

## 14. GitHub Repository

**Activity 09 repository:**

https://github.com/AkshithaSanagarapu/local-storage-part-2

The Activity 09 implementation was committed with:

```text
3880f10 — Complete Activity 09 SQLite Card Catalogue
```

The `main` branch was pushed to the Activity 09 repository.

The original Activity 08 repository was retained separately.

The release APK and iCollege submission files are not required to be committed to the source repository.

## 15. Final Submission Checklist

### Completed

- [x] Preserve the observed Activity 08 guest records after upgrading.
- [x] Implement version-2 folder and card schema.
- [x] Implement Folder and CardRecord models.
- [x] Implement repository-based folder/card operations.
- [x] Implement Card Catalogue screens and forms.
- [x] Create Atlas and Harbor folders.
- [x] Create duplicate-title Compass cards with distinct IDs.
- [x] Edit one card by ID without changing the other.
- [x] Observe saved card data after relaunch.
- [x] Delete an individual card.
- [x] Delete a folder through the application.
- [x] Reject a blank card title.
- [x] Display fallback artwork for an invalid URL.
- [x] Run `flutter analyze` successfully.
- [x] Build a release APK.
- [x] Install the release APK successfully.
- [x] Push the Activity 09 source to GitHub.
- [x] Create `github_link.txt`.
- [x] Rename the APK to `Activity09_Sanagarapu_Akshitha.apk`.

### Remaining Verification and Submission

- [ ] Confirm that the installed release APK opens and displays the expected data.
- [ ] Verify the fresh version-2 database on a separate disposable target.
- [ ] Record read-only database schema and foreign-key diagnostics.
- [ ] Verify the cascade rule directly using disposable test records.
- [ ] Confirm remaining cancellation and validation cases.
- [ ] Perform and document an Android system Force stop and relaunch.
- [ ] Supply genuine required evidence screenshots if available.
- [ ] Verify the final graduate Critical Thinking DOCX.
- [ ] Commit and push this corrected README.
- [ ] Upload all three required files to iCollege.
- [ ] Reopen and verify each uploaded submission.

## 16. iCollege Submission Files

Submit three separate files:

| File | Purpose |
|---|---|
| `github_link.txt` | Link to the Activity 09 GitHub repository |
| `Activity09_Sanagarapu_Akshitha.apk` | Release Android application |
| `Sanagarapu_Akshitha_CriticalThinking.docx` | Graduate reflection and AI Lab |

The repository contains the Flutter project, database implementation, README, and available evidence.

The submission APK was successfully built and installed. Installation alone does not establish completion of the release smoke test.

**Project status:** The Activity 09 application is implemented, committed, and pushed. The release APK is built and installed. Remaining test and evidence limitations are documented so that completed observations are not confused with unverified requirements.

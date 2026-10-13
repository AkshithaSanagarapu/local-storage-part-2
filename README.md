
# Local Storage Lab — Flutter & SQLite

**Mobile Application Development | In-Class Activities 08 & 09 | Section 2**

**Student:** Akshitha Sainath Sanagarapu  
**Student ID:** 003027780  
**Pathway:** Graduate  
**Project:** `local_storage_lab`

## 1. Project Overview

This Flutter application demonstrates local data persistence using SQLite.

Activity 08 implemented a Fall Festival Roster for managing guest records. Activity 09 extends the existing application with a Card Catalogue that supports folders, cards, relational data, and database migration.

The primary objective of Activity 09 is to upgrade the SQLite database from version 1 to version 2 without losing the original Activity 08 records.

The application provides two features:

- **Fall Festival Roster:** Create, view, edit, and delete guest records.
- **Card Catalogue:** Create folders, manage cards, edit records by ID, and delete cards or folders.

## 2. Development Environment

| Component | Details |
|---|---|
| Flutter | 3.47.2 (stable) |
| Dart | 3.13.2 |
| IDE | Visual Studio Code |
| Operating system | macOS |
| Original test emulator | Pixel 10 |
| Disposable test emulator | Activity09_Test |
| Android | API 37 |
| Database | SQLite |
| Packages | sqflite, path_provider, path |
| Pathway | Graduate |

### Setup and Run

```bash
flutter pub get
flutter devices
flutter run
```

Select an available emulator when prompted.

### Static Analysis

```bash
flutter analyze
```

**Verified result:**

```text
Analyzing local_storage_lab...
No issues found!
```

### Build Release APK

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The submission APK is named:

```text
Activity09_Sanagarapu_Akshitha.apk
```

The release APK was successfully built and installed on the Android emulator.

A debug APK was also built for inspection of the SQLite database on a separate disposable emulator.

## 3. Project Structure

| File | Responsibility |
|---|---|
| `lib/main.dart` | Navigation and Activity 08 roster |
| `lib/database_helper.dart` | SQLite initialization, migration, and roster operations |
| `lib/folder.dart` | Folder data model |
| `lib/card_record.dart` | Card data model |
| `lib/catalogue_repository.dart` | Folder and card database operations |
| `lib/catalogue_screen.dart` | Card Catalogue UI |
| `pubspec.yaml` | Flutter dependencies |
| `README.md` | Documentation, testing, and evidence |
| `evidence/` | Screenshots and test evidence |

The application uses a repository layer to separate database operations from the Flutter user interface.

## 4. SQLite Database Architecture

**Database:** `MyDatabase.db`

**Activity 08 version:** 1  
**Activity 09 version:** 2

The application stores the database in the application documents directory using `getApplicationDocumentsDirectory()`.

On the disposable Android emulator, the database was located at:

```text
/data/user/0/com.example.local_storage_lab/app_flutter/MyDatabase.db
```

### Application Tables

The version-2 database contains three application tables:

1. `my_table`
2. `folders`
3. `cards`

### Original Activity 08 Table

The original `my_table` stores guest records.

| Column | Type |
|---|---|
| `_id` | INTEGER PRIMARY KEY |
| `name` | TEXT |
| `age` | INTEGER |

The version-2 migration retains this table.

### Folders Table

| Column | Type |
|---|---|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT |
| `name` | TEXT NOT NULL UNIQUE |
| `created_at` | TEXT NOT NULL |

### Cards Table

| Column | Type |
|---|---|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT |
| `title` | TEXT NOT NULL |
| `suit` | TEXT NOT NULL |
| `notes` | TEXT NOT NULL DEFAULT '' |
| `image_ref` | TEXT, nullable |
| `folder_id` | INTEGER NOT NULL |

### Foreign-Key Relationship

Each card belongs to one folder through `folder_id`.

The database declares:

```sql
FOREIGN KEY (folder_id)
REFERENCES folders(id)
ON DELETE CASCADE
```

The database also defines:

```text
idx_cards_folder_id
```

This index supports queries that retrieve cards belonging to a particular folder.

### Migration Strategy

The database helper supports:

- `onCreate` for a fresh version-2 installation.
- `onUpgrade` for upgrading an existing version-1 database.
- Creation of the new `folders` and `cards` tables.
- Preservation of the original `my_table`.
- Foreign-key configuration for the database connection.

The migration does not intentionally drop or recreate the original guest table.

## 5. Models and Repository

The application uses typed `Folder` and `CardRecord` models.

The models map between Dart objects and SQLite rows.

The repository supports:

- Creating folders.
- Reading folders and their card counts.
- Reading cards by folder ID.
- Creating cards.
- Editing cards by ID.
- Deleting cards by ID.
- Deleting folders by ID.

Integer primary keys are used to identify records reliably.

Two cards may share the same title while having different IDs.

## 6. Application Features

### Fall Festival Roster

The original Activity 08 interface supports:

- Adding guests.
- Viewing guest names, ages, and IDs.
- Editing guests by ID.
- Canceling edits.
- Deleting guests with confirmation.
- Refreshing the roster.
- Validating input.

The supported age range is 0 through 130.

### Card Catalogue

The Activity 09 interface supports:

- Creating folders.
- Displaying folder names and card counts.
- Opening a folder.
- Adding cards.
- Editing existing cards.
- Assigning cards to folders.
- Deleting individual cards.
- Deleting folders with confirmation.
- Displaying empty states.
- Showing fallback artwork when an image is missing.

### Card Fields

A card contains:

- Title.
- Suit.
- Notes.
- Optional image URL.
- Folder ID.

### Image Fallback

Image references are stored as URLs instead of image bytes.

If an image is unavailable or cannot load, the interface displays a suit symbol:

| Suit | Fallback |
|---|---|
| Hearts | ♥ |
| Diamonds | ♦ |
| Clubs | ♣ |
| Spades | ♠ |

This allows the card to remain usable even when its remote artwork is unavailable.

## 7. Activity 08 Data Preservation

The original installation was upgraded from database version 1 to version 2.

The following guest records remained visible after the upgrade:

| Guest ID | Name | Age |
|---|---|---|
| 2 | River | 35 |
| 3 | Acorn | 0 |
| 4 | Oak | 130 |

**Observed result: PASS**

The original records retained their IDs and values after the Activity 09 upgrade.

The available migration screenshot was captured after the upgrade. It is not presented as a pre-upgrade screenshot.

## 8. Fresh-Install SQLite Verification

A separate disposable Android emulator, `Activity09_Test` (`emulator-5556`), was used to verify fresh database creation.

The application was installed, launched, and used to initialize a new SQLite database.

A copy of `MyDatabase.db` was inspected using the macOS SQLite command-line tool.

### Verification Commands

```sql
PRAGMA user_version;

SELECT name
FROM sqlite_master
WHERE type = 'table';

PRAGMA foreign_key_list(cards);

PRAGMA index_list(cards);

PRAGMA foreign_key_check;
```

### Actual Results

**Database version:**

```text
2
```

**Tables:**

```text
android_metadata
my_table
folders
sqlite_sequence
cards
```

`android_metadata` and `sqlite_sequence` are SQLite/Android support tables.

**Foreign-key definition:**

```text
0|0|folders|folder_id|id|NO ACTION|CASCADE|NONE
```

This confirms that `cards.folder_id` references `folders.id` with `ON DELETE CASCADE`.

**Index:**

```text
0|idx_cards_folder_id|0|c|0
```

**Foreign-key integrity check:**

```text
No rows returned
```

This indicates no foreign-key violations were detected in the inspected database.

### Verification Summary

| Requirement | Result |
|---|---|
| Fresh database created | PASS |
| Database version 2 | PASS |
| Original `my_table` exists | PASS |
| `folders` table exists | PASS |
| `cards` table exists | PASS |
| Foreign-key relationship defined | PASS |
| `ON DELETE CASCADE` declared | PASS |
| `idx_cards_folder_id` exists | PASS |
| Foreign-key integrity check | PASS |

**Important distinction:** These checks verify the schema and integrity of the copied database. They do not independently establish the Android application's runtime `PRAGMA foreign_keys` connection setting or demonstrate a controlled cascade-deletion test.

The original emulator and its migrated Activity 08 data were not cleared or uninstalled during this verification.

## 9. Activity 09 Test Matrix

| Test | Observed Result | Status |
|---|---|---|
| T1a — Upgrade | Original guest records retained their IDs and values | PASS |
| T1b — Fresh install | Version-2 schema created and verified on disposable emulator | PASS |
| T2 — Create | Atlas contained two Compass cards with distinct IDs; Harbor contained Signal | PASS |
| T3 — Edit | Editing Compass ID 1 did not change Compass ID 2 | PARTIAL |
| T4 — Restart | Saved records remained after app force-stop and relaunch | PASS for observed persistence |
| T5 — Delete | Individual card and folder deletion were observed | PARTIAL |
| T6 — Validation | Blank card title rejected; invalid image URL showed fallback | PARTIAL |

The partial statuses identify assignment-specific subtests that were not independently documented.

### T1 — Upgrade and Fresh Installation

The existing version-1 database was upgraded to version 2 without losing the observed guest records.

A separate fresh installation successfully created the version-2 schema.

**Result:** PASS for the observed upgrade, preservation, and fresh-schema verification.

### T2 — Folder and Card Creation

Folders created:

- Atlas.
- Harbor.

Cards created:

| Card ID | Title | Suit | Folder |
|---|---|---|---|
| 1 | Compass | Hearts | Atlas |
| 2 | Compass | Spades | Atlas |
| 3 | Signal | Diamonds | Harbor |

The two Compass cards received distinct IDs despite sharing a title.

**Result:** PASS.

### T3 — Editing by ID

Card ID 1 was changed from:

```text
Compass — Hearts
```

to:

```text
Compass Updated — Clubs
```

Card ID 2 remained:

```text
Compass — Spades
```

This demonstrates that the edit targeted the selected card ID.

**Result:** PASS for targeted editing.

The separate edit-cancellation subtest was not independently documented.

### T4 — Restart Persistence

The application was force-stopped and relaunched on the original emulator without clearing its data.

Saved records remained available, including the edited Compass card.

**Result:** PASS for observed persistence after force-stop and relaunch.

The available screenshots do not independently document every step of the Android force-stop procedure.

### T5 — Deletion

An individual card was deleted without removing the other card.

The Harbor folder was also deleted through the application after containing the Signal card.

Atlas remained available.

**Result:** PASS for observed individual-card and folder deletion.

**Limitations:**

- The performed folder-deletion test used Harbor rather than the prescribed Atlas example.
- Delete-cancellation subtests were not independently recorded.
- Direct behavioral verification of cascading child deletion was not performed.

### T6 — Validation and Image Fallback

**Blank card title:**

An attempt to save a card with an empty title displayed:

```text
Title cannot be empty
```

No new card was created.

**Invalid image URL:**

A test card used:

```text
https://example.invalid/missing.png
```

The application displayed the Diamonds suit fallback without crashing.

**Result:** PASS for these observed cases.

Blank-folder and duplicate-folder-name validation were not separately documented.

## 10. Final Observed Catalogue State

After removing temporary test records, the original upgraded installation displayed:

| Folder | Card | Card ID | Suit |
|---|---|---|---|
| Atlas | Compass Updated | 1 | Clubs |

The separate fresh-install emulator was used only for disposable verification.

## 11. Evidence

The repository includes Activity 09 evidence under:

```text
evidence/activity09/
```

Captured evidence includes:

- Post-migration Activity 08 guest records.
- Card creation with duplicate titles and distinct IDs.
- Card editing.
- Catalogue screenshots after subsequent operations.
- Fresh-install interface screenshots, where saved.
- Static-analysis output.

Relevant screenshot filenames include:

```text
evidence/activity09/T1_migration.png
evidence/activity09/T2_cards.png
evidence/activity09/T3_edited.png
```

The original pre-upgrade screenshot was not recovered, so the post-migration screenshot is not labeled as proof of the earlier pre-upgrade state.

A read-only copy of the disposable SQLite database was also used for schema verification.

The SQLite database copy is diagnostic test data, not a required submission artifact.

### Static Analysis Evidence

```text
Analyzing local_storage_lab...
No issues found!
```

**Result:** PASS.

## 12. Database Design Decisions

### Why Use Integer IDs?

Titles and names are not guaranteed to be unique.

Two Compass cards were created with different IDs.

Editing one card by ID did not modify the other.

### Why Use Foreign Keys?

The `folder_id` column establishes a relationship between cards and their parent folders.

This helps maintain relational consistency and supports folder-specific queries.

### Why Use Cascading Deletion?

For this fictional Card Catalogue, deleting a folder is intended to remove its associated cards.

For applications that must retain historical records, other policies may be more appropriate:

- `ON DELETE RESTRICT`.
- Soft deletion.
- Reassignment to another folder.
- Transactional snapshot and restoration.

### Why Store Image URLs?

Image URLs avoid storing large image files directly in SQLite.

However, remote images depend on network availability and valid links.

The application uses a suit-symbol fallback when artwork cannot be displayed.

## 13. Graduate Critical Thinking and AI Alchemist's Lab

The separate graduate Critical Thinking document contains the required reflections and AI Lab responses.

### Reflection Prompts

1. Failure reconstruction.
2. Delete-policy trade-offs.
3. Image forensics.
4. Version-3 migration design.

### Graduate AI Lab

- **G1:** Migration time-loop.
- **G2:** Cascade bargain.

The graduate document includes the analysis, relevant test observations, and AI assistance disclosure.

### Version-3 Design

The version-3 migration is a design exercise, not an implemented feature of Activity 09.

The proposed design considers:

- Adding a favorite flag with a safe default.
- Adding a nullable review date.
- Preserving existing data.
- Testing both upgrades and fresh installations.
- Handling migration failures safely.

### G1 — Migration Time-Loop

The reflection evaluates why silently ignoring a failed migration can leave a database in an inconsistent state.

The proposed safer approach preserves migration transaction behavior, propagates failures, and verifies schema invariants.

### G2 — Cascade Bargain

The reflection evaluates why reinserting a deleted folder name is insufficient to restore its deleted cards, original IDs, and relationships.

Alternatives include restricted deletion, soft deletion, and snapshot-based undo.

No version-3 migration or undo feature was implemented for this activity.

## 14. Known Limitations

- Data is stored locally on the device.
- Cloud synchronization is not implemented.
- User authentication and database encryption are not included.
- Remote image URLs may fail.
- Runtime foreign-key enforcement was not independently queried on the Android connection.
- A controlled SQL cascade-deletion behavior test was not separately recorded.
- Some cancellation and validation subtests remain unverified.
- The original pre-upgrade screenshot was not available.
- Some test screenshots document the observed application state rather than the entire testing procedure.

These limitations are disclosed to distinguish verified behavior from untested scenarios.

## 15. Attribution and AI Assistance

The Activity 08 foundation and SQLite helper were developed using course-provided materials.

The application uses Flutter, Dart, SQLite, and the following packages:

- `sqflite`
- `path_provider`
- `path`

ChatGPT assisted with implementation planning, debugging, test planning, and documentation.

AI assistance and the evaluation of its suggestions are discussed in the separately submitted graduate Critical Thinking document.

Only observed test results are reported as completed.

## 16. GitHub Repository

**Activity 09 repository:**

https://github.com/AkshithaSanagarapu/local-storage-part-2

The repository contains the Flutter application, database implementation, README, and available evidence.

The original Activity 08 project was retained separately.

## 17. Final Submission Checklist

### Completed

- [x] Preserve observed Activity 08 guest records.
- [x] Implement SQLite database version 2.
- [x] Create `folders` and `cards` tables.
- [x] Define the foreign-key relationship and cascade rule.
- [x] Create the `folder_id` index.
- [x] Implement Folder and CardRecord models.
- [x] Implement repository-based CRUD operations.
- [x] Implement Card Catalogue UI.
- [x] Create folders and cards.
- [x] Verify duplicate-title cards have distinct IDs.
- [x] Edit a card by ID.
- [x] Observe persistence after force-stop and relaunch.
- [x] Test individual-card deletion.
- [x] Test folder deletion through the UI.
- [x] Test blank card-title validation.
- [x] Test invalid image URL fallback.
- [x] Run `flutter analyze` successfully.
- [x] Build the release APK.
- [x] Install the release APK.
- [x] Build the debug APK for database inspection.
- [x] Verify fresh-install database version 2.
- [x] Verify the three application tables.
- [x] Verify the declared foreign key and cascade rule.
- [x] Verify the folder-ID index.
- [x] Run `PRAGMA foreign_key_check` successfully.
- [x] Complete graduate reflection prompts 1–4.
- [x] Complete graduate AI Lab G1 and G2.
- [x] Prepare the graduate Critical Thinking DOCX.
- [x] Create the GitHub repository.
- [x] Push the Activity 09 implementation to GitHub.
- [x] Prepare the submission APK and GitHub link.

### Remaining or Not Independently Verified

- [ ] Independently verify the remaining cancellation subtests.
- [ ] Independently verify blank-folder and duplicate-folder validation.
- [ ] Perform a controlled cascade-deletion behavior test.
- [ ] Confirm any additional required screenshots are available.
- [ ] Commit and push the final README and evidence.
- [ ] Confirm the final iCollege submission receipt.

## 18. iCollege Submission Files

The submission consists of three files:

| File | Purpose |
|---|---|
| `github_link.txt` | Activity 09 GitHub repository link |
| `Activity09_Sanagarapu_Akshitha.apk` | Release Android APK |
| `Sanagarapu_Akshitha_CriticalThinking.docx` | Graduate reflection and AI Lab |

**Project status:** The Activity 09 application is implemented, the release APK was built and installed, the original guest records were preserved in the observed upgrade, and the fresh-install version-2 SQLite schema passed direct inspection.

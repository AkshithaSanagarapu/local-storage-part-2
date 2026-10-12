
# Local Storage Lab — Flutter & SQLite

**Mobile Application Development | In-Class Activities 08 & 09 | Section 2**

**Student:** Akshitha Sainath Sanagarapu (003027780)
**Pathway:** Graduate  
**Project Folder:** `local_storage_lab`

## 1. Project Overview

This Flutter application demonstrates local data persistence using SQLite.

The project was originally developed for Activity 08 as a Fall Festival guest roster. Activity 09 extends the same application by introducing a Card Catalogue with folders, cards, relationships, and database migration.

The application now includes two features:

1. **Fall Festival Roster (Activity 08):** Manage fictional guests using SQLite.
2. **Card Catalogue (Activity 09):** Organize cards into folders using a relational SQLite database.

The goal of Activity 09 is to extend an existing database without losing previously stored data.

## 2. Development Environment

| Component | Details |
|---|---|
| Flutter | 3.47.2 (stable) |
| Dart | 3.13.2 |
| IDE | Visual Studio Code |
| Operating System | macOS |
| Test Device | Pixel 10 Android Emulator |
| Android Version | Android 17, API 37 |
| Database | SQLite |
| Packages | `sqflite`, `path_provider`, `path` |

### Running the Application

Open a terminal inside `local_storage_lab` and run:

```bash
flutter pub get
flutter devices
flutter run -d emulator-5554
```

The emulator ID may differ depending on the development environment.

To run static analysis:

```bash
flutter analyze
```

To save the analyzer output:

```bash
mkdir -p evidence
flutter analyze 2>&1 | tee evidence/analysis_output.txt
```

To build a release APK:

```bash
flutter build apk --release
```

The generated APK is expected at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The project uses native SQLite storage and was tested on an Android emulator rather than Flutter web.

## 3. Application Structure

The application has a home screen with two navigation options.

### Fall Festival Roster

This is the original Activity 08 feature.

It supports:

- Adding guests with names and ages.
- Viewing saved records and database-generated IDs.
- Editing records by their unique IDs.
- Canceling edits without saving.
- Deleting records with confirmation.
- Refreshing records from SQLite.
- Displaying the current record count.
- Validating guest names and ages.

### Card Catalogue

This is the Activity 09 feature.

It supports:

- Creating folders.
- Displaying folders and their card counts.
- Opening a folder to view its cards.
- Creating cards with a title, suit, notes, and optional image reference.
- Editing an existing card.
- Moving a card to a different folder through the folder selector.
- Deleting individual cards by ID.
- Deleting folders with confirmation.
- Displaying a fallback suit symbol when an image is unavailable.
- Rejecting empty card titles.
- Preserving data across application restarts.

## 4. Project Files

| File | Responsibility |
|---|---|
| `lib/main.dart` | Application initialization, home navigation, and original roster |
| `lib/database_helper.dart` | SQLite initialization, schema versioning, and original roster CRUD |
| `lib/folder.dart` | Folder data model |
| `lib/card_record.dart` | Card data model |
| `lib/catalogue_repository.dart` | Folder and card database operations |
| `lib/catalogue_screen.dart` | Card Catalogue screens, forms, and dialogs |
| `pubspec.yaml` | Flutter project dependencies |

The Card Catalogue separates database operations from the user interface through a repository class.

## 5. SQLite Database Architecture

### Database Details

**Database name:** `MyDatabase.db`  
**Original schema version:** 1  
**Updated schema version:** 2

The database contains three tables:

1. `my_table`
2. `folders`
3. `cards`

### Original Table: `my_table`

This table belongs to Activity 08.

| Column | SQLite Type | Purpose |
|---|---|---|
| `_id` | INTEGER PRIMARY KEY | Unique guest ID |
| `name` | TEXT NOT NULL | Guest name |
| `age` | INTEGER NOT NULL | Guest age |

The original guest records are preserved when the database is upgraded.

### New Table: `folders`

The folders table stores the categories used to organize cards.

Each folder has a database-generated ID, a name, and creation information.

The application displays the number of cards associated with each folder.

### New Table: `cards`

The cards table stores the Card Catalogue records.

Each card contains:

| Field | Purpose |
|---|---|
| ID | Unique database identity |
| Title | Card name |
| Suit | Hearts, Diamonds, Clubs, or Spades |
| Notes | Optional description |
| Image reference | Optional image URL |
| Folder ID | Reference to the owning folder |

The folder ID establishes the relationship between a card and its folder.

### Relationships and Foreign Keys

The Card Catalogue uses a one-to-many relationship:

```text
Folder
  |
  +-- Card
  +-- Card
  +-- Card
```

One folder can contain multiple cards, but each card belongs to one folder at a time.

SQLite foreign-key enforcement is enabled during database configuration.

The card-to-folder relationship uses cascading deletion so that removing a folder also removes its associated cards.

### Database Migration

Activity 08 used database version 1.

Activity 09 upgrades the schema to version 2.

The migration adds the `folders` and `cards` tables while retaining the original `my_table`.

This is important because changing only the database creation logic would not update an already-installed application.

The upgrade logic handles existing installations, while the creation logic supports new installations.

The migration is intended to preserve existing guest data rather than replacing the database.

## 6. CRUD Implementation

### Folder Operations

**Create:** Insert a folder after validating its name.

**Read:** Query saved folders and calculate their associated card counts.

**Delete:** Request confirmation before deleting a folder.

### Card Operations

**Create:** Validate card details and insert the new record into SQLite.

**Read:** Query cards associated with a selected folder.

**Update:** Modify a card using its unique database ID.

**Delete:** Remove only the card identified by its ID.

### Why Unique IDs Matter

Two cards can have identical titles.

For example, the application successfully stored:

| ID | Title | Suit |
|---|---|---|
| 1 | Compass | Hearts |
| 2 | Compass | Spades |

The records remained independent because they had different database-generated IDs.

When card ID 1 was edited, card ID 2 remained unchanged.

This demonstrates why update and delete operations should target primary keys rather than visible titles.

## 7. Input Validation and Error Handling

The application validates user input before performing database operations.

### Folder Validation

- Folder names cannot be empty after trimming whitespace.
- Duplicate folder names are handled through database constraints and error feedback.

### Card Validation

- Card titles cannot be empty.
- Suits must be selected from the supported options.
- Cards must reference an existing folder.
- Notes are optional.
- Image URLs are optional.

### Image Fallback

If no image reference is provided, the application displays the card's suit symbol.

If an image URL cannot be loaded, the application also displays the suit symbol instead of a broken image.

Supported suit symbols include:

- Hearts: ♥
- Diamonds: ♦
- Clubs: ♣
- Spades: ♠

### User Experience

The application includes:

- Loading indicators.
- Empty-state messages.
- Confirmation dialogs.
- Cancel buttons.
- Validation feedback.
- Error messages.
- Refreshable database-backed lists.

Dialog text controllers are managed by dedicated stateful widgets to avoid accessing disposed controllers after a dialog closes.

## 8. Activity 08 — Original Roster Testing

The original Activity 08 implementation tested:

- Empty roster behavior.
- Creating guests with duplicate names.
- Editing by unique ID.
- Canceling an edit.
- Persistence after relaunch.
- Deleting by unique ID.
- Name and age validation.
- Minimum and maximum accepted ages.

The age validation accepts whole numbers from 0 through 130.

The Activity 08 test data remaining in the upgraded application was observed as:

| Guest ID | Name | Age |
|---|---|---|
| 2 | River | 35 |
| 3 | Acorn | 0 |
| 4 | Oak | 130 |

The original roster was displayed after Activity 09 changes were installed, providing evidence that the existing records remained accessible.

## 9. Activity 09 — Manual Testing

Testing was performed on a Pixel 10 Android emulator.

### T1 — Database Upgrade and Existing Data

**Objective:** Confirm that upgrading the database does not remove the Activity 08 guest records.

**Observed:**

The original Fall Festival Roster displayed three existing records:

- River, ID 2, age 35.
- Acorn, ID 3, age 0.
- Oak, ID 4, age 130.

The Card Catalogue was also accessible.

**Result:** PASS for the observed upgraded installation.

**Additional verification:** A separate fresh-install schema test is still required.

### T2 — Folder and Card Creation

**Objective:** Create folders and cards, including records with duplicate titles.

**Folders created:**

- Atlas
- Harbor

**Cards created:**

| ID | Title | Suit | Folder |
|---|---|---|---|
| 1 | Compass | Hearts | Atlas |
| 2 | Compass | Spades | Atlas |
| 3 | Signal | Diamonds | Harbor |

**Observed:**

- Both folders were displayed.
- Atlas contained two Compass cards.
- Harbor contained one Signal card.
- Duplicate card titles received different IDs.
- Card symbols appeared when image URLs were blank.

**Result:** PASS

### T3 — Edit a Card by ID

**Objective:** Update one Compass card without modifying the other.

**Action:**

Edited card ID 1:

- Title changed from Compass to Compass Updated.
- Suit changed from Hearts to Clubs.
- Notes changed to Edited first Compass card.

**Observed:**

Card ID 1 reflected the new details.

Card ID 2 remained Compass with the Spades suit.

**Result:** PASS

### T4 — Persistence After Restart

**Objective:** Confirm that card data remains available after restarting the application.

**Action:**

Stopped the Flutter session, closed the application, and relaunched it on the same Android emulator without clearing application data.

**Observed after relaunch:**

| ID | Title | Suit | Folder |
|---|---|---|---|
| 1 | Compass Updated | Clubs | Atlas |
| 2 | Compass | Spades | Atlas |

The records retained their original IDs and edited values.

**Result:** PASS

### T5 — Card and Folder Deletion

**Objective:** Verify deletion by ID and folder deletion behavior.

**Individual card deletion:**

Deleted Compass, ID 2.

**Observed:**

Compass Updated, ID 1, remained in Atlas.

**Folder deletion:**

Deleted Harbor, which previously contained Signal, ID 3.

**Observed:**

Harbor disappeared from the folder list.

Atlas remained intact.

**Result:** PASS for the observed UI behavior.

**Additional verification:** Direct database-level confirmation that Signal was removed through `ON DELETE CASCADE` remains to be completed.

### T6 — Invalid Input and Image Fallback

**Objective:** Verify validation and graceful handling of invalid image references.

**Empty-title test:**

Attempted to save a card with a blank title.

**Observed:**

The dialog remained open and displayed:

```text
Title cannot be empty
```

No new card was created.

**Invalid image test:**

Created a temporary card with:

| Field | Value |
|---|---|
| Title | Image Test |
| Suit | Diamonds |
| Folder | Atlas |
| Image URL | `https://example.invalid/missing.png` |

**Observed:**

The card displayed the Diamonds fallback symbol without crashing.

**Result:** PASS

### Test Data Cleanup

After testing:

- Compass, ID 2, was deleted.
- Harbor and its associated Signal card were removed through the folder deletion workflow.
- The temporary Image Test card was deleted.
- The temporary Test Folder was deleted.

**Final observed Card Catalogue state:**

- Atlas: 1 card.
- Compass Updated: ID 1, Clubs.

## 10. Evidence and Screenshots

The project uses an `evidence` directory for screenshots and analysis results.

Recommended Activity 09 evidence filenames:

| File | Description |
|---|---|
| `evidence/T1_before.png` | Original Activity 08 guest records after upgrade |
| `evidence/T2_folders.png` | Atlas and Harbor folders |
| `evidence/T2_cards.png` | Two Compass cards with different IDs |
| `evidence/T2_signal.png` | Signal card in Harbor |
| `evidence/T3_edit.png` | Edited Compass and unchanged second card |
| `evidence/T4_after.png` | Cards preserved after restart |
| `evidence/T5_delete.png` | Remaining card after individual deletion |
| `evidence/T5_folder_delete.png` | Folder list after deleting Harbor |
| `evidence/T6_invalid.png` | Empty-title validation message |
| `evidence/T6_image_fallback.png` | Invalid image URL fallback |
| `evidence/analysis_output.txt` | Flutter static analysis result |

These are recommended filenames for organizing the captured screenshots. Screenshots must be copied into the project and named accordingly before submission.

### Static Analysis

The final recorded analyzer result was:

```text
Analyzing local_storage_lab...
No issues found! (ran in 0.9s)
```

This confirms that Flutter's static analyzer reported no issues at the time of testing.

Static analysis does not replace runtime or database verification.

## 11. Activity 08 — Graduate Reflection

### Reflection 1: The Disappearing-Data Mystery

Before restarting the original roster, I predicted that the saved River records would remain available because they were stored in SQLite rather than only in Flutter memory.

After relaunching the application, the same saved records and IDs were displayed.

If the records had disappeared or returned with different values, that would have contradicted the expected persistence behavior.

### Reflection 2: Two Rivers, One Wrong Edit

Two guests shared the name River but had different IDs.

Canceling an edit left the original value unchanged. Saving a later edit updated only the selected record.

This showed why unique primary keys are necessary when different records can have the same visible name.

### Reflection 3: Usability Walkthrough

During development, the original roster encountered a refresh issue caused by sorting a database result list directly.

The implementation was corrected to use a modifiable list before sorting.

This reinforced the importance of testing the interface after database operations, not just checking whether the SQL statement succeeds.

### Reflection 4: Defending the Storage Boundary

The roster validates guest names and ages in Flutter before writing to SQLite.

This provides immediate feedback to the user.

SQLite constraints protect the database structure, but they do not automatically enforce every application-specific validation rule.

Future schema changes should use versioned migrations so existing installations retain their saved data.

## 12. Activity 09 — Graduate Reflection

### Reflection 1: Preserving Existing Data

Activity 09 required extending the original SQLite database rather than creating an unrelated replacement.

The application continued displaying the original guest records after the updated schema was installed.

This demonstrated why preserving the database name, original table, and migration path matters.

The existing data should not be deleted merely because new functionality has been introduced.

### Reflection 2: Relationships and Primary Keys

The Card Catalogue uses a one-to-many relationship between folders and cards.

Each card has a unique ID and a folder reference.

During testing, two cards named Compass were inserted into Atlas.

Editing one Compass card changed only its selected ID.

This demonstrated the importance of using primary keys for updates and foreign keys for relationships.

### Reflection 3: Testing Persistence and Deletion

The cards remained available after the application was stopped and relaunched.

The edited Compass card retained its ID and updated values.

Deleting the other Compass card did not remove the edited card.

Deleting Harbor removed it from the folder list while Atlas remained available.

These tests helped verify that the interface continued reflecting the saved SQLite state after different operations.

### Reflection 4: Debugging and User Experience

During Activity 09 testing, the application encountered a Flutter widget lifecycle assertion involving dialog controllers.

The issue was addressed by moving the dialog controllers into dedicated stateful widgets and disposing them through the widget lifecycle.

The application was then rebuilt and tested again.

Subsequent folder and card operations completed without the earlier red-screen error.

This experience reinforced the importance of testing asynchronous workflows and widget lifecycles in addition to database logic.

## 13. Graduate AI Lab

AI assistance was used during development to:

- Review the existing Flutter and SQLite implementation.
- Plan the database migration.
- Organize the folder and card models.
- Implement the repository and interface.
- Investigate Flutter analyzer warnings.
- Debug the dialog controller lifecycle issue.
- Plan manual tests for persistence, editing, deletion, and validation.
- Improve project documentation.

The application behavior described in the testing section was checked using the Android emulator.

**Graduate AI lab exercises G1–G4:** The two selected exercises and their required prompts, outputs, and reflections still need to be documented separately before submission. General development assistance is not automatically equivalent to completing those exercises.

## 14. Known Limitations

- Data is stored locally on the installed device.
- The application does not provide cloud synchronization.
- There is no user authentication or database encryption.
- Images are referenced by URL rather than stored as binary data.
- An unavailable image URL displays a suit symbol.
- The current testing evidence is primarily based on manual emulator testing.
- A separate disposable fresh-install schema test and direct cascade verification remain outstanding.

## 15. Attribution and AI Assistance

The original SQLite database helper was based on the course-provided material used for Activity 08.

The project uses Flutter, Dart, SQLite, and the `sqflite`, `path_provider`, and `path` packages.

ChatGPT assisted with test planning and debugging.

All stated manual testing observations were based on interactions with the Android emulator.

## 16. Final Submission Checklist

- [x] Preserve the Activity 08 roster functionality.
- [x] Implement the Card Catalogue.
- [x] Add folders and cards.
- [x] Support card creation, reading, editing, and deletion.
- [x] Support folder deletion.
- [x] Test duplicate card titles with unique IDs.
- [x] Test persistence after restart.
- [x] Test invalid card titles.
- [x] Test invalid image URL fallback.
- [x] Run `flutter analyze` successfully.
- [ ] Copy and organize all required screenshots in `evidence/`.
- [ ] Complete fresh-install database verification.
- [ ] Verify cascade deletion directly in SQLite.
- [ ] Complete two graduate AI lab exercises.
- [ ] Build and verify the release APK.
- [ ] Prepare the required reflection document.
- [ ] Commit and push the final project to GitHub.
- [ ] Submit all required files and links.

---

**Project Status:** Activity 08 and Activity 09 core functionality implemented and manually tested. Final verification, graduate AI lab documentation, evidence packaging, release build, and submission preparation remain.


import 'package:flutter/material.dart';

import 'catalogue_repository.dart';
import 'card_record.dart';
import 'folder.dart';

// ------------------------------------------------------------
// FOLDER LIST SCREEN
// ------------------------------------------------------------

class CatalogueScreen extends StatefulWidget {
  final CatalogueRepository repository;

  const CatalogueScreen({
    super.key,
    required this.repository,
  });

  @override
  State<CatalogueScreen> createState() =>
      _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  List<Folder> _folders = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      final folders =
          await widget.repository.getFoldersWithCounts();

      if (!mounted) return;

      setState(() {
        _folders = folders;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load folders: $error';
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addFolder() async {
    if (_busy) return;

    // The dialog owns and disposes its text controller.
    // No database operation happens while the dialog closes.
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _FolderDialog(),
    );

    if (!mounted || name == null) return;

    setState(() {
      _busy = true;
    });

    try {
      await widget.repository.insertFolder(name);

      await _loadFolders();

      _showMessage('Folder "$name" created');
    } catch (error) {
      _showMessage(
        'Could not create folder. '
        'Check whether the name already exists.',
      );

      debugPrint('Folder creation failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _deleteFolder(Folder folder) async {
    if (_busy || folder.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Folder?'),
          content: Text(
            'Delete "${folder.name}" and all '
            '${folder.cardCount} cards inside it?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _busy = true;
    });

    try {
      final affected =
          await widget.repository.deleteFolder(folder.id!);

      await _loadFolders();

      _showMessage(
        affected == 1
            ? 'Folder deleted'
            : 'Folder was not found',
      );
    } catch (error) {
      _showMessage('Delete failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Catalogue'),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _addFolder,
        icon: const Icon(Icons.create_new_folder),
        label: const Text('Add Folder'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _loadFolders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _folders.isEmpty
                  ? const Center(
                      child: Text(
                        'No folders yet.\n'
                        'Tap Add Folder to begin.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFolders,
                      child: ListView.builder(
                        itemCount: _folders.length,
                        itemBuilder: (context, index) {
                          final folder = _folders[index];

                          return ListTile(
                            leading: const Icon(
                              Icons.folder,
                              color: Colors.deepPurple,
                            ),
                            title: Text(folder.name),
                            subtitle: Text(
                              '${folder.cardCount} cards',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                              ),
                              onPressed: _busy
                                  ? null
                                  : () => _deleteFolder(folder),
                            ),
                            onTap: _busy
                                ? null
                                : () async {
                                    if (folder.id == null) {
                                      return;
                                    }

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (context) {
                                          return CardsScreen(
                                            repository:
                                                widget.repository,
                                            folder: folder,
                                          );
                                        },
                                      ),
                                    );

                                    if (mounted) {
                                      await _loadFolders();
                                    }
                                  },
                          );
                        },
                      ),
                    ),
    );
  }
}

// ------------------------------------------------------------
// CREATE FOLDER DIALOG
// ------------------------------------------------------------

class _FolderDialog extends StatefulWidget {
  const _FolderDialog();

  @override
  State<_FolderDialog> createState() =>
      _FolderDialogState();
}

class _FolderDialogState extends State<_FolderDialog> {
  final TextEditingController _nameController =
      TextEditingController();

  String? _validation;

  @override
  void dispose() {
    // Flutter disposes this controller only when the
    // dialog widget has actually been removed.
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _validation = 'Enter a folder name';
      });
      return;
    }

    // Return the name. The parent saves it afterward.
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Folder'),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: 'Folder name',
          errorText: _validation,
        ),
        onChanged: (value) {
          if (_validation != null) {
            setState(() {
              _validation = null;
            });
          }
        },
        onSubmitted: (value) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// CARDS LIST SCREEN
// ------------------------------------------------------------

class CardsScreen extends StatefulWidget {
  final CatalogueRepository repository;
  final Folder folder;

  const CardsScreen({
    super.key,
    required this.repository,
    required this.folder,
  });

  @override
  State<CardsScreen> createState() =>
      _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<CardRecord> _cards = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      final cards = await widget.repository.getCards(
        widget.folder.id!,
      );

      if (!mounted) return;

      setState(() {
        _cards = cards;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load cards: $error';
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _symbol(String suit) {
    switch (suit) {
      case 'Hearts':
        return '♥';
      case 'Diamonds':
        return '♦';
      case 'Clubs':
        return '♣';
      case 'Spades':
        return '♠';
      default:
        return '?';
    }
  }

  Widget _cardImage(CardRecord card) {
    final reference = card.imageRef?.trim() ?? '';

    final fallback = Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      color: Colors.deepPurple.shade50,
      child: Text(
        _symbol(card.suit),
        style: const TextStyle(
          fontSize: 32,
          color: Colors.deepPurple,
        ),
      ),
    );

    if (reference.isEmpty) {
      return fallback;
    }

    final uri = Uri.tryParse(reference);

    if (uri == null ||
        (uri.scheme != 'https' &&
            uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return fallback;
    }

    return Image.network(
      reference,
      width: 58,
      height: 58,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return fallback;
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return fallback;
      },
    );
  }

  Future<void> _openCardForm([
    CardRecord? existing,
  ]) async {
    if (_busy) return;

    List<Folder> folders;

    try {
      folders =
          await widget.repository.getFoldersWithCounts();
    } catch (error) {
      _showMessage(
        'Could not load folder choices: $error',
      );
      return;
    }

    if (!mounted) return;

    final selectedFolderId =
        existing?.folderId ?? widget.folder.id!;

    if (!folders.any(
      (folder) => folder.id == selectedFolderId,
    )) {
      _showMessage(
        'Selected folder no longer exists',
      );
      return;
    }

    // The dialog owns all of its text controllers.
    final card = await showDialog<CardRecord>(
      context: context,
      builder: (context) {
        return _CardDialog(
          existing: existing,
          folders: folders,
          defaultFolderId: widget.folder.id!,
        );
      },
    );

    if (!mounted || card == null) return;

    setState(() {
      _busy = true;
    });

    try {
      if (existing == null) {
        final id =
            await widget.repository.insertCard(card);

        _showMessage('Card created (ID $id)');
      } else {
        final affected =
            await widget.repository.updateCard(card);

        _showMessage(
          affected == 1
              ? 'Card updated'
              : 'Card no longer exists',
        );
      }

      await _loadCards();
    } catch (error) {
      _showMessage('Save failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _deleteCard(CardRecord card) async {
    if (_busy || card.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Card?'),
          content: Text(
            'Delete "${card.title}" '
            '(ID ${card.id})?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _busy = true;
    });

    try {
      final affected =
          await widget.repository.deleteCard(card.id!);

      await _loadCards();

      _showMessage(
        affected == 1
            ? 'Card deleted'
            : 'Card no longer exists',
      );
    } catch (error) {
      _showMessage('Delete failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy
            ? null
            : () => _openCardForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _loadCards,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _cards.isEmpty
                  ? const Center(
                      child: Text(
                        'This folder has no cards yet.',
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCards,
                      child: ListView.builder(
                        itemCount: _cards.length,
                        itemBuilder: (context, index) {
                          final card = _cards[index];

                          return Card(
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: _cardImage(card),
                              title: Text(card.title),
                              subtitle: Text(
                                '${card.suit} · '
                                'ID ${card.id}\n'
                                '${card.notes}',
                              ),
                              isThreeLine: true,
                              onTap: _busy
                                  ? null
                                  : () => _openCardForm(card),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                                onPressed: _busy
                                    ? null
                                    : () => _deleteCard(card),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

// ------------------------------------------------------------
// CREATE / EDIT CARD DIALOG
// ------------------------------------------------------------

class _CardDialog extends StatefulWidget {
  final CardRecord? existing;
  final List<Folder> folders;
  final int defaultFolderId;

  const _CardDialog({
    required this.existing,
    required this.folders,
    required this.defaultFolderId,
  });

  @override
  State<_CardDialog> createState() =>
      _CardDialogState();
}

class _CardDialogState extends State<_CardDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _imageController;

  late String _suit;
  late int _folderId;

  String? _validation;

  static const List<String> _suits = [
    'Hearts',
    'Diamonds',
    'Clubs',
    'Spades',
  ];

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;

    _titleController = TextEditingController(
      text: existing?.title ?? '',
    );

    _notesController = TextEditingController(
      text: existing?.notes ?? '',
    );

    _imageController = TextEditingController(
      text: existing?.imageRef ?? '',
    );

    _suit = existing?.suit ?? 'Hearts';

    _folderId =
        existing?.folderId ?? widget.defaultFolderId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _imageController.dispose();

    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _validation = 'Title cannot be empty';
      });
      return;
    }

    if (!_suits.contains(_suit)) {
      setState(() {
        _validation = 'Choose a valid suit';
      });
      return;
    }

    if (!widget.folders.any(
      (folder) => folder.id == _folderId,
    )) {
      setState(() {
        _validation = 'Choose a valid folder';
      });
      return;
    }

    final imageText = _imageController.text.trim();

    final card = CardRecord(
      id: widget.existing?.id,
      title: title,
      suit: _suit,
      notes: _notesController.text,
      imageRef:
          imageText.isEmpty ? null : imageText,
      folderId: _folderId,
    );

    // Return the validated card.
    // The parent performs the database operation.
    Navigator.pop(context, card);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? 'Add Card'
            : 'Edit Card',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Card title *',
              ),
              onChanged: (value) {
                if (_validation != null) {
                  setState(() {
                    _validation = null;
                  });
                }
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: _suit,
              decoration: const InputDecoration(
                labelText: 'Suit',
              ),
              items: _suits.map((suit) {
                return DropdownMenuItem<String>(
                  value: suit,
                  child: Text(suit),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _suit = value;
                  });
                }
              },
            ),
            DropdownButtonFormField<int>(
              initialValue: _folderId,
              decoration: const InputDecoration(
                labelText: 'Folder',
              ),
              items: widget.folders
                  .where(
                    (folder) => folder.id != null,
                  )
                  .map((folder) {
                return DropdownMenuItem<int>(
                  value: folder.id!,
                  child: Text(folder.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _folderId = value;
                  });
                }
              },
            ),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
              ),
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
              ),
            ),
            if (_validation != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: Text(
                  _validation!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

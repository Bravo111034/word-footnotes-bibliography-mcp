import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import 'file_preview_screen.dart';

class LibraryFile {
  const LibraryFile({
    required this.name,
    required this.folder,
    required this.icon,
    required this.aiProcessed,
  });

  final String name;
  final String folder;
  final IconData icon;
  final bool aiProcessed;
}

const _folders = ['All', 'Documents', 'Images', 'Research', 'Notes'];

const _files = [
  LibraryFile(name: 'EV battery report.pdf', folder: 'Research', icon: Icons.picture_as_pdf_outlined, aiProcessed: true),
  LibraryFile(name: 'Brand moodboard.png', folder: 'Images', icon: Icons.image_outlined, aiProcessed: false),
  LibraryFile(name: 'Customer interview notes.docx', folder: 'Documents', icon: Icons.description_outlined, aiProcessed: true),
  LibraryFile(name: 'Q3 board deck.pptx', folder: 'Documents', icon: Icons.slideshow_outlined, aiProcessed: true),
  LibraryFile(name: 'Meeting notes — Sep 12.md', folder: 'Notes', icon: Icons.notes_outlined, aiProcessed: false),
];

/// Library: a grid asset manager with a folder filter row and per-file
/// AI-processed indicator (spec §30-32). Tapping a file opens
/// [FilePreviewScreen] with an "Ask Aura" quick action.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _folder = 'All';
  bool _gridView = true;

  @override
  Widget build(BuildContext context) {
    final files = _folder == 'All' ? _files : _files.where((f) => f.folder == _folder).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: Icon(_gridView ? Icons.view_list_outlined : Icons.grid_view_outlined),
            onPressed: () => setState(() => _gridView = !_gridView),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AuraSpace.md, vertical: AuraSpace.sm),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _folders.length,
                separatorBuilder: (_, __) => const SizedBox(width: AuraSpace.xs),
                itemBuilder: (context, i) {
                  final folder = _folders[i];
                  return ChoiceChip(
                    label: Text(folder),
                    selected: _folder == folder,
                    onSelected: (_) => setState(() => _folder = folder),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: _gridView ? _LibraryGrid(files: files) : _LibraryList(files: files),
          ),
        ],
      ),
    );
  }
}

class _LibraryGrid extends StatelessWidget {
  const _LibraryGrid({required this.files});

  final List<LibraryFile> files;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AuraSpace.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AuraSpace.sm,
        crossAxisSpacing: AuraSpace.sm,
        childAspectRatio: 1.1,
      ),
      itemCount: files.length,
      itemBuilder: (context, i) => _FileCard(file: files[i]),
    );
  }
}

class _LibraryList extends StatelessWidget {
  const _LibraryList({required this.files});

  final List<LibraryFile> files;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AuraSpace.md),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(height: AuraSpace.sm),
      itemBuilder: (context, i) {
        final file = files[i];
        return AuraCard(
          onTap: () => _openPreview(context, file),
          child: Row(
            children: [
              Icon(file.icon, color: AuraColors.violet),
              const SizedBox(width: AuraSpace.sm),
              Expanded(child: Text(file.name, overflow: TextOverflow.ellipsis)),
              if (file.aiProcessed) const AuraStatusBadge(label: 'AI', tone: AuraBadgeTone.violet),
            ],
          ),
        );
      },
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({required this.file});

  final LibraryFile file;

  @override
  Widget build(BuildContext context) {
    return AuraCard(
      onTap: () => _openPreview(context, file),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(file.icon, color: AuraColors.violet, size: 28),
              const Spacer(),
              if (file.aiProcessed) const AuraStatusBadge(label: 'AI', tone: AuraBadgeTone.violet),
            ],
          ),
          const Spacer(),
          Text(file.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

void _openPreview(BuildContext context, LibraryFile file) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => FilePreviewScreen(file: file)));
}

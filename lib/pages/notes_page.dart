import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool loading = true;
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // 🔹 READ NOTES
  Future<void> _loadNotes() async {
    setState(() => loading = true);

    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      }
      setState(() => loading = false);
      return;
    }

    try {
      final response = await supabase
          .from('notes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        notes = List<Map<String, dynamic>>.from(response);
      });
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notes: ${e.message}')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // 🔹 CREATE / UPDATE NOTE
  Future<void> _openNoteDialog({Map<String, dynamic>? note}) async {
    final titleController = TextEditingController(text: note?['title'] ?? '');
    final contentController = TextEditingController(
      text: note?['content'] ?? '',
    );
    final isEditing = note != null;

    final accent = const Color(0xFF9C8EF3);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: const Color(0xFFF0F1F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: const Color(0xFFF0F1F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(
              isEditing ? 'Update' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result != true) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = {
      'user_id': user.id,
      'title': titleController.text.trim(),
      'content': contentController.text.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      if (isEditing) {
        await supabase.from('notes').update(data).eq('id', note['id']);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note updated')));
      } else {
        await supabase.from('notes').insert(data).select();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note added')));
      }
      _loadNotes();
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  // 🔹 DELETE NOTE
  Future<void> _deleteNote(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Note',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('notes').delete().eq('id', id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note deleted')));
      _loadNotes();
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  // 🔹 BUILD UI
  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F6FA);
    const accent = Color(0xFF9C8EF3);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          "Your Notes",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        onPressed: () => _openNoteDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Note', style: TextStyle(color: Colors.white)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: accent))
          : notes.isEmpty
          ? const Center(
              child: Text(
                'No notes yet.\nTap "+" to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    title: Text(
                      note['title'] ?? 'Untitled',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        note['content'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openNoteDialog(note: note);
                        } else if (value == 'delete') {
                          _deleteNote(note['id']);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.black87),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'note_detail_screen.dart';
import 'login_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final supa = Supabase.instance.client;
  List notes = [];

  @override
  void initState() {
    super.initState();
    _loadInitialNotes();
    _subscribeToRealtimeUpdates();
  }

  void _loadInitialNotes() async {
    final userId = supa.auth.currentUser?.id;
    if (userId == null) return;

    final data = await supa
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('inserted_at', ascending: false);

    setState(() => notes = data);
  }

  void _subscribeToRealtimeUpdates() {
    final userId = supa.auth.currentUser?.id;
    if (userId == null) return;

    supa
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
      setState(() => notes = data);
    });
  }

  void _logout() async {
    await supa.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          'Tus Gastos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          )
        ],
      ),
      body: notes.isEmpty
          ? Center(
              child: Text(
                'No hay notas registradas',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (_, i) {
                final n = notes[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      n['title'],
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '\$${n['price']}',
                      style: GoogleFonts.poppins(color: Colors.green.shade700),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteDetailScreen(note: n),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteDetailScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

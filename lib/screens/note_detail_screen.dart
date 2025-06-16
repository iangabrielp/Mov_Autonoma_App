import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteDetailScreen extends StatefulWidget {
  final Map? note;
  const NoteDetailScreen({this.note, super.key});
  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  bool get isNew => widget.note == null;

  @override
  void initState() {
    super.initState();
    if (!isNew) {
      titleCtrl.text = widget.note!['title'];
      descCtrl.text = widget.note!['description'];
      priceCtrl.text = widget.note!['price'].toString();
    }
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;

    final data = {
      'title': titleCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'price': double.tryParse(priceCtrl.text) ?? 0,
      'user_id': Supabase.instance.client.auth.currentUser!.id,
    };

    final client = Supabase.instance.client;
    if (isNew) {
      await client.from('notes').insert(data);
    } else {
      await client.from('notes').update(data).eq('id', widget.note!['id']);
    }
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (!isNew) {
      await Supabase.instance.client.from('notes').delete().eq('id', widget.note!['id']);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Nuevo Gasto' : 'Editar Gasto'),
        actions: [
          if (!isNew)
            IconButton(onPressed: _delete, icon: const Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(children: [
            TextFormField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
            TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
            TextFormField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
              validator: (v) => double.tryParse(v ?? '') == null ? 'Número inválido' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Guardar')),
          ]),
        ),
      ),
    );
  }
}

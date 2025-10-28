import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/in_page_nav.dart';

class ContactEntry {
  final String id;
  final String name;
  final String role;
  final String phone;
  final Uint8List? avatar;

  ContactEntry({required this.id, required this.name, required this.role, required this.phone, this.avatar});
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final List<ContactEntry> _saved = [];

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _requestPermission() async {
    final status = await Permission.contacts.status;
    if (status.isGranted) return true;
    final res = await Permission.contacts.request();
    return res.isGranted;
  }

  Future<void> _pickDeviceContact() async {
    final ok = await _requestPermission();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contacts permission denied')));
      return;
    }

    try {
      // Use flutter_contacts to open external picker
  final Contact? c = await FlutterContacts.openExternalPick();
  if (c == null) return;

  // guard against widget disposed while picking
  if (!mounted) return;

  final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
  final name = c.displayName;
  final avatar = c.photo;

      final entry = ContactEntry(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, role: '', phone: phone, avatar: avatar);
      setState(() => _saved.insert(0, entry));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick contact: $e')));
    }
  }

  Future<void> _manualAdd() async {
    final result = await showModalBottomSheet<ContactEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _ManualAddForm(),
      ),
    );

    if (result != null) setState(() => _saved.insert(0, result));
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot place call')));
      return;
    }
    await launchUrl(uri);
  }

  Widget _buildCard(ContactEntry e) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.teal[50],
              backgroundImage: e.avatar != null ? MemoryImage(e.avatar!) : null,
              child: e.avatar == null ? Text(_initials(e.name), style: const TextStyle(fontWeight: FontWeight.w700)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(e.role.isEmpty ? 'Unknown' : e.role, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ]),
            ),
            // three action buttons: call, edit, delete
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _callNumber(e.phone),
                  icon: Icon(Icons.call, color: Colors.teal[700]),
                ),
                IconButton(
                  onPressed: () => _showEditContactModal(e),
                  icon: const Icon(Icons.edit, color: Colors.black54),
                ),
                IconButton(
                  onPressed: () => _confirmDeleteContact(e),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditContactModal(ContactEntry entry) async {
    final updated = await showModalBottomSheet<ContactEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _EditContactForm(entry: entry),
      ),
    );

    if (updated != null) {
      setState(() {
        final idx = _saved.indexWhere((c) => c.id == updated.id);
        if (idx != -1) _saved[idx] = updated;
      });
    }
  }

  void _confirmDeleteContact(ContactEntry entry) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('Delete ${entry.name}?'),
        content: const Text('This will remove the contact from saved contacts.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(d).pop();
              // perform delete with undo
              setState(() => _saved.removeWhere((c) => c.id == entry.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${entry.name} deleted'),
                  action: SnackBarAction(label: 'Undo', onPressed: () {
                    setState(() => _saved.insert(0, entry));
                  }),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Contacts', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Saved Contacts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: _saved.isEmpty
                  ? Center(child: Text('No contacts saved yet.', style: TextStyle(color: Colors.grey[600])))
                  : ListView.separated(
                      itemCount: _saved.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _buildCard(_saved[i]),
                    ),
            ),
            const SizedBox(height: 12),
            const InPageNav(activeIndex: 1),
          ],
        ),
      ),
      // move the FAB up a bit so it doesn't block the in-page nav bar
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
  // move the FAB further up so it doesn't overlap the in-page nav; use safe-area + offset
  // increased offset to avoid overlapping on taller nav bars
  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 140.0, right: 8.0),
        child: FloatingActionButton(
          onPressed: () async {
          // show options: pick or manual add
          final choice = await showModalBottomSheet<int>(
            context: context,
            builder: (_) => SafeArea(
              child: Wrap(children: [
                ListTile(leading: const Icon(Icons.people), title: const Text('Pick from device contacts'), onTap: () => Navigator.of(context).pop(0)),
                ListTile(leading: const Icon(Icons.add), title: const Text('Add manually'), onTap: () => Navigator.of(context).pop(1)),
              ]),
            ),
          );

          if (choice == 0) await _pickDeviceContact();
          if (choice == 1) await _manualAdd();
          },
          backgroundColor: Colors.teal[400],
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }
}

class _ManualAddForm extends StatefulWidget {
  @override
  State<_ManualAddForm> createState() => _ManualAddFormState();
}

class _ManualAddFormState extends State<_ManualAddForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _role = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _role.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)), const Expanded(child: Center(child: Text('Add Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))), const SizedBox(width: 48)]),
          const SizedBox(height: 12),
          TextField(controller: _name, decoration: InputDecoration(hintText: 'Name', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 8),
          TextField(controller: _role, decoration: InputDecoration(hintText: 'Role (e.g., Veterinarian)', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 8),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: 'Phone', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final entry = ContactEntry(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _name.text.trim().isEmpty ? 'Untitled' : _name.text.trim(), role: _role.text.trim(), phone: _phone.text.trim(), avatar: null);
                Navigator.of(context).pop(entry);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.teal[400], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _EditContactForm extends StatefulWidget {
  final ContactEntry entry;
  const _EditContactForm({required this.entry});

  @override
  State<_EditContactForm> createState() => _EditContactFormState();
}

class _EditContactFormState extends State<_EditContactForm> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _role;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.entry.name);
    _phone = TextEditingController(text: widget.entry.phone);
    _role = TextEditingController(text: widget.entry.role);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _role.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)), const Expanded(child: Center(child: Text('Edit Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))), const SizedBox(width: 48)]),
          const SizedBox(height: 12),
          TextField(controller: _name, decoration: InputDecoration(hintText: 'Name', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 8),
          TextField(controller: _role, decoration: InputDecoration(hintText: 'Role (e.g., Veterinarian)', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 8),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: 'Phone', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final updated = ContactEntry(id: widget.entry.id, name: _name.text.trim().isEmpty ? 'Untitled' : _name.text.trim(), role: _role.text.trim(), phone: _phone.text.trim(), avatar: widget.entry.avatar);
                Navigator.of(context).pop(updated);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.teal[400], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet_store.dart';
import '../models/pet.dart';
import 'pet_info_page.dart';
import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MyPetsPage extends StatelessWidget {
  const MyPetsPage({super.key});

  static const Color mintA = Color(0xFF97E8C6);
  static const Color mintB = Color(0xFF7FE1B6);
  static const Color bgMint = Color(0xFFF3FBF7);

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<PetStore>().all;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, bgMint], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: centered title with Arduino indicator on the right
                SizedBox(
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: const Text('MyPets', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      ),
                      // (Removed) Arduino connected indicator
                      // optional left back button (go to home)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Added Pets list
                const Text('Added Pets', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Expanded(
                  child: pets.isEmpty
                      ? Center(child: Text('No pets added yet. Add one below.', style: TextStyle(color: Colors.grey[600])))
                      : ListView.separated(
                          itemCount: pets.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            final p = pets[i];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetInfoPage(pet: p))),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: p.avatarColor,
                                        child: (p.photoPath != null && File(p.photoPath!).existsSync())
                                            ? ClipOval(
                                                child: Image.file(
                                                  File(p.photoPath!),
                                                  width: 56,
                                                  height: 56,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Text(
                                                _initials(p.name),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 6),
                                          Text(p.breed.isEmpty ? 'Unknown breed' : p.breed, style: TextStyle(color: Colors.grey[600])),
                                        ]),
                                      ),
                                      // Edit / Delete actions
                                      Row(children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.black54),
                                          onPressed: () => _showEditPetModal(context, p),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          onPressed: () => _confirmDelete(context, p),
                                        ),
                                      ])
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 14),
                // Add a New Pet form trigger
                const Text('Add a New Pet', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showAddPetModal(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      backgroundColor: mintB,
                    ),
                    child: const Text('Add Pet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),

                const SizedBox(height: 14),

                // Local in-page navigation bar (MyPets, Contacts, Calendar, Alerts)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        icon: Icons.pets,
                        label: 'MyPets',
                        active: true,
                        onTap: () {},
                      ),
                      _NavItem(
                        icon: Icons.phone_outlined,
                        label: 'Contacts',
                        active: false,
                        onTap: () => Navigator.of(context).pushNamed('/contact'),
                      ),
                      _NavItem(
                        icon: Icons.calendar_today,
                        label: 'Calendar',
                        active: false,
                        onTap: () => Navigator.of(context).pushNamed('/calendar'),
                      ),
                      _NavItem(
                        icon: Icons.notifications_none,
                        label: 'Alerts',
                        active: false,
                        onTap: () => Navigator.of(context).pushNamed('/alerts'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, min(2, parts.first.length)).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _showAddPetModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _AddPetForm(),
      ),
    );
  }

  void _showEditPetModal(BuildContext ctx, Pet pet) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _EditPetForm(pet: pet),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, Pet pet) {
    showDialog(
      context: ctx,
      builder: (d) => AlertDialog(
        title: Text('Delete ${pet.name}?'),
        content: const Text('This action will permanently remove the pet.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(d).pop();
              ctx.read<PetStore>().remove(pet.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AddPetForm extends StatefulWidget {
  const _AddPetForm();

  @override
  State<_AddPetForm> createState() => _AddPetFormState();
}

class _AddPetFormState extends State<_AddPetForm> {
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _age = TextEditingController();
  final _colour = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  String _gender = 'Male';
  Color _avatarColor = const Color(0xFF97E8C6);
  String? _photoPath;
  final _formKey = GlobalKey<FormState>();

  static const _genderOptions = ['Male', 'Female'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
                const Expanded(child: Center(child: Text('Add Pet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            // Add Photo area (placeholder initials + color picker)
            Center(
              child: Column(children: [
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: _avatarColor,
                    child: _photoPath != null && File(_photoPath!).existsSync()
                        ? ClipOval(
                            child: Image.file(
                              File(_photoPath!),
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            MyPetsPage._initials(_name.text.isEmpty ? 'Pet' : _name.text),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('+ Add Photo (tap avatar)', style: TextStyle(color: Colors.black54)),
              ]),
            ),
            const SizedBox(height: 12),
            // inputs
            _buildField(_name, 'Pet Name'),
            const SizedBox(height: 8),
            _buildField(_breed, 'Breed Name'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildDropdownGender()),
              const SizedBox(width: 8),
              Expanded(child: _buildField(_age, 'Age')),
            ]),
            const SizedBox(height: 8),
            _buildField(_colour, 'Colour'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField(_height, 'Height')),
              const SizedBox(width: 8),
              Expanded(child: _buildField(_weight, 'Weight')),
            ]),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  backgroundColor: const Color(0xFF04BFBF),
                ),
                child: const Text('Add Pet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String placeholder) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        hintText: placeholder,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => null,
    );
  }

  Widget _buildDropdownGender() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<String>(
        value: _gender,
        isExpanded: true,
        underline: const SizedBox(),
        items: _AddPetFormState._genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _gender = v ?? _gender),
      ),
    );
  }

  void _chooseAvatarColor() {
    // simple color cycle for prototype
    final colors = [const Color(0xFF97E8C6), const Color(0xFFF6C77D), const Color(0xFF9FD8F8), const Color(0xFFBE9CF6)];
    setState(() => _avatarColor = colors[Random().nextInt(colors.length)]);
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
      if (file == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final filename = 'pet_${DateTime.now().millisecondsSinceEpoch}${pathExtension(file.path)}';
      final saved = await File(file.path).copy('${appDir.path}/$filename');
      setState(() => _photoPath = saved.path);
    } catch (e) {
      // ignore errors for now
      debugPrint('Image pick error: $e');
    }
  }

  String pathExtension(String p) {
    final idx = p.lastIndexOf('.');
    return idx == -1 ? '' : p.substring(idx);
  }

  void _save() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final pet = Pet(
      id: id,
      name: _name.text.trim().isEmpty ? 'Untitled' : _name.text.trim(),
      breed: _breed.text.trim(),
      gender: _gender,
      age: _age.text.trim(),
      colour: _colour.text.trim(),
      height: _height.text.trim(),
      weight: _weight.text.trim(),
      avatarColor: _avatarColor,
      photoPath: _photoPath,
    );
    context.read<PetStore>().add(pet);
    Navigator.of(context).pop();
  }
}

class _EditPetForm extends StatefulWidget {
  final Pet pet;
  const _EditPetForm({required this.pet});

  @override
  State<_EditPetForm> createState() => _EditPetFormState();
}

class _EditPetFormState extends State<_EditPetForm> {
  late final TextEditingController _name;
  late final TextEditingController _breed;
  late final TextEditingController _age;
  late final TextEditingController _colour;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  String _gender = 'Male';
  late Color _avatarColor;
  String? _photoPath;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    _name = TextEditingController(text: p.name);
    _breed = TextEditingController(text: p.breed);
    _age = TextEditingController(text: p.age);
    _colour = TextEditingController(text: p.colour);
    _height = TextEditingController(text: p.height);
    _weight = TextEditingController(text: p.weight);
    _gender = p.gender.isEmpty ? 'Male' : p.gender;
    _avatarColor = p.avatarColor;
    _photoPath = p.photoPath;
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _age.dispose();
    _colour.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
                const Expanded(child: Center(child: Text('Edit Pet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Column(children: [
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: _avatarColor,
                    child: _photoPath != null && File(_photoPath!).existsSync()
                        ? ClipOval(
                            child: Image.file(
                              File(_photoPath!),
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            MyPetsPage._initials(_name.text.isEmpty ? 'Pet' : _name.text),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('+ Change Photo (tap avatar)', style: TextStyle(color: Colors.black54)),
              ]),
            ),
            const SizedBox(height: 12),
            _buildField(_name, 'Pet Name'),
            const SizedBox(height: 8),
            _buildField(_breed, 'Breed Name'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildDropdownGender()),
              const SizedBox(width: 8),
              Expanded(child: _buildField(_age, 'Age')),
            ]),
            const SizedBox(height: 8),
            _buildField(_colour, 'Colour'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildField(_height, 'Height')),
              const SizedBox(width: 8),
              Expanded(child: _buildField(_weight, 'Weight')),
            ]),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  backgroundColor: const Color(0xFF04BFBF),
                ),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String placeholder) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        hintText: placeholder,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => null,
    );
  }

  Widget _buildDropdownGender() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<String>(
        value: _gender,
        isExpanded: true,
        underline: const SizedBox(),
        items: _AddPetFormState._genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _gender = v ?? _gender),
      ),
    );
  }

  void _chooseAvatarColor() {
    final colors = [const Color(0xFF97E8C6), const Color(0xFFF6C77D), const Color(0xFF9FD8F8), const Color(0xFFBE9CF6)];
    setState(() => _avatarColor = colors[Random().nextInt(colors.length)]);
  }

  void _save() {
    final updated = Pet(
      id: widget.pet.id,
      name: _name.text.trim().isEmpty ? 'Untitled' : _name.text.trim(),
      breed: _breed.text.trim(),
      gender: _gender,
      age: _age.text.trim(),
      colour: _colour.text.trim(),
      height: _height.text.trim(),
      weight: _weight.text.trim(),
      avatarColor: _avatarColor,
      photoPath: _photoPath,
    );
    context.read<PetStore>().update(updated);
    Navigator.of(context).pop();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
      if (file == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final filename = 'pet_${DateTime.now().millisecondsSinceEpoch}${pathExtension(file.path)}';
      final saved = await File(file.path).copy('${appDir.path}/$filename');
      setState(() => _photoPath = saved.path);
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  String pathExtension(String p) {
    final idx = p.lastIndexOf('.');
    return idx == -1 ? '' : p.substring(idx);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF7FE1B6);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? activeColor : Colors.white,
              boxShadow: active ? [BoxShadow(color: activeColor.withOpacity(0.22), blurRadius: 10, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
              border: Border.all(color: active ? activeColor.withOpacity(0.18) : Colors.grey.withOpacity(0.08), width: 2),
            ),
            child: Icon(icon, color: active ? Colors.white : Colors.black54, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.black87 : Colors.black54)),
        ],
      ),
    );
  }
}
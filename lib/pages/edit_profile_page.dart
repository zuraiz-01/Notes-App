// ignore_for_file: await_only_futures

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/pages/login_page.dart';
import '../auth/delete_user_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  bool loading = true;
  File? _imageFile;
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  // 🔹 Load profile from Supabase
  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => loading = true);

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          nameController.text = response['name'] ?? '';
          bioController.text = response['bio'] ?? '';
          _avatarUrl = response['avatar_url'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // 🔹 Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (picked != null && mounted) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  // 🔹 Save profile updates
  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => loading = true);
    String? imagePath;

    // Upload image if selected
    if (_imageFile != null) {
      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        await supabase.storage
            .from('avatars')
            .upload(
              fileName,
              _imageFile!,
              fileOptions: const FileOptions(upsert: true),
            );

        imagePath = supabase.storage.from('avatars').getPublicUrl(fileName);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
          setState(() => loading = false);
          return;
        }
      }
    }

    // Update profile
    try {
      final updates = {
        'id': user.id,
        'name': nameController.text.trim(),
        'bio': bioController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        if (imagePath != null) 'avatar_url': imagePath,
      };

      await supabase.from('profiles').upsert(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action will permanently delete your account and all associated data. Are you sure you want to continue?',
        ),
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

    if (!mounted) return;
    setState(() => loading = true);

    try {
      // ✅ Get current user
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final userId = user.id;
      print('🔍 Deleting user with ID: $userId');

      // ✅ Supabase automatically adds authorization headers
      final response = await supabase.functions.invoke(
        'delete-user',
        body: {'user_id': userId},
      );

      print('📊 Response status: ${response.status}');
      print('📊 Response data: ${response.data}');

      if (response.status != 200) {
        final error = response.data is Map
            ? (response.data['error'] ?? 'Unknown error')
            : response.data.toString();
        throw Exception(error);
      }

      // ✅ Sign out the user
      await supabase.auth.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      print('❌ Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFFF5F6FA);
    final Color card = Colors.white;
    final Color accent = const Color(0xFF9C8EF3);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            title: const Text(
              "Edit Profile",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    child: Column(
                      children: [
                        // 🖼 Profile Image
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: bg,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_avatarUrl != null
                                            ? NetworkImage(_avatarUrl!)
                                            : null)
                                        as ImageProvider?,
                              child: _imageFile == null && _avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 55,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // 🧑 Name Field
                        _inputField(
                          controller: nameController,
                          hint: "Full Name",
                          icon: Icons.person_outline,
                          accent: accent,
                        ),
                        const SizedBox(height: 20),

                        // 📝 Bio Field
                        _inputField(
                          controller: bioController,
                          hint: "Bio",
                          icon: Icons.info_outline,
                          accent: accent,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 30),

                        // 💾 Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ❌ Delete Account Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: loading ? null : _confirmDelete,
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Delete Account',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // 🔹 Loading Overlay
        if (loading)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  // 🔹 Input Field Builder
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color accent,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF0F1F5),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: accent),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

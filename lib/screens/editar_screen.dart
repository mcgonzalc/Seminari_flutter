import 'package:flutter/material.dart';
import 'package:seminari_flutter/models/user.dart';
import 'package:seminari_flutter/services/UserService.dart';
import 'package:seminari_flutter/widgets/Layout.dart';

class EditarScreen extends StatefulWidget {
  final String userId;
  const EditarScreen({super.key, required this.userId});

  @override
  State<EditarScreen> createState() => _EditarScreenState();
}

class _EditarScreenState extends State<EditarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final edatController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final User? user = await UserService.getUserById(widget.userId);
      if (user != null) {
        nomController.text = user.name;
        edatController.text = user.age.toString();
        emailController.text = user.email;
      }
    } catch (e) {
      debugPrint('Error carregant usuari: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User user = await UserService.getUserById(widget.userId);
      if (user.password != passwordController.text){
        return;
      }

      user.name = nomController.text;
      user.email = emailController.text;
      if (int.tryParse(edatController.text) != null)
      {
          user.age = int.tryParse(edatController.text) ?? 0;
      }
      bool success = await UserService.updateUser(
        widget.userId,
        user
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuari actualitzat correctament')),
        );
        // Pots fer navegació o altres accions després
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No s\'ha pogut actualitzar l\'usuari')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    edatController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWrapper(
      title: 'Editar usuari',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFormField(
                          controller: nomController,
                          label: 'Nom',
                          icon: Icons.person,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Cal omplir el nom' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: edatController,
                          label: 'Edat',
                          icon: Icons.cake,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Cal omplir l\'edat';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age < 0) {
                              return 'Si us plau, insereix una edat vàlida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: emailController,
                          label: 'Correu electrònic',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El correu electrònic no pot estar buit';
                            }
                            if (!value.contains('@')) {
                              return 'Si us plau insereix una adreça vàlida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: passwordController,
                          label: 'Contrasenya',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La contrasenya no pot estar buida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Actualitzar usuari',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
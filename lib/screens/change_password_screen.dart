import 'package:flutter/material.dart';
import '../services/UserService.dart'; // Ajusta el path segons el teu projecte
import '/models/user.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String userId;

  const ChangePasswordScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les contrasenyes noves no coincideixen')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User user = await UserService.getUserById(widget.userId);
      user.password = _newPasswordController.text;
      bool success = await UserService.updateUser(
        widget.userId,
        user
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contrasenya canviada correctament')),
        );
        Navigator.pop(context); // Torna enrere després d’èxit
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error canviant la contrasenya')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canviar contrasenya')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(labelText: 'Contrasenya antiga'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Introdueix la contrasenya antiga' : null,
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'Nova contrasenya'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Introdueix la nova contrasenya' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirma la nova contrasenya'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Confirma la nova contrasenya' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Canviar contrasenya'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
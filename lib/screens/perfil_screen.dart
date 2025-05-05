import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:seminari_flutter/models/user.dart';
import 'package:seminari_flutter/provider/user_auth_provider.dart';
import 'package:seminari_flutter/services/UserService.dart';
import 'package:seminari_flutter/services/auth_service.dart';
import '../widgets/Layout.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  User? userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = Provider.of<UserAuthProvider>(context, listen: false);
      final userId = user.userId;

      if (userId == null || userId.isEmpty) {
        setState(() {
          _error = 'Usuari no autenticat';
          _isLoading = false;
        });
        return;
      }

      final profile = await UserService.getUserById(userId);
      setState(() {
        userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error carregant perfil: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserAuthProvider>(context);

    if (_isLoading) {
      return LayoutWrapper(
        title: 'Perfil',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return LayoutWrapper(
        title: 'Perfil',
        child: Center(child: Text(_error!)),
      );
    }

    // Si no tenim perfil carregat, podem mostrar missatge o fallback
    if (userProfile == null) {
      return LayoutWrapper(
        title: 'Perfil',
        child: const Center(child: Text('No s\'ha trobat l\'usuari')),
      );
    }

    return LayoutWrapper(
      title: 'Perfil',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    userProfile!.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProfile!.email,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildProfileItem(
                            context,
                            Icons.badge,
                            'Nom',
                            userProfile!.name,
                          ),
                          const Divider(),
                          _buildProfileItem(
                              context, 
                              Icons.cake, 
                              'Edat', 
                              userProfile!.age.toString()),
                           const Divider(),
                          _buildProfileItem(
                              context, 
                              Icons.email, 
                              'Correu electrònic', 
                              userProfile!.email),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuració del compte',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildSettingItem(
                            context,
                            Icons.edit,
                            'Editar Perfil',
                            'Actualitza la teva informació personal',
                            '/editar',
                            extra: user.userId,
                          ),
                          _buildSettingItem(
                            context,
                            Icons.lock,
                            'Canviar contrasenya',
                            'Actualitzar la contrasenya',
                            '/editarcontrasena',
                            extra: user.userId,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final authService = AuthService();
                        authService.logout();
                        context.go('/login');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al tancar sessió: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('TANCAR SESSIÓ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String route, {
    Object? extra,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        if (extra != null) {
          context.go(route, extra: extra);
        } else {
          context.go(route);
        }
      },
    );
  }
}

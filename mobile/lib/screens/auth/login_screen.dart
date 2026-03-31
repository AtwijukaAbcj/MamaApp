import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mama_app/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();
  final _serverController = TextEditingController(text: 'https://api.mamaapp.health');
  
  bool _isLoading = false;
  bool _showServerConfig = false;
  bool _isPatientMode = false;
  bool _isRegisterMode = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    _nameController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    final auth = ref.read(authActionsProvider);
    await auth.configure(_serverController.text.trim());
    
    LoginResult result;
    
    if (_isPatientMode) {
      if (_isRegisterMode) {
        result = await auth.registerAsPatient(
          phone: _phoneController.text.trim(),
          pin: _pinController.text.trim(),
          fullName: _nameController.text.trim(),
        );
      } else {
        result = await auth.loginAsPatient(
          phone: _phoneController.text.trim(),
          pin: _pinController.text.trim(),
        );
      }
    } else {
      result = await auth.login(
        phone: _phoneController.text.trim(),
        pin: _pinController.text.trim(),
      );
    }
    
    setState(() => _isLoading = false);
    
    if (!result.success) {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                
                Icon(
                  Icons.pregnant_woman,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                
                Text(
                  'MamaApp',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  _isPatientMode 
                    ? (_isRegisterMode ? 'Patient Registration' : 'Patient Login')
                    : 'Health Worker Login',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                
                // User type toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isPatientMode = false;
                            _isRegisterMode = false;
                            _error = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isPatientMode 
                                ? Theme.of(context).primaryColor 
                                : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 20,
                                  color: !_isPatientMode ? Colors.white : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Health Worker',
                                  style: TextStyle(
                                    color: !_isPatientMode ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isPatientMode = true;
                            _error = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isPatientMode 
                                ? Colors.pink 
                                : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 20,
                                  color: _isPatientMode ? Colors.white : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Patient',
                                  style: TextStyle(
                                    color: _isPatientMode ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                if (_isPatientMode) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _isRegisterMode = false),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: !_isRegisterMode ? FontWeight.bold : FontWeight.normal,
                            decoration: !_isRegisterMode ? TextDecoration.underline : null,
                          ),
                        ),
                      ),
                      const Text(' | '),
                      TextButton(
                        onPressed: () => setState(() => _isRegisterMode = true),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontWeight: _isRegisterMode ? FontWeight.bold : FontWeight.normal,
                            decoration: _isRegisterMode ? TextDecoration.underline : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (_isPatientMode && _isRegisterMode) ...[
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'Enter your full name',
                    ),
                    validator: (value) {
                      if (_isRegisterMode && (value == null || value.isEmpty)) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '+256...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: _isPatientMode ? 4 : 6,
                  decoration: InputDecoration(
                    labelText: _isPatientMode ? '4-Digit PIN' : 'PIN',
                    prefixIcon: const Icon(Icons.lock),
                    counterText: '',
                    helperText: _isPatientMode && _isRegisterMode 
                      ? 'Create a 4-digit PIN you will remember' 
                      : null,
                  ),
                  validator: (value) {
                    if (value == null || value.length < 4) {
                      return 'PIN must be at least 4 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!, style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _isPatientMode ? Colors.pink : null,
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isPatientMode 
                          ? (_isRegisterMode ? 'Create Account' : 'Login as Patient')
                          : 'Login as Health Worker',
                        style: const TextStyle(fontSize: 16),
                      ),
                ),
                const SizedBox(height: 24),
                
                if (_isPatientMode) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.watch, color: Colors.pink.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Self-Monitoring Features',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _featureRow(Icons.favorite, 'Heart rate from Apple Watch'),
                        _featureRow(Icons.air, 'Blood oxygen (SpO2) monitoring'),
                        _featureRow(Icons.notifications_active, 'Automatic danger alerts'),
                        _featureRow(Icons.sync, 'Data synced to your health worker'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                TextButton.icon(
                  onPressed: () => setState(() => _showServerConfig = !_showServerConfig),
                  icon: Icon(_showServerConfig ? Icons.expand_less : Icons.expand_more),
                  label: const Text('Server Configuration'),
                ),
                
                if (_showServerConfig) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _serverController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      prefixIcon: Icon(Icons.dns),
                      helperText: 'Only change if instructed by administrator',
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

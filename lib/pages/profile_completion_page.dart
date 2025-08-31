import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_service.dart';
import '../auth_service.dart';
import '../producer_provider.dart';
import 'home_page.dart';

class ProfileCompletionPage extends StatefulWidget {
  final bool isEditing;
  const ProfileCompletionPage({Key? key, this.isEditing = false}) : super(key: key);

  @override
  _ProfileCompletionPageState createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _orgNameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final producer = Provider.of<ProducerProvider>(context, listen: false).producer;
    _orgNameController = TextEditingController(text: widget.isEditing ? producer?.organizationName : '');
    _phoneController = TextEditingController(text: widget.isEditing ? producer?.phone : '');
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final apiService = Provider.of<ApiService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final producerProvider = Provider.of<ProducerProvider>(context, listen: false);

      try {
        if (widget.isEditing) {
          // Update existing producer
          final producer = producerProvider.producer!;
          await apiService.updateProducer(producer.id, {
            'organization_name': _orgNameController.text,
            'phone': _phoneController.text,
          });
        } else {
          // Create new producer
          final user = authService.user!;
          await apiService.createProducer(
            googleUid: user.uid,
            userName: user.displayName ?? 'No Name',
            email: user.email!,
            organizationName: _orgNameController.text,
            phone: _phoneController.text,
          );
        }

        // Refresh producer data
        final updatedProducerData = await apiService.getProducer(authService.user!.uid);
        if (updatedProducerData != null) {
          producerProvider.setProducer(updatedProducerData);
        }

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Profile' : 'Complete Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _orgNameController,
                decoration: const InputDecoration(labelText: 'Organization Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your organization name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone (Optional)'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(widget.isEditing ? 'Update Profile' : 'Save Profile'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

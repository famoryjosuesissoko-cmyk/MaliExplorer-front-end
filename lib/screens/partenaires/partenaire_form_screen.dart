import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class PartenaireFormScreen extends StatefulWidget {
  const PartenaireFormScreen({super.key});

  @override
  State<PartenaireFormScreen> createState() => _PartenaireFormScreenState();
}

class _PartenaireFormScreenState extends State<PartenaireFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devenir Partenaire')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Nom ou Organisation',
                controller: _nomController,
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                label: 'Contact (Email / Tél)',
                controller: _contactController,
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppDimensions.xl),
              AppButton(
                text: 'Soumettre la candidature',
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Candidature envoyée avec succès')),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

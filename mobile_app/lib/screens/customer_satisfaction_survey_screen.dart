import 'package:flutter/material.dart';
import '../theme/djezzy_theme.dart';

class CustomerSatisfactionSurveyScreen extends StatefulWidget {
  const CustomerSatisfactionSurveyScreen({super.key});

  @override
  State<CustomerSatisfactionSurveyScreen> createState() => _CustomerSatisfactionSurveyScreenState();
}

class _CustomerSatisfactionSurveyScreenState extends State<CustomerSatisfactionSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSatisfaction = 'Neutre';
  final _commentController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rapport soumis au service client !'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: DjezzyTheme.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Customer Survey', style: TextStyle(color: DjezzyTheme.darkText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enquête de Satisfaction',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rapport de plainte ou retour client suite à un problème de réseau.',
                style: TextStyle(color: DjezzyTheme.lightText, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              const Text('Numéro de téléphone du client', style: TextStyle(fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _buildInputDecoration('Ex: 0770 XX XX XX'),
                validator: (val) => val == null || val.isEmpty ? 'Numéro requis' : null,
              ),
              const SizedBox(height: 16),
              
              const Text('Niveau de satisfaction', style: TextStyle(fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSatisfaction,
                decoration: _buildInputDecoration(''),
                items: const [
                  DropdownMenuItem(value: 'Très Insatisfait', child: Text('Très Insatisfait')),
                  DropdownMenuItem(value: 'Insatisfait', child: Text('Insatisfait')),
                  DropdownMenuItem(value: 'Neutre', child: Text('Neutre')),
                ],
                onChanged: (val) => setState(() => _selectedSatisfaction = val!),
              ),
              const SizedBox(height: 16),

              const Text('Commentaire / Plainte', style: TextStyle(fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                decoration: _buildInputDecoration('Ex: Le client se plaint d\'une mauvaise 4G depuis hier...'),
                validator: (value) {
                  if ((_selectedSatisfaction == 'Insatisfait' || _selectedSatisfaction == 'Très Insatisfait') && (value == null || value.trim().isEmpty)) {
                    return 'Un commentaire est obligatoire en cas d\'insatisfaction';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DjezzyTheme.primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ENVOYER LE RAPPORT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}

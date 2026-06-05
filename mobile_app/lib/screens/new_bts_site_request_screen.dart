import 'package:flutter/material.dart';
import '../theme/djezzy_theme.dart';

class NewBtsSiteRequestScreen extends StatefulWidget {
  const NewBtsSiteRequestScreen({super.key});

  @override
  State<NewBtsSiteRequestScreen> createState() => _NewBtsSiteRequestScreenState();
}

class _NewBtsSiteRequestScreenState extends State<NewBtsSiteRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande envoyée au département ingénierie !'), backgroundColor: Colors.green));
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
        title: const Text('New BTS Request', style: TextStyle(color: DjezzyTheme.darkText, fontWeight: FontWeight.bold, fontSize: 18)),
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
                'Demande de nouveau site BTS',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText),
              ),
              const SizedBox(height: 8),
              const Text(
                'Remplissez ce formulaire pour proposer l\'installation d\'une nouvelle antenne relais dans une zone non couverte.',
                style: TextStyle(color: DjezzyTheme.lightText, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                decoration: _buildInputDecoration('Localisation (Wilaya / Commune)', 'Ex: Alger, Bab Ezzouar'),
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                decoration: _buildInputDecoration('Coordonnées GPS estimées (Lat, Long)', 'Ex: 36.711, 3.188'),
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: _buildInputDecoration('Raison de la demande', 'Ex: Zone blanche, forte densité de population...'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez expliquer la raison';
                  }
                  if (value.trim().length < 30) {
                    return 'La raison doit contenir au moins 30 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration('Type d\'antenne recommandé', ''),
                items: const [
                  DropdownMenuItem(value: 'Macro', child: Text('Macro-cell (Large couverture)')),
                  DropdownMenuItem(value: 'Micro', child: Text('Micro-cell (Zone urbaine dense)')),
                ],
                onChanged: (val) {},
                validator: (val) => val == null ? 'Sélection requise' : null,
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
                  child: const Text('SOUMETTRE LA DEMANDE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/djezzy_theme.dart';
import '../providers/bts_provider.dart';

class ReportBtsFailureScreen extends StatefulWidget {
  const ReportBtsFailureScreen({super.key});

  @override
  State<ReportBtsFailureScreen> createState() => _ReportBtsFailureScreenState();
}

class _ReportBtsFailureScreenState extends State<ReportBtsFailureScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBts;
  String _selectedSeverity = 'HAUTE';
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // S'assurer que les antennes sont chargées
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final btsProvider = Provider.of<BtsProvider>(context, listen: false);
      if (btsProvider.btsList.isEmpty) {
        btsProvider.fetchBtsList();
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBts == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une antenne'), backgroundColor: Colors.orange));
        return;
      }
      
      setState(() => _isSubmitting = true);
      
      bool success = await Provider.of<BtsProvider>(context, listen: false)
          .reportFailure(_selectedBts!, _selectedSeverity, _descriptionController.text);
      
      if (!mounted) return;
      
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alerte NOC : Panne déclarée sur $_selectedBts ! L\'antenne est maintenant en DELAYED.'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context); // Retourner à l'écran précédent
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur : Impossible de déclarer la panne. Vérifiez que l\'antenne existe bien dans la base.'), backgroundColor: Colors.orange),
        );
      }
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
        title: const Text('Report BTS Failure', style: TextStyle(color: DjezzyTheme.darkText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Consumer<BtsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.btsList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: DjezzyTheme.primaryRed));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Signaler une Panne',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Veuillez remplir ce formulaire de manière précise pour que le NOC puisse intervenir rapidement.',
                    style: TextStyle(color: DjezzyTheme.lightText, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  // BTS Selection
                  const Text('Sélectionner le site BTS', style: TextStyle(fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedBts,
                    hint: const Text('Choisir une antenne...'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: provider.btsList.map((bts) => DropdownMenuItem(value: bts.btsId, child: Text('${bts.btsId} (${bts.statut})'))).toList(),
                    onChanged: (val) => setState(() => _selectedBts = val),
                    validator: (value) => value == null ? 'Requis' : null,
                  ),
              const SizedBox(height: 24),

              // Severity
              const Text('Niveau de Sévérité', style: TextStyle(fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSeverity,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'HAUTE', child: Text('HAUTE (Coupure de service)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  DropdownMenuItem(value: 'MOYENNE', child: Text('MOYENNE (Dégradation)', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                  DropdownMenuItem(value: 'FAIBLE', child: Text('FAIBLE (Alarme mineure)', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                ],
                onChanged: (val) => setState(() => _selectedSeverity = val!),
              ),
              const SizedBox(height: 24),

              // Description
              const Text('Description du problème', style: TextStyle(fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Ex: Le redresseur principal est tombé en panne suite à une coupure de courant...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez décrire le problème';
                  }
                  if (value.trim().length < 20) {
                    return 'La description doit contenir au moins 20 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Photo Upload
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12, style: BorderStyle.solid),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.camera_alt_outlined, color: DjezzyTheme.lightText, size: 40),
                    SizedBox(height: 8),
                    Text('Ajouter une photo (Optionnel)', style: TextStyle(color: DjezzyTheme.darkText, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DjezzyTheme.primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SOUMETTRE LE RAPPORT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
      },
      ),
    );
  }
}

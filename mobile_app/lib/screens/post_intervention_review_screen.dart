import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/djezzy_theme.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class PostInterventionReviewScreen extends StatefulWidget {
  final Task? task;
  const PostInterventionReviewScreen({super.key, this.task});

  @override
  State<PostInterventionReviewScreen> createState() => _PostInterventionReviewScreenState();
}

class _PostInterventionReviewScreenState extends State<PostInterventionReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTask;
  String _selectedStatus = 'Succès';
  final _notesController = TextEditingController();

  final List<String> _tasksList = [
    'Tâche #1042 - Remplacement redresseur',
    'Tâche #1045 - Vérification climatisation',
    'Tâche #1048 - Câblage fibre optique'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _selectedTask = 'Tâche #${widget.task!.taskId} - ${widget.task!.btsId}';
      if (!_tasksList.contains(_selectedTask)) {
        _tasksList.insert(0, _selectedTask!);
      }
    } else {
      _selectedTask = _tasksList.first;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (widget.task != null) {
        // Appelle l'API réelle pour clôturer l'intervention et passer en ON AIR
        bool success = await Provider.of<TaskProvider>(context, listen: false)
            .closeIntervention(widget.task!.taskId, widget.task!.btsId);
        
        if (!mounted) return;
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Intervention clôturée et rapport soumis !'), backgroundColor: Colors.green),
          );
          context.pop(); // Retour à la page précédente
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la clôture.'), backgroundColor: Colors.red),
          );
        }
      } else {
        // Mode démo (depuis Forms Center)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revue post-intervention soumise avec succès ! (Mode Démo)'), backgroundColor: Colors.green),
        );
        context.pop();
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
          onPressed: () => context.pop(),
        ),
        title: const Text('Post-Intervention', style: TextStyle(color: DjezzyTheme.darkText, fontWeight: FontWeight.bold, fontSize: 18)),
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
                'Revue Post-Intervention',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText),
              ),
              const SizedBox(height: 8),
              const Text(
                'Confirmez la résolution du problème et ajoutez les notes de clôture.',
                style: TextStyle(color: DjezzyTheme.lightText, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              const Text('Tâche ciblée', style: TextStyle(fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTask,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _tasksList.map((task) => DropdownMenuItem(value: task, child: Text(task, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: widget.task == null ? (val) => setState(() => _selectedTask = val!) : null, // Grisé si une tâche est déjà passée
              ),
              const SizedBox(height: 24),

              const Text('Statut de Résolution', style: TextStyle(fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'Succès', child: Text('Succès - Problème résolu', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  DropdownMenuItem(value: 'Partiel', child: Text('Partiel - Nécessite un suivi', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                  DropdownMenuItem(value: 'Échec', child: Text('Échec - Escalade requise', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                ],
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 24),

              const Text('Notes de clôture (Travaux réalisés)', style: TextStyle(fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Détaillez les actions entreprises...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez ajouter des notes de clôture';
                  }
                  if (value.trim().length < 10) {
                    return 'Les notes doivent contenir au moins 10 caractères';
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
                  child: const Text('CLÔTURER L\'INTERVENTION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

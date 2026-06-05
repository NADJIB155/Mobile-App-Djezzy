import 'package:flutter/material.dart';
import '../theme/djezzy_theme.dart';

class AssistanceScreen extends StatefulWidget {
  final String btsId;
  const AssistanceScreen({super.key, required this.btsId});

  @override
  State<AssistanceScreen> createState() => _AssistanceScreenState();
}

class _AssistanceScreenState extends State<AssistanceScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Bonjour, ici le NOC Djezzy. Je vois que vous êtes assigné sur l\'antenne ',
      'time': '10:00'
    },
    {
      'isMe': false,
      'text': 'La télémétrie indique un problème de VSWR sur le secteur 2. Avez-vous besoin du schéma de câblage ?',
      'time': '10:01'
    }
  ];

  @override
  void initState() {
    super.initState();
    _messages[0]['text'] += widget.btsId + '. Comment puis-je vous aider ?';
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'isMe': true,
        'text': _chatController.text.trim(),
        'time': 'Maintenant'
      });
      _chatController.clear();
    });
    
    // Simuler une réponse du NOC après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'isMe': false,
            'text': 'Bien reçu. Je vous envoie la documentation technique en P.J. Faites attention lors du redémarrage du module RRU.',
            'time': 'Maintenant'
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assistance NOC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Antenne ${widget.btsId}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lancement Appel Visio... (Simulation)'), backgroundColor: Colors.green));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.green.withOpacity(0.1),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Expert NOC en ligne (Temps d\'attente estimé : < 1 min)', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'];
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? DjezzyTheme.primaryRed : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(color: isMe ? Colors.white : DjezzyTheme.darkText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: TextStyle(color: isMe ? Colors.white70 : DjezzyTheme.lightText, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: DjezzyTheme.lightText),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Écrivez votre message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: DjezzyTheme.primaryRed,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

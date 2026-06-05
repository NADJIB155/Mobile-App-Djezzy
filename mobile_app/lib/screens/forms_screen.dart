import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/djezzy_theme.dart';
import '../widgets/app_drawer.dart';

class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text('Forms Center', style: TextStyle(color: DjezzyTheme.darkText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TECHNICIAN FORMS',
              style: TextStyle(color: DjezzyTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildFormCard(context, 'Report BTS\nFailure', Icons.warning_rounded, color: DjezzyTheme.primaryRed, path: '/report-failure')),
                const SizedBox(width: 16),
                Expanded(child: _buildFormCard(context, 'Post-Intervention\nReview', Icons.edit_document, color: DjezzyTheme.primaryRed, path: '/task-review')),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'COMMERCIAL FORMS',
              style: TextStyle(color: DjezzyTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildFormCard(context, 'New BTS Site\nRequest', Icons.domain, color: DjezzyTheme.primaryRed, path: '/new-bts-site')),
                const SizedBox(width: 16),
                Expanded(child: _buildFormCard(context, 'Customer\nSatisfaction\nSurvey', Icons.person, color: DjezzyTheme.primaryRed, path: '/survey')),
              ],
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(selectedIndex: 2),
    );
  }

  Widget _buildFormCard(BuildContext context, String title, IconData icon, {required Color color, required String path}) {
    return InkWell(
      onTap: () => context.push(path),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFF5F5F5),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DjezzyTheme.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

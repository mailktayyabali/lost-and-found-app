import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SupportPage extends StatelessWidget {
  final String title;
  const SupportPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: May 2024',
              style: TextStyle(color: context.colors.textLight, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'Welcome to FoundIt. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us.',
            ),
            _buildSection(
              'Data Collection',
              'We collect personal information that you voluntarily provide to us when you register on the App, express an interest in obtaining information about us or our products and services, when you participate in activities on the App or otherwise when you contact us.',
            ),
            _buildSection(
              'Information Sharing',
              'We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.',
            ),
            _buildSection(
              'Contact Us',
              'If you have questions or comments about this policy, you may email us at support@foundit.app',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String heading, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

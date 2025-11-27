import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firebase_service.dart';
import 'cv_form_page.dart';

class CvListPage extends StatefulWidget {
  const CvListPage({super.key});

  @override
  State<CvListPage> createState() => _CvListPageState();
}

class _CvListPageState extends State<CvListPage> {
  final FirebaseService _svc = FirebaseService();

  void _showAddDialog([String? id, Map<String, dynamic>? data]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CvFormPage(docId: id, initialData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CVs')),
      body: StreamBuilder(
        stream: _svc.streamCvs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) return const Center(child: Text('No data'));
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No CVs yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? 'No name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['email'] ?? ''),
                    if (data['phone'] != null) Text('Phone: ${data['phone']}'),
                    if (data['resumeUrl'] != null) ...[
                      if (kIsWeb)
                        TextButton.icon(
                          onPressed: () async {
                            final url = data['resumeUrl'] as String;
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await launchUrl(
                                Uri.parse(url),
                                webOnlyWindowName: '_blank',
                              );
                            } catch (_) {
                              await Clipboard.setData(ClipboardData(text: url));
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not open preview — copied URL to clipboard',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.preview),
                          label: const Text('Preview'),
                        ),
                      TextButton.icon(
                        onPressed: () async {
                          final url = data['resumeUrl'] as String;
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final uri = Uri.parse(url);
                            final opened = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!opened) {
                              await Clipboard.setData(ClipboardData(text: url));
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not open URL — copied to clipboard',
                                  ),
                                ),
                              );
                            }
                          } catch (_) {
                            await Clipboard.setData(ClipboardData(text: url));
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not open URL — copied to clipboard',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open / Copy Resume URL'),
                      ),
                    ],
                    if (data['resumeBase64'] != null)
                      TextButton.icon(
                        onPressed: () {
                          final messenger = ScaffoldMessenger.of(context);
                          final name = data['resumeName'] ?? 'resume';
                          final b64 = data['resumeBase64'] as String;
                          final sizeKb = (b64.length * 3) / 4 / 1024;
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text('Resume: $name'),
                              content: Text(
                                'Stored in Firestore (${sizeKb.toStringAsFixed(1)} KB) as base64.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    final navigator = Navigator.of(
                                      dialogContext,
                                    );
                                    await Clipboard.setData(
                                      ClipboardData(text: b64),
                                    );
                                    navigator.pop();
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Base64 copied to clipboard',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Copy Base64'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.attach_file),
                        label: const Text('View Resume (Base64)'),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddDialog(doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _svc.deleteCv(doc.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

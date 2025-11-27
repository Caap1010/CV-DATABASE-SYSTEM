import 'package:flutter/material.dart';
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
                    if (data['resumeUrl'] != null)
                      TextButton.icon(
                        onPressed: () {
                          // On web the resumeUrl can be opened in a new tab; mobile will open in browser.
                          // Keep this placeholder; adding `url_launcher` dependency can improve behavior.
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Resume'),
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

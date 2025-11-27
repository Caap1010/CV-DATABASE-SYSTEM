import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class CvFormPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? initialData;
  const CvFormPage({super.key, this.docId, this.initialData});

  @override
  State<CvFormPage> createState() => _CvFormPageState();
}

class _CvFormPageState extends State<CvFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  String? _resumeName;
  final FirebaseService _svc = FirebaseService();

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      _nameCtrl.text = d['name'] ?? '';
      _emailCtrl.text = d['email'] ?? '';
      _phoneCtrl.text = d['phone'] ?? '';
      _summaryCtrl.text = d['summary'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    // File picking requires `file_picker` and storage configuration.
    // For now this is a placeholder so the form can still be used without file upload.
    // You can add `file_picker` and storage upload later and uncomment implementation.
    // ignore: avoid_print
    print(
      'File picker not configured. To enable, add `file_picker` and storage logic.',
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'summary': _summaryCtrl.text.trim(),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    // Note: resume upload is not enabled in this environment. If you add
    // `file_picker` and storage dependencies, upload here and set `resumeUrl`.

    if (widget.docId == null) {
      await _svc.addCv(payload);
    } else {
      await _svc.updateCv(widget.docId!, payload);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.docId == null ? 'Add CV' : 'Edit CV')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _summaryCtrl,
                decoration: const InputDecoration(labelText: 'Summary'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Upload resume'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _resumeName ??
                          widget.initialData?['resumeName'] ??
                          'No file selected',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Save CV')),
            ],
          ),
        ),
      ),
    );
  }
}

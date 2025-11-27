import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

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
  Uint8List? _resumeBytes;
  String? _resumeName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
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
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    if (result == null) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    // Basic validation: allow common document types and limit size to 5 MB for direct upload.
    final allowedExt = <String>{'pdf', 'doc', 'docx', 'txt'};
    final ext = (file.extension ?? file.name.split('.').last).toLowerCase();
    const maxUploadBytes = 5 * 1024 * 1024; // 5 MB
    if (!allowedExt.contains(ext)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unsupported file type. Use PDF/DOC/DOCX/TXT.'),
        ),
      );
      return;
    }
    if (file.size > maxUploadBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File too large (max 5 MB).')),
      );
      return;
    }
    setState(() {
      _resumeBytes = file.bytes;
      _resumeName = file.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final basePayload = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'summary': _summaryCtrl.text.trim(),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    String docId = widget.docId ?? '';
    DocumentReference? createdRef;
    if (docId.isEmpty) {
      createdRef = await _svc.addCv(basePayload);
      docId = createdRef.id;
    } else {
      await _svc.updateCv(docId, basePayload);
    }

    final payload = Map<String, dynamic>.from(basePayload);

    if (_resumeBytes != null) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });
      try {
        final url = await _svc.uploadResume(
          _resumeBytes!,
          _resumeName ?? 'resume',
          docId: docId,
          onProgress: (p) {
            // apply light smoothing for nicer UX
            if (mounted) {
              setState(() {
                _uploadProgress = (_uploadProgress * 0.75 + p * 0.25);
              });
            }
          },
        );
        payload['resumeUrl'] = url;
        payload['resumeName'] = _resumeName ?? '';
        await _svc.updateCv(docId, {
          'resumeUrl': url,
          'resumeName': _resumeName ?? '',
        });
      } catch (e) {
        final String msg = e.toString();
        if (_resumeBytes!.lengthInBytes <= 300 * 1024) {
          payload['resumeName'] = _resumeName ?? '';
          payload['resumeBase64'] = base64Encode(_resumeBytes!);
          await _svc.updateCv(docId, {
            'resumeName': payload['resumeName'],
            'resumeBase64': payload['resumeBase64'],
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload failed, saved resume as base64 fallback.'),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadProgress = 0.0;
          });
        }
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
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
              _isUploading
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(value: _uploadProgress),
                        const SizedBox(height: 8),
                        Text(
                          '${(_uploadProgress * 100).toStringAsFixed(0)}% uploading...',
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save CV'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

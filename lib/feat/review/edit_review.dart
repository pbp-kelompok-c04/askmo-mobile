import 'package:flutter/material.dart';
import '../../models/review.dart';
import 'review_repository.dart';

class EditReviewPage extends StatefulWidget {
  final Review review;
  const EditReviewPage({super.key, required this.review});

  @override
  State<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _ratingCtrl;
  late TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.review.name);
    _ratingCtrl = TextEditingController(text: widget.review.rating.toString());
    _textCtrl = TextEditingController(text: widget.review.text);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ratingCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final d = double.tryParse(_ratingCtrl.text.replaceAll(',', '.')) ?? widget.review.rating;
    final updated = widget.review.copyWith(name: _nameCtrl.text, rating: d, text: _textCtrl.text);
    ReviewRepository.instance.update(widget.review.id, updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Reviewer name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ratingCtrl,
                decoration: const InputDecoration(labelText: 'Rating (0.0 - 5.0)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (d == null || d < 0 || d > 5) return 'Enter 0.0-5.0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _textCtrl,
                decoration: const InputDecoration(labelText: 'Masukan dan Saran Anda'),
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF571E88)),
              )
            ],
          ),
        ),
      ),
    );
  }
}


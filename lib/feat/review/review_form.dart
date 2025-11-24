import 'package:flutter/material.dart';
import '../../models/review.dart';
import 'review_repository.dart';

class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({super.key});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ratingCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    final d = double.tryParse(_ratingCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final r = Review(
      id: id,
      name: _nameCtrl.text,
      text: _textCtrl.text,
      rating: d,
      date: '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}',
    );
    ReviewRepository.instance.add(r);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                // Purple aura gradient
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B003A), Color(0xFF571E88)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141314),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Lapangan: Lapangan Sepakbola Arcici', style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text('Bagikan pengalaman Anda!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nameCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Reviewer name *',
                                labelStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: const Color(0xFF0F0F0F),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama harus diisi' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _ratingCtrl,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Rating (0.0 - 5.0) *',
                                labelStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: const Color(0xFF0F0F0F),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              validator: (v) {
                                final s = v ?? '';
                                final d = double.tryParse(s.replaceAll(',', '.'));
                                if (d == null) return 'Masukkan angka 0.0 - 5.0';
                                if (d < 0 || d > 5) return 'Rating harus antara 0.0 sampai 5.0';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _textCtrl,
                              maxLines: 6,
                              style: const TextStyle(color: Colors.white70),
                              decoration: InputDecoration(
                                labelText: 'Masukan dan Saran Anda *',
                                labelStyle: const TextStyle(color: Colors.white70),
                                hintText: 'Masukkan review Anda',
                                hintStyle: const TextStyle(color: Colors.white24),
                                filled: true,
                                fillColor: const Color(0xFF0F0F0F),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Review harus diisi' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: TextEditingController(),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Gambar (URL)',
                                labelStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: const Color(0xFF0F0F0F),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _submit,
                                icon: const Icon(Icons.send),
                                label: const Text('KIRIM REVIEW'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF571E88),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

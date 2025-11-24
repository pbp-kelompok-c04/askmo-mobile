import 'package:flutter/material.dart';
import 'feat/review/feeds_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = Colors.deepPurple;
    return MaterialApp(
      title: 'ASKMO Reviews',
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark)),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASKMO')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedsPage())),
          child: const Text('Lihat Reviews'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF571E88), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        ),
      ),
    );
  }
}

// Halaman untuk menampilkan review lapangan
class ReviewLapanganPage extends StatelessWidget {
  const ReviewLapanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data untuk review lapangan
    final reviews = [
      {"name": "syafiq nih", "rating": 3, "review": "66", "date": "2025-10-28 12:28"},
      {"name": "Alex", "rating": 4, "review": "Lapangan nyaman dan bersih.", "date": "2025-09-10 09:12"},
      {"name": "Bella", "rating": 5, "review": "Pengalaman bermain terbaik!", "date": "2025-08-03 15:40"},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            children: const [
                              Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                              SizedBox(width: 6),
                              Text('Kembali ke Daftar Lapangan', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.star, color: Colors.yellow, size: 22),
                                SizedBox(width: 6),
                                Text('3,8/5.0', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Beri Review & Rating'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddReviewPage(type: 'lapangan')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF571E88),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                textStyle: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Review Lapangan : Lapangan Sepakbola Arcici',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Divider(color: Colors.grey[800], thickness: 1),
                    const SizedBox(height: 12),
                    const Text('Semua Review', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final r = reviews[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 110,
                                margin: const EdgeInsets.only(right: 12, top: 12, bottom: 12, left: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF571E88),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(r['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          const Spacer(),
                                          Text(r['date'] as String, style: const TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.yellow, size: 18),
                                          const SizedBox(width: 6),
                                          Text('${r['rating']}/5', style: const TextStyle(color: Colors.yellow)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(r['review'] as String, style: const TextStyle(color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Halaman untuk menampilkan review coach
class ReviewCoachPage extends StatelessWidget {
  const ReviewCoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data untuk review coach
    final reviews = [
      {"name": "Michael Jordan", "rating": 5, "review": "Pelatih yang luar biasa! Sangat memotivasi."},
      {"name": "Kobe Bryant", "rating": 4, "review": "Pelatih yang baik, namun ada beberapa area untuk perbaikan."},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Coach'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Review untuk Coach ABC",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(color: Colors.white),
                elevation: 3,
                backgroundColor: Colors.transparent,
              ),
              onPressed: () {
                // Navigasi ke halaman untuk tambah review
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddReviewPage(type: 'coach')),
                );
              },
              child: const Text('Tambah Review'),
            ),
            const SizedBox(height: 20),
            // Daftar review
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    color: Colors.black12,
                    child: ListTile(
                      title: Text(review['name'] as String, style: TextStyle(color: Colors.white)),
                      subtitle: Text(review['review'] as String, style: TextStyle(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.yellow),
                          Text('${review['rating']}', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman untuk tambah review (form dengan validasi sederhana)
class AddReviewPage extends StatefulWidget {
  final String type;
  const AddReviewPage({super.key, required this.type});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ratingCtrl.dispose();
    _reviewCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // For now, simply show a SnackBar and pop back.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review berhasil dikirim!')));
      Navigator.pop(context);
    }
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
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Lapangan: Lapangan Sepakbola Arcici', style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold)),
                        ),
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
                          const SizedBox(height: 8),
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
                            controller: _reviewCtrl,
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
                            controller: _imageCtrl,
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
                          ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.send),
                            label: const Text('KIRIM REVIEW'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF571E88),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }
}

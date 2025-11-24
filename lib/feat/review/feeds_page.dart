import 'package:flutter/material.dart';
import 'review_repository.dart';
import '../../models/review.dart';
import 'review_form.dart';
import 'edit_review.dart';

class FeedsPage extends StatelessWidget {
  const FeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ReviewRepository.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Feeds Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Review Lapangan : Lapangan Sepakbola Arcici', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewFormPage()));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Review'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF571E88)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Semua Review', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<List<Review>>(
                valueListenable: repo.reviews,
                builder: (context, list, _) {
                  if (list.isEmpty) return const Center(child: Text('Belum ada review'));
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = list[index];
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(width: 6, height: 80, color: const Color(0xFF571E88)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [Text(r.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Spacer(), Text(r.date, style: const TextStyle(color: Colors.grey))]),
                                    const SizedBox(height: 8),
                                    Row(children: [const Icon(Icons.star, color: Colors.yellow, size: 16), const SizedBox(width: 6), Text('${r.rating}/5', style: const TextStyle(color: Colors.yellow))]),
                                    const SizedBox(height: 8),
                                    Text(r.text, style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white70),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => EditReviewPage(review: r)));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () {
                                      repo.remove(r.id);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
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

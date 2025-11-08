// main.dart - Complete Flutter Quiz App
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quiz',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const QuizHomePage(),
    );
  }
}

class Question {
  final int id;
  final String q;
  final String a;
  bool learned;
  bool expanded;

  Question(this.id, this.q, this.a, {this.learned = false, this.expanded = false});
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({Key? key}) : super(key: key);

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  List<Question> _questions = [
    Question(1, "What is a Widget in Flutter?", "Everything in Flutter is a widget - the basic building blocks of a Flutter app's UI."),
    Question(2, "What is setState() used for?", "setState() notifies the framework that the internal state has changed and the UI needs to rebuild."),
    Question(3, "What is the difference between StatelessWidget and StatefulWidget?", "StatelessWidget is immutable and doesn't change, while StatefulWidget can change its state during the app's lifetime."),
  ];

  bool _isRefreshing = false;
  bool _showAddForm = false;
  final _qController = TextEditingController();
  final _aController = TextEditingController();

  int get _learnedCount => _questions.where((q) => q.learned).length;

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      for (var q in _questions) {
        q.learned = false;
        q.expanded = false;
      }
      _isRefreshing = false;
    });
  }

  void _toggle(int id) {
    setState(() {
      final idx = _questions.indexWhere((q) => q.id == id);
      if (idx != -1) _questions[idx].expanded = !_questions[idx].expanded;
    });
  }

  void _markLearned(int id) {
    setState(() {
      final idx = _questions.indexWhere((q) => q.id == id);
      if (idx != -1) _questions[idx].learned = true;
    });
  }

  void _delete(int id) {
    setState(() => _questions.removeWhere((q) => q.id == id));
  }

  void _add() {
    if (_qController.text.trim().isEmpty || _aController.text.trim().isEmpty) return;
    setState(() {
      _questions.insert(0, Question(DateTime.now().millisecondsSinceEpoch, _qController.text, _aController.text));
      _showAddForm = false;
    });
    _qController.clear();
    _aController.clear();
  }

  @override
  void dispose() {
    _qController.dispose();
    _aController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF9333EA)]),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Flutter Quiz', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Master Flutter concepts', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                            IconButton(
                              icon: _isRefreshing
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.refresh, color: Colors.white),
                              onPressed: _isRefreshing ? null : _refresh,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _questions.isEmpty ? 0 : _learnedCount / _questions.length,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('$_learnedCount of ${_questions.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _showAddForm = !_showAddForm),
                icon: const Icon(Icons.add),
                label: const Text('Add New Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          if (_showAddForm)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(controller: _qController, decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(controller: _aController, decoration: const InputDecoration(labelText: 'Answer', border: OutlineInputBorder()), maxLines: 3),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: ElevatedButton(onPressed: _add, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text('Add'))),
                            const SizedBox(width: 8),
                            Expanded(child: ElevatedButton(
                              onPressed: () {
                                setState(() => _showAddForm = false);
                                _qController.clear();
                                _aController.clear();
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                              child: const Text('Cancel'),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final q = _questions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Dismissible(
                    key: Key(q.id.toString()),
                    direction: q.learned ? DismissDirection.endToStart : DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd && !q.learned) {
                        _markLearned(q.id);
                        return false;
                      }
                      return direction == DismissDirection.endToStart;
                    },
                    onDismissed: (_) => _delete(q.id),
                    background: Container(
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Row(children: [Icon(Icons.check, color: Colors.white), SizedBox(width: 8), Text('Learned', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                    ),
                    secondaryBackground: Container(
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.delete, color: Colors.white)]),
                    ),
                    child: Card(
                      elevation: q.learned ? 1 : 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: q.learned ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none),
                      child: InkWell(
                        onTap: () => _toggle(q.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.indigo.shade100, borderRadius: BorderRadius.circular(4)),
                                    child: Text('Q${index + 1}', style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  if (q.learned) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                                      child: Row(children: [Icon(Icons.check, size: 12, color: Colors.green.shade700), const SizedBox(width: 4), Text('Learned', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12))]),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(q.q, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              const Text('Swipe → learned | ← delete', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(height: 24),
                                    const Text('ANSWER:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: Text(q.a, style: const TextStyle(fontSize: 14)),
                                    ),
                                  ],
                                ),
                                crossFadeState: q.expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 300),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _questions.length,
            ),
          ),
        ],
      ),
    );
  }
}
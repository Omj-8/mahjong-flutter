import 'package:flutter/material.dart';

import '../models/history_model.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();

  bool _loading = true;
  List<SessionEntry> _history = [];
  Map<String, int> _cumulative = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await _historyService.loadHistory();
    final cumulative = await _historyService.loadCumulative();
    setState(() {
      _history = history;
      _cumulative = cumulative;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    await _historyService.clearAll();
    if (!mounted) return;
    setState(() {
      _history = [];
      _cumulative = {};
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('累計データをリセットしました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('累計・履歴'),
        actions: [
          IconButton(
            onPressed: _history.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_forever),
            tooltip: '累計リセット',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCumulativeSection(),
                  const SizedBox(height: 24),
                  _buildHistorySection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCumulativeSection() {
    if (_cumulative.isEmpty) {
      return _buildEmptyCard('累計はまだありません');
    }

    final entries = _cumulative.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '累計ポイント',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text(
                      _formatPoints(e.value),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: e.value >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_history.isEmpty) {
      return _buildEmptyCard('履歴はまだありません');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '履歴',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ..._history.map(_buildHistoryCard),
      ],
    );
  }

  Widget _buildHistoryCard(SessionEntry entry) {
    final dateTime = DateTime.parse(entry.dateTimeIso).toLocal();
    final dateLabel =
        '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              dateLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...entry.players.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.name),
                    Text(
                      _formatPoints(p.totalPoints),
                      style: TextStyle(
                        color: p.totalPoints >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 0) {
      return '+$points';
    }
    return '$points';
  }
}

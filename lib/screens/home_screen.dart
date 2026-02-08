import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/history_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'score_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameSettings gameSettings;
  final HistoryService _historyService = HistoryService();
  Map<String, int> _cumulative = {};
  bool _loadingCumulative = true;

  @override
  void initState() {
    super.initState();
    gameSettings = GameSettings();
    _loadCumulative();
  }

  Future<void> _loadCumulative() async {
    final cumulative = await _historyService.loadCumulative();
    if (!mounted) return;
    setState(() {
      _cumulative = cumulative;
      _loadingCumulative = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('麻雀ウマオカ計算機'),
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.casino,
                      size: 80,
                      color: Colors.blue.shade300,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '麻雀ウマオカ計算機',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点数を入力して\nウマとオカを計算',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => ScoreInputScreen(
                        gameSettings: gameSettings,
                      ),
                    ),
                  );
                  await _loadCumulative();
                },
                icon: const Icon(Icons.edit),
                label: const Text('点数を入力'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final newSettings = await Navigator.of(context).push<GameSettings?>(
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        initialSettings: gameSettings,
                      ),
                    ),
                  );
                  if (newSettings != null) {
                    setState(() {
                      gameSettings = newSettings;
                    });
                  }
                },
                icon: const Icon(Icons.settings),
                label: const Text('ウマ・オカ設定'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                  await _loadCumulative();
                },
                icon: const Icon(Icons.history),
                label: const Text('累計・履歴'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.teal,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      '現在の設定',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (gameSettings.usePointSystem) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('初期所持点数:', style: TextStyle(fontSize: 12)),
                          Text(
                            '${gameSettings.initialScore}点',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('返し点数:', style: TextStyle(fontSize: 12)),
                          Text(
                            '${gameSettings.returnPoints}点',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        '着順ボーナス',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSettingItem('1位', gameSettings.bonus1st),
                          _buildSettingItem('2位', gameSettings.bonus2nd),
                          _buildSettingItem('3位', gameSettings.bonus3rd),
                          _buildSettingItem('4位', gameSettings.bonus4th),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('飛びルール:', style: TextStyle(fontSize: 12)),
                          Text(
                            gameSettings.useTobiRule ? '有効' : '無効',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: gameSettings.useTobiRule
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (gameSettings.useTobiRule) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('飛びペナルティ:',
                                style: TextStyle(fontSize: 12)),
                            Text(
                              '${gameSettings.tobiPenalty}pt',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('飛ばした人のボーナス:',
                                style: TextStyle(fontSize: 12)),
                            Text(
                              '${gameSettings.tobiReward}pt',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ] else ...[
                      const Text(
                        'ポイント制: 無効',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCumulativeSummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value >= 0 ? '+$value' : '$value',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: value >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildCumulativeSummary() {
    if (_loadingCumulative) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_cumulative.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '累計はまだありません',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final entries = _cumulative.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            '累計ポイント',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key),
                  Text(
                    e.value >= 0 ? '+${e.value}' : '${e.value}',
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
    );
  }
}

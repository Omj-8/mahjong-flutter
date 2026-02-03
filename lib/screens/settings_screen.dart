import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_model.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings initialSettings;

  const SettingsScreen({
    super.key,
    required this.initialSettings,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController initialScoreController;
  late TextEditingController returnPointsController;
  late TextEditingController pointsPerThousandController;
  late TextEditingController bonus1stController;
  late TextEditingController bonus2ndController;
  late TextEditingController bonus3rdController;
  late TextEditingController bonus4thController;
  late bool usePointSystem;

  @override
  void initState() {
    super.initState();
    initialScoreController = TextEditingController(
      text: widget.initialSettings.initialScore.toString(),
    );
    returnPointsController = TextEditingController(
      text: widget.initialSettings.returnPoints.toString(),
    );
    pointsPerThousandController = TextEditingController(
      text: widget.initialSettings.pointsPerThousand.toString(),
    );
    bonus1stController = TextEditingController(
      text: widget.initialSettings.bonus1st.toString(),
    );
    bonus2ndController = TextEditingController(
      text: widget.initialSettings.bonus2nd.toString(),
    );
    bonus3rdController = TextEditingController(
      text: widget.initialSettings.bonus3rd.toString(),
    );
    bonus4thController = TextEditingController(
      text: widget.initialSettings.bonus4th.toString(),
    );
    usePointSystem = widget.initialSettings.usePointSystem;
  }

  @override
  void dispose() {
    initialScoreController.dispose();
    returnPointsController.dispose();
    pointsPerThousandController.dispose();
    bonus1stController.dispose();
    bonus2ndController.dispose();
    bonus3rdController.dispose();
    bonus4thController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ゲーム設定'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ポイント制の有効/無効
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ポイント制を使用',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: usePointSystem,
                      onChanged: (value) {
                        setState(() {
                          usePointSystem = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (usePointSystem) ...[
              const Text(
                '基本設定',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField('初期所持点数', initialScoreController),
              const SizedBox(height: 12),
              _buildInputField('返し点数', returnPointsController),
              const SizedBox(height: 12),
              _buildInputField('1000点あたりのポイント', pointsPerThousandController),
              const SizedBox(height: 32),
              const Text(
                '着順ボーナス',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildBonusInputField('1位のボーナス', bonus1stController),
              const SizedBox(height: 12),
              _buildBonusInputField('2位のボーナス', bonus2ndController),
              const SizedBox(height: 12),
              _buildBonusInputField('3位のボーナス', bonus3rdController),
              const SizedBox(height: 12),
              _buildBonusInputField('4位のボーナス', bonus4thController),
              const SizedBox(height: 16),
              _buildBonusSummary(),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'ポイント制が無効です',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: const Text('保存する'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _resetToDefaults,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.grey,
              ),
              child: const Text('デフォルトに戻す'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildBonusInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*$')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (_) {
        setState(() {});
      },
    );
  }

  Widget _buildBonusSummary() {
    final bonus1 = int.tryParse(bonus1stController.text) ?? 30;
    final bonus2 = int.tryParse(bonus2ndController.text) ?? 10;
    final bonus3 = int.tryParse(bonus3rdController.text) ?? -10;
    final bonus4 = int.tryParse(bonus4thController.text) ?? -30;
    final total = bonus1 + bonus2 + bonus3 + bonus4;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: total == 0 ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(
          color: total == 0 ? Colors.green : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ボーナス合計:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: total == 0 ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          Text(
            total == 0 ? '✓ 0pt' : '✗ ${total}pt',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: total == 0 ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    final bonus1 = int.tryParse(bonus1stController.text) ?? 30;
    final bonus2 = int.tryParse(bonus2ndController.text) ?? 10;
    final bonus3 = int.tryParse(bonus3rdController.text) ?? -10;
    final bonus4 = int.tryParse(bonus4thController.text) ?? -30;

    // バリデーション：着順ボーナスの合計が0か確認
    final bonusTotal = bonus1 + bonus2 + bonus3 + bonus4;
    if (bonusTotal != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '着順ボーナスの合計が0になっていません\n現在の合計: ${bonusTotal}pt',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final newSettings = GameSettings(
      initialScore: int.tryParse(initialScoreController.text) ?? 25000,
      returnPoints: int.tryParse(returnPointsController.text) ?? 30000,
      pointsPerThousand: int.tryParse(pointsPerThousandController.text) ?? 1,
      bonus1st: bonus1,
      bonus2nd: bonus2,
      bonus3rd: bonus3,
      bonus4th: bonus4,
      usePointSystem: usePointSystem,
    );
    Navigator.of(context).pop(newSettings);
  }

  void _resetToDefaults() {
    final defaults = GameSettings.defaultSettings();
    setState(() {
      initialScoreController.text = defaults.initialScore.toString();
      returnPointsController.text = defaults.returnPoints.toString();
      pointsPerThousandController.text = defaults.pointsPerThousand.toString();
      bonus1stController.text = defaults.bonus1st.toString();
      bonus2ndController.text = defaults.bonus2nd.toString();
      bonus3rdController.text = defaults.bonus3rd.toString();
      bonus4thController.text = defaults.bonus4th.toString();
      usePointSystem = defaults.usePointSystem;
    });
  }
}

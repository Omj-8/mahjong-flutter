import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_model.dart';
import '../services/calculator_service.dart';
import 'result_screen.dart';

class ScoreInputScreen extends StatefulWidget {
  final GameSettings gameSettings;

  const ScoreInputScreen({
    super.key,
    required this.gameSettings,
  });

  @override
  State<ScoreInputScreen> createState() => _ScoreInputScreenState();
}

class _ScoreInputScreenState extends State<ScoreInputScreen> {
  late List<TextEditingController> scoreControllers;
  late List<String> playerNames;
  String? _tobiKillerName;
  int _rotationIndex = 0;

  @override
  void initState() {
    super.initState();
    playerNames = ['東', '南', '西', '北'];
    scoreControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    _tobiKillerName = null;
  }

  @override
  void dispose() {
    for (var controller in scoreControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最終点数入力'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '各プレイヤーの最終点数を入力してください',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildRotationControls(),
            const SizedBox(height: 12),
            _buildRotatableTable(),
            const SizedBox(height: 16),
            _buildTotalScoreDisplay(),
            if (widget.gameSettings.useTobiRule) ...[
              const SizedBox(height: 16),
              _buildTobiSection(),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _calculateResults,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                '計算する',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _clearAll,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.grey,
              ),
              child: const Text('クリア'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationControls() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.rotate_right, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '卓を回転して入力しやすい向きに合わせる',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                const Spacer(),
                Text(
                  '${_rotationIndex * 90}°',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: List.generate(
                4,
                (index) => ChoiceChip(
                  label: Text('${index * 90}°'),
                  selected: _rotationIndex == index,
                  onSelected: (_) {
                    setState(() {
                      _rotationIndex = index;
                    });
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _rotationIndex = (_rotationIndex + 3) % 4;
                    });
                  },
                  icon: const Icon(Icons.rotate_left),
                  label: const Text('90°左'),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _rotationIndex = (_rotationIndex + 1) % 4;
                    });
                  },
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('90°右'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotatableTable() {
    final tableRotation = _rotationIndex * (math.pi / 2);
    final seatOrder = [
      // 東の右が北、向かいが西、左が南
      {'name': playerNames[0], 'index': 0, 'align': Alignment.topCenter},
      {'name': playerNames[3], 'index': 3, 'align': Alignment.centerRight},
      {'name': playerNames[2], 'index': 2, 'align': Alignment.bottomCenter},
      {'name': playerNames[1], 'index': 1, 'align': Alignment.centerLeft},
    ];

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.casino, color: Colors.white, size: 36),
              ),
            ),
            Transform.rotate(
              angle: tableRotation,
              child: Stack(
                children: seatOrder
                    .map(
                      (seat) => Align(
                        alignment: seat['align'] as Alignment,
                        child: Transform.rotate(
                          angle: -tableRotation,
                          child: _buildSeatInputField(
                            seat['name'] as String,
                            seat['index'] as int,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatInputField(String playerName, int index) {
    return SizedBox(
      width: 140,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                playerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: scoreControllers[index],
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                inputFormatters: [
                  _MahjongScoreInputFormatter(),
                ],
                decoration: InputDecoration(
                  isDense: true,
                  suffixText: '00点',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  hintText: '250 / -50',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalScoreDisplay() {
    int totalScore = 0;
    for (var controller in scoreControllers) {
      if (controller.text.isNotEmpty && controller.text != '-') {
        final input = int.parse(controller.text);
        totalScore += input * 100; // 入力値に00を付与
      }
    }

    final isValid = totalScore == 100000;
    final difference = totalScore - 100000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(
          color: isValid ? Colors.green : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '合計点数:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '$totalScore点',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isValid ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!isValid)
            Text(
              totalScore == 0
                  ? '点数を入力してください'
                  : difference > 0
                      ? '${difference}点多い'
                      : '${-difference}点足りない',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            )
          else
            Text(
              '✓ 条件を満たしています',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  List<String> _getNegativePlayerNames() {
    final negativeNames = <String>[];
    for (int i = 0; i < scoreControllers.length; i++) {
      final text = scoreControllers[i].text;
      if (text.isEmpty || text == '-') continue;
      final input = int.parse(text);
      final score = input * 100;
      if (score < 0) {
        negativeNames.add(playerNames[i]);
      }
    }
    return negativeNames;
  }

  Widget _buildTobiSection() {
    final negativePlayers = _getNegativePlayerNames();

    if (negativePlayers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '飛びはありません',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final availableKillers =
      playerNames.where((name) => !negativePlayers.contains(name)).toList();
    final dropdownItems = ['なし', ...availableKillers];
    final currentValue = dropdownItems.contains(_tobiKillerName)
      ? _tobiKillerName
      : 'なし';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '飛びルール',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '飛び対象: ${negativePlayers.join(' / ')}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: currentValue,
            items: dropdownItems
                .map(
                  (name) => DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(
              labelText: '飛ばした人（任意）',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _tobiKillerName = value == 'なし' ? null : value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _calculateResults() {
    // バリデーション1：全て入力されているか
    if (scoreControllers.any(
        (controller) => controller.text.isEmpty || controller.text == '-')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('すべてのプレイヤーの点数を入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 点数を取得（入力値に00を付与して計算）
    final scores = scoreControllers.map((c) {
      final input = int.parse(c.text);
      return input * 100; // 入力値に00を付与
    }).toList();
    final totalScore = scores.fold<int>(0, (sum, score) => sum + score);

    // バリデーション2：合計が100000点か
    if (totalScore != 100000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '点数の合計が100000点ではありません\n現在: ${totalScore}点\n差分: ${totalScore - 100000}点',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // プレイヤーオブジェクトを作成
    final players = <Player>[];
    for (int i = 0; i < 4; i++) {
      players.add(
        Player(
          name: playerNames[i],
          finalScore: scores[i],
        ),
      );
    }

    // 飛びルール用の情報を整理
    final negativePlayers = _getNegativePlayerNames();
    final tobiKillerName = widget.gameSettings.useTobiRule &&
        negativePlayers.isNotEmpty &&
        _tobiKillerName != null &&
        !negativePlayers.contains(_tobiKillerName)
      ? _tobiKillerName
      : null;

    // 計算を実行
    final result = CalculatorService.calculateGameResult(
      players,
      widget.gameSettings,
      tobiKillerName: tobiKillerName,
    );

    // 結果画面へ遷移
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          result: result,
          gameSettings: widget.gameSettings,
        ),
      ),
    );
  }

  void _clearAll() {
    for (var controller in scoreControllers) {
      controller.clear();
    }
    setState(() {
      _tobiKillerName = null;
    });
  }
}

/// 麻雀の点数フォーマッター（負の数対応、数字とマイナス記号のみ、5桁以下）
class _MahjongScoreInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String raw = newValue.text;

    // 先頭のマイナスのみ許可
    bool isNegative = raw.startsWith('-');
    String numericOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');

    // 5桁以下に制限（50000までで十分）
    if (numericOnly.length > 5) {
      return oldValue;
    }

    // マイナス記号を先頭に付与（数字が未入力でも許可）
    if (isNegative) {
      numericOnly = '-$numericOnly';
    }

    // 単独の「-」を許可
    if (numericOnly == '-') {
      return const TextEditingValue(
        text: '-',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    // テキストのみ更新（カーソル位置を保持）
    return TextEditingValue(
      text: numericOnly,
      selection: TextSelection.fromPosition(
        TextPosition(offset: numericOnly.length),
      ),
    );
  }
}


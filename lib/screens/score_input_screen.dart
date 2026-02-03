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
            const SizedBox(height: 24),
            ...List.generate(
              4,
              (index) => _buildPlayerInputField(playerNames[index], index),
            ),
            const SizedBox(height: 16),
            _buildTotalScoreDisplay(),
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

  Widget _buildPlayerInputField(String playerName, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: scoreControllers[index],
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        inputFormatters: [
          _MahjongScoreInputFormatter(),
        ],
        decoration: InputDecoration(
          labelText: '$playerName (東南西北の$playerName)',
          prefix: const Text(''),
          suffixText: '00点',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.blue.shade50,
          hintText: '250 → 25000点 / -50 → -5000点',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
        onChanged: (_) {
          setState(() {});
        },
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

    // 計算を実行
    final result = CalculatorService.calculateGameResult(
      players,
      widget.gameSettings,
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


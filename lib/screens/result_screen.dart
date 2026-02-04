import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_model.dart';
import '../services/calculator_service.dart';
import '../services/history_service.dart';

class ResultScreen extends StatelessWidget {
  final GameResult result;
  final GameSettings gameSettings;
  final HistoryService _historyService = HistoryService();

  ResultScreen({
    super.key,
    required this.result,
    required this.gameSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = CalculatorService.validateResults(result);

    return Scaffold(
      appBar: AppBar(
        title: const Text('計算結果'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!gameSettings.usePointSystem)
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
              )
            else ...[
              if (!isValid)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('合計が想定値になっていません。\n入力値を確認してください。'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              ..._buildResultCards(),
              const SizedBox(height: 32),
              _buildSummaryTable(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _addToHistory(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                ),
                child: const Text('累計に追加'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _shareResults(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text('結果をコピー'),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.grey,
              ),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultCards() {
    // 順位でソート
    final sortedPlayers = List<Player>.from(result.players);
    sortedPlayers.sort((a, b) => a.rank.compareTo(b.rank));

    return sortedPlayers.map((player) {
      final colors = [Colors.amber, Colors.grey, Colors.orange, Colors.brown];
      final color = colors[player.rank - 1];
      final isTobiVictim = result.tobiVictims.contains(player.name);
      final isTobiKiller = result.tobiKillerName == player.name;
      int tobiAdjustment = 0;
      if (result.tobiEnabled) {
        if (isTobiVictim) {
          tobiAdjustment += result.tobiPenalty;
        }
        if (isTobiKiller) {
          tobiAdjustment += result.tobiReward * result.tobiVictims.length;
        }
      }

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              '第${player.rank}位: ${player.name}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            subtitle: Text(
              '合計: ${_formatPoints(player.totalPoints)} / 最終点数: ${player.finalScore}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: player.totalPoints >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('基礎ポイント:'),
                  Text(
                    _formatPoints(player.basePoints),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: player.basePoints >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('着順ボーナス:'),
                  Text(
                    _formatPoints(player.bonusPoints),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: player.bonusPoints >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              if (result.tobiEnabled && tobiAdjustment != 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('飛び調整:'),
                      Text(
                        _formatPoints(tobiAdjustment),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              tobiAdjustment >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              if (player.rank == 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'トップボーナス:',
                        style: TextStyle(color: Colors.blue),
                      ),
                      Text(
                        _formatPoints(
                          player.totalPoints -
                              player.basePoints -
                              player.bonusPoints -
                              tobiAdjustment,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSummaryTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '設定値',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('初期所持点数'),
              Text('${gameSettings.initialScore}点'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('返し点数'),
              Text('${gameSettings.returnPoints}点'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('1位'),
              Text(_formatPoints(gameSettings.bonus1st)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('2位'),
              Text(_formatPoints(gameSettings.bonus2nd)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('3位'),
              Text(_formatPoints(gameSettings.bonus3rd)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('4位'),
              Text(_formatPoints(gameSettings.bonus4th)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('飛びルール'),
              Text(gameSettings.useTobiRule ? '有効' : '無効'),
            ],
          ),
          if (gameSettings.useTobiRule) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('飛びペナルティ'),
                Text(_formatPoints(gameSettings.tobiPenalty)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('飛ばした人のボーナス'),
                Text(_formatPoints(gameSettings.tobiReward)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 0) {
      return '+$points';
    } else {
      return '$points';
    }
  }

  void _shareResults(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('=== 麻雀ポイント計算結果 ===\n');

    // ソート済みプレイヤーを取得
    final sortedPlayers = List<Player>.from(result.players);
    sortedPlayers.sort((a, b) => a.rank.compareTo(b.rank));

    for (var player in sortedPlayers) {
      buffer.writeln(
        '第${player.rank}位: ${player.name} (最終点数: ${player.finalScore}点)',
      );
      buffer.writeln('  基礎ポイント: ${_formatPoints(player.basePoints)}');
      buffer.writeln('  着順ボーナス: ${_formatPoints(player.bonusPoints)}');
      if (player.rank == 1) {
        int topBonus = player.totalPoints - player.basePoints - player.bonusPoints;
        buffer.writeln('  トップボーナス: ${_formatPoints(topBonus)}');
      }
      buffer.writeln('  合計: ${_formatPoints(player.totalPoints)}');
      buffer.writeln('');
    }

    buffer.writeln('=== 設定値 ===');
    buffer.writeln('初期所持点数: ${gameSettings.initialScore}点');
    buffer.writeln('返し点数: ${gameSettings.returnPoints}点');
    buffer.writeln(
      '着順ボーナス - 1位: ${_formatPoints(gameSettings.bonus1st)}, '
      '2位: ${_formatPoints(gameSettings.bonus2nd)}, '
      '3位: ${_formatPoints(gameSettings.bonus3rd)}, '
      '4位: ${_formatPoints(gameSettings.bonus4th)}',
    );

    if (gameSettings.useTobiRule) {
      buffer.writeln('飛びルール: 有効');
      buffer.writeln('飛びペナルティ: ${_formatPoints(gameSettings.tobiPenalty)}');
      buffer.writeln('飛ばした人のボーナス: ${_formatPoints(gameSettings.tobiReward)}');
      if (result.tobiVictims.isNotEmpty) {
        buffer.writeln('飛び対象: ${result.tobiVictims.join(' / ')}');
      }
      buffer.writeln(
        '飛ばした人: ${result.tobiKillerName ?? 'なし'}',
      );
    } else {
      buffer.writeln('飛びルール: 無効');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('結果をコピーしました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _addToHistory(BuildContext context) async {
    await _historyService.addSession(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('累計に追加しました'),
        backgroundColor: Colors.teal,
      ),
    );
    // 2秒後にホームに戻る
    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

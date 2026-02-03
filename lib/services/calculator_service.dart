import '../models/game_model.dart';

/// ウマオカの計算サービス
class CalculatorService {
  /// 5捨6入を実行
  static int roundAwayFromZero(double value) {
    if (value >= 0) {
      return (value + 0.5).floor();
    } else {
      return (value - 0.5).ceil();
    }
  }

  /// プレイヤーの順位を計算する
  static List<Player> calculateRanks(List<Player> players) {
    // スコアでソートして順位を決める
    final sortedByScore = List<Player>.from(players);
    sortedByScore.sort((a, b) => b.finalScore.compareTo(a.finalScore));

    // 同点の場合も考慮して順位を付ける
    for (int i = 0; i < sortedByScore.length; i++) {
      sortedByScore[i].rank = i + 1;
    }

    return players;
  }

  /// ポイント制で計算する
  static GameResult calculatePointSystem(
    List<Player> players,
    GameSettings settings,
  ) {
    // まず順位を計算
    final playersWithRanks = calculateRanks(players);

    // 基礎ポイントを計算
    for (var player in playersWithRanks) {
      // スコアを5捨6入
      final roundedScore = roundAwayFromZero(player.finalScore / 1000.0) * 1000;
      // 返し点数を引く
      final scoreDifference = roundedScore - settings.returnPoints;
      // 1000で割って5捨6入
      final basePoints = roundAwayFromZero(scoreDifference / 1000.0) * settings.pointsPerThousand;
      player.basePoints = basePoints.toInt();
    }

    // 着順ボーナスを計算
    final bonusList = [
      settings.bonus1st,
      settings.bonus2nd,
      settings.bonus3rd,
      settings.bonus4th
    ];

    for (var player in playersWithRanks) {
      player.bonusPoints = bonusList[player.rank - 1];
    }

    // 仮の合計を計算
    int totalPoints = 0;
    for (var player in playersWithRanks) {
      player.totalPoints = player.basePoints + player.bonusPoints;
      totalPoints += player.totalPoints;
    }

    // トップボーナス：全体が0になるように1位に加算
    // totalPointsが負の場合、その絶対値を1位に加算
    int topBonus = -totalPoints;
    
    // 1位を見つけて加算
    for (var player in playersWithRanks) {
      if (player.rank == 1) {
        player.totalPoints += topBonus;
        break;
      }
    }

    return GameResult(players: playersWithRanks);
  }

  /// 統合的な計算メソッド
  static GameResult calculateGameResult(
    List<Player> players,
    GameSettings settings,
  ) {
    if (settings.usePointSystem) {
      return calculatePointSystem(players, settings);
    } else {
      // ウマオカなしの場合は0を返す
      final playersWithRanks = calculateRanks(players);
      for (var player in playersWithRanks) {
        player.basePoints = 0;
        player.bonusPoints = 0;
        player.totalPoints = 0;
      }
      return GameResult(players: playersWithRanks);
    }
  }

  /// 検証用：合計が0になっているか確認
  static bool validateResults(GameResult result) {
    int totalPoints = 0;
    for (var player in result.players) {
      totalPoints += player.totalPoints;
    }
    return totalPoints == 0;
  }
}

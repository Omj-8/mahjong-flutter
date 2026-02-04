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
    GameSettings settings, {
    String? tobiKillerName,
  }) {
    // まず順位を計算
    final playersWithRanks = calculateRanks(players);

    // 基礎ポイントを計算
    for (var player in playersWithRanks) {
      // スコアを5捨6入
      final roundedScore = roundAwayFromZero(player.finalScore / 1000.0) * 1000;
      // 返し点数を引く
      final scoreDifference = roundedScore - settings.returnPoints;
      // 1000で割って5捨6入
      final basePoints =
          roundAwayFromZero(scoreDifference / 1000.0) * settings.pointsPerThousand;
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

    // 飛びルールを適用（トップボーナス適用後）
    final tobiVictims = <String>[];
    if (settings.useTobiRule && tobiKillerName != null) {
      // 飛ばした人が明示的に指定された場合のみ飛び処理をする
      for (var player in playersWithRanks) {
        if (player.finalScore < 0) {
          player.totalPoints += settings.tobiPenalty;
          tobiVictims.add(player.name);
        }
      }

      if (tobiVictims.isNotEmpty) {
        for (var player in playersWithRanks) {
          if (player.name == tobiKillerName) {
            player.totalPoints += settings.tobiReward * tobiVictims.length;
            break;
          }
        }
      }
    }

    return GameResult(
      players: playersWithRanks,
      tobiEnabled: settings.useTobiRule,
      tobiVictims: tobiVictims,
      tobiKillerName: tobiKillerName,
      tobiPenalty: settings.tobiPenalty,
      tobiReward: settings.tobiReward,
    );
  }

  /// 統合的な計算メソッド
  static GameResult calculateGameResult(
    List<Player> players,
    GameSettings settings, {
    String? tobiKillerName,
  }) {
    if (settings.usePointSystem) {
      return calculatePointSystem(
        players,
        settings,
        tobiKillerName: tobiKillerName,
      );
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

  /// 検証用：合計が想定通りか確認
  static bool validateResults(GameResult result) {
    int totalPoints = 0;
    for (var player in result.players) {
      totalPoints += player.totalPoints;
    }

    int expectedTotal = 0;
    if (result.tobiEnabled && result.tobiVictims.isNotEmpty) {
      expectedTotal = result.tobiPenalty * result.tobiVictims.length;
      if (result.tobiKillerName != null) {
        expectedTotal += result.tobiReward * result.tobiVictims.length;
      }
    }

    return totalPoints == expectedTotal;
  }
}

/// ゲーム設定とプレイヤー情報を管理するモデル
class GameSettings {
  // 基本設定
  int initialScore; // 初期所持点数（デフォルト：25000点）
  int returnPoints; // 返し点数（デフォルト：30000点）
  int pointsPerThousand; // 1000点あたりのポイント（デフォルト：1）
  
  // 着順ボーナス
  int bonus1st; // 1位のボーナス
  int bonus2nd; // 2位のボーナス
  int bonus3rd; // 3位のボーナス
  int bonus4th; // 4位のボーナス
  
  // 計算方式の選択
  bool usePointSystem; // ポイント制を使用するか

  GameSettings({
    this.initialScore = 25000,
    this.returnPoints = 30000,
    this.pointsPerThousand = 1,
    this.bonus1st = 30,
    this.bonus2nd = 10,
    this.bonus3rd = -10,
    this.bonus4th = -30,
    this.usePointSystem = true,
  });

  /// デフォルト設定
  static GameSettings defaultSettings() {
    return GameSettings(
      initialScore: 25000,
      returnPoints: 30000,
      pointsPerThousand: 1,
      bonus1st: 30,
      bonus2nd: 10,
      bonus3rd: -10,
      bonus4th: -30,
      usePointSystem: true,
    );
  }
}

/// プレイヤー情報
class Player {
  String name;
  int finalScore; // 最終点数
  int rank; // 順位
  int basePoints; // 基礎ポイント
  int bonusPoints; // 着順ボーナス
  int totalPoints; // 合計ポイント

  Player({
    required this.name,
    this.finalScore = 0,
    this.rank = 0,
    this.basePoints = 0,
    this.bonusPoints = 0,
    this.totalPoints = 0,
  });
}

/// ゲーム結果の計算結果
class GameResult {
  List<Player> players;

  GameResult({
    required this.players,
  });
}


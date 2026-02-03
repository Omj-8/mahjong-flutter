# 麻雀ウマオカ計算アプリ

カスタムポイント計算システムを搭載した、麻雀ゲームの清算・累計管理アプリです。

## 📱 対応プラットフォーム

- ✅ Android 15+ (API 35+)
- ✅ Windows
- ✅ Web (Edge / Chrome)
- 🟡 iOS (未実装)
- 🟡 Linux (未実装)

---

## 🎯 主な機能

### 1. **カスタムポイント計算システム**
- **計算ロジック**: 1000点 = 1pt（5捨6入方式）
- **着順ボーナス**:
  - 1位: +30pt
  - 2位: +10pt
  - 3位: -10pt
  - 4位: -30pt
- **トップボーナス**: 自動計算により全プレイヤーのポイント合計が0ptになるよう調整
- **設定可能**: ウマ・オカ設定画面でボーナス値をカスタマイズ可能

### 2. **点数入力・検証**
- 4プレイヤーの最終得点を入力
- **自動バリデーション**: 全プレイヤーの合計が100,000点に達するまで確定不可
- **ボーナス検証**: 全ボーナスの合計が0ptであることを確認
- **マイナス入力対応**: 負数も正負両方の形式で入力可能
- **ショートカット入力**: 「250」→「25,000点」のように自動変換

### 3. **累計・履歴管理**
- **LocalStorage対応**: Androidデバイスに永続保存（shared_preferences使用）
- **ゲーム履歴**: 過去のゲーム結果を日時付きで記録
- **累計ポイント表示**: プレイヤー別の累計ポイントをリアルタイム表示（降順ソート）
- **クリア機能**: 履歴を完全削除できる

### 4. **結果表示**
- プレイヤー別に基本ポイント・着順ボーナス・トップボーナスを表示
- 結果をテキスト形式でコピー可能
- 「累計に追加」で結果をリアルタイムに履歴に保存

---

## 📊 計算例

**入力データ（点数）:**
- プレイヤーA: 35,600点（2位）
- プレイヤーB: 22,800点（3位）
- プレイヤーC: 28,600点（4位）
- プレイヤーD: 13,000点（4位）

**計算過程:**
```
A: (35600×100 → 3560000pt ÷ 1000) = 3560pt → 基本ポイント: 15pt → +10pt(2位) = 25pt
B: (22800×100 → 2280000pt ÷ 1000) = 2280pt → 基本ポイント: -72pt → -10pt(3位) = -82pt
C: (28600×100 → 2860000pt ÷ 1000) = 2860pt → 基本ポイント: -14pt → -30pt(4位) = -44pt
D: (13000×100 → 1300000pt ÷ 1000) = 1300pt → 基本ポイント: -128pt → -30pt(4位) = -158pt

トップボーナス調整: +259pt を1位Aに加算
最終: A=284pt, B=-82pt, C=-44pt, D=-158pt (合計=0pt ✓)
```

---

## 🛠️ 技術スタック

### フロントエンド
- **フレームワーク**: Flutter
- **言語**: Dart
- **UI**: Material Design

### バックエンド・ストレージ
- **LocalStorage**: shared_preferences (^2.2.3)
- **データ形式**: JSON
- **永続化**: Device Storage (Android)

### プロジェクト構成
```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── game_model.dart                # Game data structures
│   └── history_model.dart             # History serialization
├── services/
│   ├── calculator_service.dart        # Point calculation logic
│   └── history_service.dart           # LocalStorage manager
└── screens/
    ├── home_screen.dart               # Navigation & cumulative view
    ├── score_input_screen.dart        # Point entry & validation
    ├── settings_screen.dart           # Game parameter config
    ├── result_screen.dart             # Result display & save
    └── history_screen.dart            # History & cumulative details
```

---

## 🚀 セットアップ・実行

### 前提条件
- Flutter SDK (>=3.0.0)
- Dart SDK (integrated with Flutter)
- Android SDK 35+ (Androidでの実行時)
- ADB / USB debugging enabled (物理デバイス使用時)

### インストール
```bash
# 依存パッケージをインストール
flutter pub get

# コードジェネレーション実行
flutter pub run build_runner build --delete-conflicting-outputs
```

### 実行

**Edgeブラウザ（Windows）:**
```bash
flutter run -d edge
```

**Androidデバイス（物理端末）:**
```bash
flutter devices                                          # デバイス確認
flutter run -d 8691BFCFAC00003274                       # ID指定で実行
```

**Androidエミュレータ:**
```bash
flutter emulators --launch <emulator_name>
flutter run -d <emulator_id>
```

---

## ✅ 本セッションで完了した内容

### 実装完了
- ✅ 5捨6入方式の点数計算システム
- ✅ 着順ボーナス機構（+30, +10, -10, -30pt）
- ✅ トップボーナス自動計算（合計0pt調整）
- ✅ 入力バリデーション（100,000点合計確認）
- ✅ ボーナス合計バリデーション（0pt確認）
- ✅ マイナス入力対応（先頭に"-"入力可能）
- ✅ 累計・履歴機能の実装
- ✅ shared_preferences統合
- ✅ JSON永続化
- ✅ プレイヤー別累計表示（降順ソート）
- ✅ 過去ゲーム履歴表示（日時付き）
- ✅ Webバージョン（Edge）で全機能動作確認
- ✅ **Androidデバイス展開成功** (P30 ROW / Android 15 API 35)

### テスト済み機能
- 正数・負数両方の入力と計算
- バリデーション動作（入力エラー表示）
- LocalStorage保存・読み込み
- 履歴クリア機能
- Web版での累計計算

---

## 🚨 既知の問題・制限

| 項目 | 状態 | 詳細 |
|------|------|------|
| iOS対応 | 🟡 未実装 | Flutter iOS SDK別途インストール必要 |
| Linux対応 | 🟡 未実装 | Linux SDK別途インストール必要 |
| クラウド同期 | 🟡 未実装 | デバイスローカルのみ保存 |
| プレイヤープロフィール | 🟡 未実装 | 名前のみ管理、ユーザー帳票機能なし |
| エクスポート機能 | 🟡 未実装 | CSV/PDF出力未対応、テキストコピーのみ |
| オフライン専用 | ✅ 仕様 | インターネット接続不要 |

---

## 📋 今後の課題・改善項目

### 高優先度（実装推奨）
1. **iOS対応**
   - 依存: Flutter iOS SDK インストール
   - 工数: 中程度（プラットフォーム固有コード最小限）
   - 効果: iPhone ユーザーへの対応

2. **プレイヤー管理機能**
   - 機能: よく使う4人の名前セットを保存
   - 実装: SharedPreferences + "よく使う組み合わせ" リスト
   - 効果: 入力の高速化

3. **データエクスポート**
   - CSV形式: 日付・プレイヤー名・ポイント
   - JSON形式: バックアップ・別デバイス復元
   - 実装: file_picker + csv/json_serializable
   - 効果: データ分析・バックアップ

4. **詳細統計機能**
   - グラフ表示: 月別ポイント推移
   - 勝率計算: 1位率・平均順位
   - パッケージ: fl_chart + データ集計ロジック

5. **通知機能**
   - ゲーム開始/終了時のリマインダー
   - パッケージ: flutter_local_notifications
   - 効果: 定期的なセッション記録促進

### 中優先度（UI/UX改善）
6. **ダークモード対応**
   - テーマ切り替え機能
   - 実装: ThemeData 分離
   - 効果: 夜間使用時の目への負担軽減

7. **複数言語対応（i18n）**
   - 日本語 / 英語 最低限対応
   - パッケージ: intl + localization_tool
   - 効果: 国際利用対応

8. **入力形式の多様化**
   - 自動着順入力（点数の大小から自動判定）
   - ポイント直接入力モード
   - 実装: 入力フォーム UI 分岐

9. **結果画面の改善**
   - ビジュアル表現: ランキング表示
   - アニメーション: スコア表示時の演出
   - シェア機能: SNS投稿（画像化）

### 低優先度（オプション機能）
10. **ネットワークマルチプレイ**
    - 複数デバイス間での自動同期
    - バックエンド: Firebase Realtime DB
    - 効果: リモート対戦・複数拠点同時管理

11. **AI対戦機能**
    - 仮想プレイヤーとの麻雀シミュレーション
    - パッケージ: dart_ai / TensorFlow Lite
    - 効果: 娯楽性向上

12. **決済・課金機能**
    - 有料版・課金要素
    - バックエンド: Google Play Billing / App Store
    - 効果: 収益化

---

## 📈 進捗トラッキング

```
[████████████████████░░░░░░░░░░░░░] 65% 完了

コア機能（必須）: 100%
├─ 計算ロジック ✅
├─ 入力検証 ✅
├─ 履歴管理 ✅
└─ Android展開 ✅

プラットフォーム対応: 40%
├─ Web ✅
├─ Android ✅
├─ Windows ✅
├─ iOS ⏳
└─ Linux ⏳

データ管理: 60%
├─ LocalStorage ✅
├─ プレイヤー管理 ⏳
├─ クラウド同期 ⏳
└─ エクスポート ⏳

UX/UI: 50%
├─ Material Design ✅
├─ 入力UI ✅
├─ ダークモード ⏳
└─ i18n対応 ⏳
```

---

## 🤝 使用技術リンク

- [Flutter公式ドキュメント](https://flutter.dev)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [Material Design](https://material.io/design)

---

## 📝 ライセンス

MIT License (プライベートプロジェクト)

---

**最終更新**: 2026年2月3日  
**ステータス**: Android展開成功 ✅

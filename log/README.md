# 開発ログ

## 2026-02-04

### 実行・検証
- Web（Edge）で起動確認。
- Androidエミュレーター起動と実機相当の動作確認。
- 画面下部のRenderFlex overflow（Home）をスクロール化で解消。

### 機能追加: 飛びルール
- 飛びルールの有効/無効切替を設定に追加。
- 飛びペナルティ/飛ばした人のボーナスを設定可能化。
- 点数入力でマイナスを検出し、飛び対象を表示。
- 「飛ばした人（任意）」の選択を追加。
- 飛びが複数人の場合、飛ばした人の加算は人数分。
- 飛ばした人が「なし」の場合は飛び処理を適用しない。
- 飛んだ人は「飛ばした人」の選択肢から除外。

### UI/UX
- 結果画面の内訳を折りたたみ（展開）表示に変更。
- 結果画面で飛び調整の内訳表示を追加。
- 累計追加後、一定時間でホームに戻る導線を改善。

### 設定表示/共有
- ホーム画面と結果画面の設定表示に飛びルール情報を追加。
- 結果コピーに飛びルールの設定/結果を追記。

### 修正・調整
- 飛びの計算ロジックと合計検証を調整。
- 旧設定からのnull問題に対処。

### 変更ファイル
- lib/models/game_model.dart
- lib/services/calculator_service.dart
- lib/screens/score_input_screen.dart
- lib/screens/settings_screen.dart
- lib/screens/result_screen.dart
- lib/screens/home_screen.dart

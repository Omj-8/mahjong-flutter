# Firebase Analytics導入手順

## 1. Firebase Console設定
1. [Firebase Console](https://console.firebase.google.com/)にログイン
2. 新しいプロジェクト作成: "mahjong-calculator"
3. Android appを追加:
   - パッケージ名: `com.omj8.mahjong_calculator`
   - google-services.jsonダウンロード
4. Analytics有効化

## 2. 必要な依存関係をpubspec.yamlに追加

```yaml
dependencies:
  # 既存の依存関係...
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.8

dev_dependencies:
  # 既存の依存関係...
```

## 3. ファイル配置
- `android/app/google-services.json` を配置
- `android/app/build.gradle.kts` にplugin追加

## 4. 実装箇所
- main.dart: Firebase初期化
- 各画面: イベント送信
- エラーハンドリング: クラッシュレポート送信

## 5. 主要な分析イベント
- ゲーム計算実行回数
- 設定変更頻度
- 機能利用状況
- エラー発生箇所
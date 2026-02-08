# リリース準備チェックリスト

## 🔒 Android署名キー作成（必須）
```bash
# 署名キー作成コマンド
keytool -genkey -v -keystore mahjong-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias mahjong

# 作成後、android/key.properties を以下で作成：
storePassword=【設定したパスワード】
keyPassword=【設定したパスワード】
keyAlias=mahjong
storeFile=../mahjong-release-key.keystore
```

## 📱 Google Play Console準備
1. Google Play Console開発者アカウント作成（$25一時払い）
2. アプリ情報登録
   - アプリ名: 麻雀ウマオカ計算機
   - カテゴリ: ゲーム/カード
   - 対象年齢: 全年齢
3. ストア掲載情報作成

## 🎨 アプリアイコン・スクリーンショット
- [ ] アプリアイコン（1024x1024）
- [ ] フィーチャーグラフィック（1024x500）
- [ ] スマートフォン用スクリーンショット（最低2枚、最大8枚）
- [ ] タブレット用スクリーンショット（推奨）

## 🔧 Technical準備
- [ ] プライバシーポリシー作成・公開
- [ ] 利用規約作成
- [ ] アプリバージョン管理戦略決定

## 📊 GitHub Actions CI/CD
- [ ] 自動テスト実行
- [ ] 自動ビルド＆デプロイ
- [ ] リリースノート自動生成

## 📈 分析・マーケティング準備
- [ ] Google Analytics for Firebase導入
- [ ] クラッシュレポート設定
- [ ] ユーザーフィードバック収集仕組み

## 🎯 今後の機能拡張（差別化）
- [ ] データエクスポート機能（CSV、Excel）
- [ ] テーマ切替（ダーク・ライト）
- [ ] 複数計算ルール対応
- [ ] プレイヤー管理機能
- [ ] 統計画面

## 🚀 リリーススケジュール
- Week 1: 署名キー・ストア準備
- Week 2: CI/CD・アナリティクス導入
- Week 3: 最終テスト・ポリシー準備
- Week 4: リリース申請・公開
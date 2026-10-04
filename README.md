# 天気予報アプリ：書籍のサンプルコード

本リポジトリは、『SwiftUIの状態管理：アプリ開発で学ぶTCA』で使用する天気予報の試作アプリのサンプルコードです。

小さなアプリを使って、地点検索と天気予報APIの技術検証(FS:Feasibility Study)を行います。
TCAは使用していません。本番運用を想定した完全なエラー処理やUIではありません。

## 本アプリでの検証内容

1. 地名を入力する
2. MKLocalSearchで候補を取得する
3. 候補から地点を選択する
4. 緯度・経度をOpen-Meteo Forecast APIへ渡す
5. 3日分の天気予報を表示する

## サンプルコード一覧

本書のサンプルコードは、用途ごとに次の3つのリポジトリに分かれています。

| サンプル | リポジトリ | 用途 |
| --- | --- | --- |
| 旅行計画アプリ Shiori | [SwiftUIStateManagementBook-Shiori](https://github.com/takenori-kabeya/SwiftUIStateManagementBook-Shiori) | 本編で開発するアプリです。状態の所有、編集とキャンセル、外部処理、非同期処理の制御、画面遷移などを、アプリへの導入を通して扱います。 |
| カウンタアプリ | [SwiftUIStateManagementBook-Counter](https://github.com/takenori-kabeya/SwiftUIStateManagementBook-Counter) | 本リポジトリです。TCAの基本構造や親子Featureの組み合わせを確認するためのサンプルです。 |
| 天気予報の試作アプリ | [SwiftUIStateManagementBook-WeatherPrototype](https://github.com/takenori-kabeya/SwiftUIStateManagementBook-WeatherPrototype) | 天気予報APIの呼び出しと、取得した情報の表示を確認するための試作アプリです。 |

## 本文とコードの対応

本文では、確認したい仕組みに合わせて、カウンタアプリの構成や実装を変更します。本文中のコードを確認するときは、本文に記載されたリンクまたはタグ名から、その時点のコードを参照してください。

## データ提供

天気予報データは [Open-Meteo](https://open-meteo.com/) から取得しています。

Weather data by Open-Meteo.com
Open-MeteoのAPIデータはCC BY 4.0の条件で提供されています。

## 使用技術

- SwiftUI
- Observation
- MapKit / MKLocalSearch
- URLSession
- Open-Meteo Forecast API
- Swift Testing

## 注意事項

- APIの仕様、料金、利用条件は変更される可能性があります。
- 利用時には各サービスの最新の公式情報を確認してください。
- 天気コードは「晴れ・曇り・雨」の3種類に単純化しています。
- 日付は検証を簡単にするため文字列として扱っています。

## 動作確認環境

- Xcode: Version 26.6 (17F113)
- Swift: swift-driver version: 1.148.6 Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)
- iOS: 26.5(23F77) (シミュレータのみで検証)

## 実行方法

1. リポジトリをクローンします。
2. `WeatherForecastFS.xcodeproj`をXcodeで開きます。
3. iOSシミュレータを選択して実行します。

APIキーの設定は不要です。

実機で実行する場合は、XcodeのSigning & Capabilitiesで自分のDevelopment Teamを選択してください。


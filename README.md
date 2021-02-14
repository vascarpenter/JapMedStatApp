### JapMedStatApp

* 日本医療統計のテキストを整形し入力しやすくするアプリ
* 完全に私用です

テキストの形式

```
88y11m F  <-- 年齢
タケキャブ錠20ｍｇ 1 錠 / １日１回　朝食後   <-- 薬が羅列
アロプリノール錠100mg「杏林」 （ザイロリック　アロチーム） 1 錠 / １日１回　朝食後

A)  <-- 空行とA)は無視してよい
# pAf（サンリズム＋ワーファリン）→イグザレルト　<-- 先頭に半角#のついた行は、次の年齢の段落が出るまで assessment
　BNP 23 (H27.5)→38.8(H28.1)→52.4(H28.5)→47.4(H29.4)→114(H29.11)→61.3(H30.12)
# そけいヘルニア 2017.11.16　根治術（UHS）
```
これを
```
88歳 11ヶ月   F  <-- 年齢
タケキャブ錠20ｍｇ 1 錠 / １日１回　朝食後     0001   <-- 期待薬効数字を後ろにつける
アロプリノール錠100mg「杏林」  1 錠 / １日１回　朝食後  6409

# pAf（サンリズム＋ワーファリン）→イグザレルト  <-- assessmentはそのまま
# そけいヘルニア 2017.11.16　根治術（UHS）
```

に整形しなおすソフト

- ビルド方法
  - https://github.com/stephencelis/SQLite.swift を使用
  - XcodeにCarthage由来のFrameworkを追加する手段    - Xcodeを起動
    - terminalにてプロジェクトフォルダにcdした後
    - `carthage update --platform macOS  --use-xcframeworks` を入力
```
*** Fetching SQLite.swift
*** Checking out SQLite.swift at "0.12.2"
*** xcodebuild output can be found in /var/folders/hp/t2gwwzpx27zdx_rnz40jnjcr0000gn/T/carthage-xcodebuild.7ufJh4.log
*** Building scheme "SQLite Mac" in SQLite.xcodeproj
```

   - `Carthage/Build`に `SQLite.xcframework` ができるため、これを Xcodeののプロジェクトフォルダにドラッグ＆ドロップ
   - アプリにしたため Framework や sqliteファイルのbundleが楽だった

- 実行
  - Open SJIS file...からSJISファイルを指定すると、その下のTextEditPaneに変換されたテキストが表示される

- SwiftUIを初めてまともに使いました

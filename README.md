# **Novel Studio Lint**

## **Overview**

テキストを小説向けのフォーマットに整形する Swift ライブラリです。  
小説執筆アプリ **Novel Studio** 向けに開発されました。

[Novel Studio - App Store](https://apps.apple.com/jp/app/novel-studio/id1499642698)

## **Features**

- 各段落の文末の不必要なスペースを削除します。
- 各段落にインデントを挿入します。
- 感嘆符（！）や疑問符（？）の後ろにスペースを挿入します。
- 開き括弧の前のスペースを削除します。
- 閉じ括弧の前の句読点を削除します。

## **Installation**

### **CocoaPods**

```ruby
pod 'NovelStudioLint'
```

## **License**

`LICENSE` ファイルをご参照ください。

## **API References**

各 API では，一部の半角記号は全角に置き換えられます。

- スペース
- カギ括弧
- 丸括弧

### **各段落の文末の不必要なスペースを削除**

```swift
func NovelStudioLint.deleteEndSpaces(sentence: String) -> String
```

### **各段落にインデントを挿入**

```swift
func NovelStudioLint.insertIndent(sentence: String) -> String
```

すでにインデントされている段落や，括弧などで始まる段落はインデントされません。

### **感嘆符（！）や疑問符（？）の後ろにスペースを挿入**

```swift
func NovelStudioLint.insertSpaceAfterReservedMarks(sentence: String) -> String
```

文末や閉じ括弧の前などにはスペースは挿入されません。

```
「粉砕！玉砕！大喝采！」
　↓
「粉砕！　玉砕！　大喝采！」
```

### **開き括弧の前のスペースを削除**

```swift
func NovelStudioLint.deleteSpacesBeforeOpeningBracket(sentence: String) -> String
```

一般に，括弧で始まる段落は小説ではインデントしません。

```
　「君たちを待っていたよ」
　↓
「君たちを待っていたよ」
```

### **閉じ括弧の前の句読点を削除**

```swift
func NovelStudioLint.deletePunctuationsBeforeClosingBracket(sentence: String) -> String
```

一般に，閉じ括弧の前の句読点は小説では省略します。

```
「そのとおり，時は逃げるものだ。」
　↓
「そのとおり，時は逃げるものだ」
```

## **Contact Us**

@shirajira / contact@novel-stud.io

(C) 2021 [Novel Studio](https://novel-stud.io/)

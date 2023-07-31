## プログラミングにも使える日本語等幅フォント Cyroit
Cyroit (しろいと) はRicty生成スクリプトで遊んでいるうちに合成フォント製作の沼にはまったことで生まれたフォントです。  
全角英数記号や半角カナなどにアンダーラインが引いてあるため、括弧の組み合わせが全角と半角になっていたり、波ダッシュであるべきところに全角チルダが使われていたりしてもすぐに判別することができます。  
また全角スペースを可視化に加え、SP (スペシャルまたはスペース) 版は半角スペース、ノーブレークスペースも可視化しています。半角スペースの表示機能の無いエディタやコマンドランチャー等で使用すると便利かもしれません。

フォントサンプル ([CotEditor](https://coteditor.com)にて)
![ScreenShop](/SS/SS.png)

## その他の特徴
- 主にラテン文字のグリフは[Inconsolata](https://github.com/googlefonts/Inconsolata)を使用しています。
- 主に仮名文字、ギリシア文字、キリル文字のグリフは[CircleM+ 1m](https://mix-mplus-ipa.osdn.jp)を使用しています。
- 主に漢字のグリフは[BIZUDゴシック](https://github.com/googlefonts/morisawa-biz-ud-gothic)を使用しています。
- [Nerd Fonts](https://www.nerdfonts.com) Ver.3を追加しています。
- [ricty_generator](https://rictyfonts.github.io)をForkしたスクリプトで自動生成させています。生成時にグリフの改変や微調整を行っています。

### ラテン文字について
- 小文字のgをオープンテールに改変しています。
- アスタリスクのスポークを6本に増やしています。
- チルダの波が強調されています。
- 数字の7の先端を折り曲げています。
- その他のグリフについても視認性向上やバランスをとるための微調整を施しています。

### 仮名文字について
- 一部のひらがなを教科書体っぽく (跳ねたり突き抜けたり) しています。
- 濁点、半濁点の大きさや位置を変えています。
- イコールと区別しやすいようにダブルハイフンの先端を少し折っています。
- ボールド体のウェイトを調整しています。
- その他のグリフについても一部微調整を施してあるものがあります。

### 漢字について
- カタカナや図形の○などと区別しやすいように一部の漢字にウロコを追加しています。
- いわゆる土吉 (吉の異体字) を新規に追加しています。
- ボールド体のウェイトを調整しています。

### 記号類について
- 他の記号と区別しやすいように破線にしてある縦線やダッシュ類があります。
- 学術記号、ショートカット記号など一部の記号を新規に追加しています。

### 機能的なものについて
- IVSを利用した異体字表示に対応しています。
- アイヌ語カナ表記に対応しています。
- vertフィーチャのみですが、縦書き表示に対応しています。
- 素材元のフォントにあったGSUB、GPOSフィーチャは大幅に削っています。

## フォントファミリーの種類
- Cyroit:   通常版
- CyroitSP: 半角スペース、ノーブレークスペース (0x00a0) も可視化したバージョン

## ライセンス
- フォントのライセンス : [SIL Open Font License 1.1](build/OFL.txt)
- スクリプトのライセンス : [MIT](./LICENSE.txt)

素材元のフォントやスクリプトはライセンスが異なる場合があります。

## スクリプトの使い方

### ビルド環境
Cyroitは、以下の環境でビルドできることを確認しています。
- OS: macOS Monterey (version 12.6.8)
- Shell: zsh 5.8.1 (x86_64-apple-darwin21.0)
- FontForge: 20230101
- FontTools: 4.41.1

### 実行方法
あらかじめ、パッケージマネージャ等を利用してFontForgeとFontToolsをインストールしておいてください。

スクリプトのある場所をカレントディレクトリにして
```
./run_ff_ttx.sh -F
```
異常なく完了した場合、直下のbuildフォルダにフォントが保存されます。

フォントをあれこれしたい人は以下のオプションが役に立つかもしれません。

`-h` ヘルプを表示します。  
`-d` 下書きモード。時間のかかる処理を飛ばします。改変したグリフを確認するのに便利です。  
`-de` 同じく下書きモードですが、Nerd fontsを追加します。  
`-e` 通常処理でNerd fontsを追加します。  
`-o` 通常処理でオブリーク体を追加で生成します。  
`-eo` 通常処理でNerd fontsを追加した上、オブリーク体も追加で生成します。  
`-F` 完成品を生成します。通常版とSP版を生成しますので時間がかかります。気長にお待ちください。  

オプションなしの場合、通常処理でNerd fonts無し、オブリーク体無しになります。  
また`-F`オプション以外の時は、フォント名はCyroitですがSP版のみ生成します。

## メモ
Powerlineグリフを使用する際はフォントサイズを12ptか14ptにすると、よい感じに表示されるかもしれません。

## 謝辞
Cyroitの合成にあたり、素晴らしいフォントとツール類を提供してくださっております製作者の方々に感謝いたします。

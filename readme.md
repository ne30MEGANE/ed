# EDラインエディタ

## 概要
テキスト処理課題で制作したクラシカルなラインエディタです。

---

## コマンド一覧
### aコマンド
*(.)a*
　指定されたアドレスが示す行の直後に0行以上のテキストを挿入します。.のみが入力されると挿入モードを終了します。現在行番号は最後に挿入された行になります。

### cコマンド
*(.)c*
　指定されたアドレスが示す行を削除し、0行以上のテキストで置き換えます。現在行番号は最後に挿入された行になります。

### dコマンド
*(.,.)d*
　指定されたアドレスが示す行を削除します。現在行番号はバッファの先頭になります。

### iコマンド
*(.)i*
　指定されたアドレスが示す行の直前に0行以上のテキストを挿入します。.のみが入力されると挿入モードを終了します。現在行番号は最後に挿入された行になります。

### jコマンド
*(.,.+1)j*
　指定されたアドレスが示す2つの行を結合し、1行にします。現在行番号は結合される側の行になります。不正なアドレスが指定された場合何も処理は行われず、現在行番号も変更されません。

### nコマンド
*(.,.)n*
　指定されたアドレスが示す行を、行番号と共に出力します。現在行番号は最後に出力された行になります。

### pコマンド
*(.,.)p*
　指定されたアドレスが示す行を出力します。現在行番号は最後に出力された行になります。

### qコマンド
*q*
　edを終了します。バッファに変更が加わっていても警告は発しません。

### wコマンド
*(1,$)w file*
　指定されたアドレスが示す行を *file* に書き込みます。 *file* が指定されない場合は元のファイルに上書きされるか、デフォルトファイル名(file.txt)で新規ファイルが作成され、保存されます。アドレスが指定されない場合はバッファ内の全てのデータを書き込みます。

### wqコマンド
*(1,$)wq file*
　wコマンドを実行したのちqコマンドでedを終了します。

### =コマンド
*=*
　現在行番号を出力します。

### epsコマンド
*.*
　指定されたアドレスが示す行を出力し、現在行番号をその行に変更します。バッファに存在しない行を指定するとエラーになります。
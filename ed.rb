class REPL
    def initialize
        @buffer = Array.new # バッファ
        @cl = 0 # カレント行
        @input = Array.new # 毎回の入力用
        @output = Array.new # 毎回の出力用
        @prompt = "command>" # プロンプト
        if ARGV[0] # ファイルが指定された時
            f = open(ARGV[0])
            f.each do |line|
                @buffer.push line.chomp # 改行コードを消してバッファーに読み込む
            end
            @cl = @buffer.size - 1 # ファイルを読み込んだ時のカレント行は一番最後(配列のサイズ-1)
            puts "-- #{ARGV[0]} opend --"
            puts @buffer
        else
            puts "-- new file created --"
        end
        loop do
            ed_read
            ed_eval
            ed_print
        end
    end

    private
    def ed_read # コマンド受け付け
        @output = "" # 出力用変数を空にする
        print @prompt # プロンプト出力
        @input = STDIN.gets(chomp: true)
    end

    def ed_eval # 解釈
        addr = '(?:\d+|[.$,;]|\/.*\/)' # 数字か.$,;か正規表現(任意の文字列)
        cmnd = '(?:[acdgijnpqrw=]|wq|\z)' # 1文字のコマンド各種 or wqコマンド
        prmt = '(?:.*)' # 任意の文字列
        if @input =~ /\A(#{addr}(,#{addr})?)?(#{cmnd})(#{prmt})?\z/
            # p $1, $2, $3, $4 # for debug
            # $1 addr,addrか左側だけ / $2 addr右側 ←指定されてなかったらnil
            # $3 cmnd / $4 prmt ←指定されていなかったら空文字列

            begin
            case $3 # コマンドによって分岐
                when "p", "n" then # 出力
                    # p addr_num $1, $2 # for debug
                    if $4.empty? # prmtが指定されていないとき
                        n = addr_num $1, $2
                        n[0].step(n[1]) do |i| # n,mの時nからmまで繰り返す
                            if $3 == "p" # 普通に出力(pコマンド)
                                puts @buffer[i-1]
                            else # 行番号と一緒に出力(nコマンド)
                                puts "#{i}: #{@buffer[i-1]}"
                            end
                        end
                    else # エラー
                        @output = "?"
                    end
                when "q" then # 終了
                    if $1 or $2 or $3.empty? # addrかprmtが指定されていないとき
                        @output = "?"
                    else
                        exit
                    end
                end
            rescue # コマンドとして認識されたけどそれ以降の処理でエラーになったやつを全部キャッチして？だす
                @output = "?"
            end
        else
            @output = "?" #どのコマンドにも当てはまらない時
        end
    end
    
    def ed_print # 結果を出力
        puts @output unless @output.empty? # 出力内容がある時だけ
    end

    def addr_num a, b # $1$2を引数にとってn,mをintの[n,m]っていう配列にするやつ
        if b # $2がnilじゃない時
            ans = a.split(",") # カンマ区切りで前と後ろに分ける
            [ans[0].to_i, ans[1].to_i] # int配列にして返す
        else # $2に何も入ってなくてアドレスが一個しか指定されない時
            [a.to_i, a.to_i] # nをn,nという認識にして配列で返す
        end
    end
end

REPL.new
class REPL
    def initialize
        @buffer = Array.new # バッファ
        @cl = 0 # カレント行
        @input = Array.new # 毎回の入力用
        @output = Array.new # 毎回の出力用
        @prompt = "command>" # プロンプト
        @file = nil # ファイルが指定されたときファイル名を保存
        if ARGV[0] # ファイルが指定された時
            @file = ARGV[0] # ファイル名(パス)を保持
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
        cmnd = '(?:wq|[acdgijnpqrw=]|\z)' # 1文字のコマンド各種 or wqコマンド
        prmt = '(?:.*)' # 任意の文字列
        if @input =~ /\A(#{addr}(,#{addr})?)?(#{cmnd})(#{prmt})?\z/
            # p $1, $2, $3, $4 # for debug
            # $1 addr,addrか左側だけ / $2 addr右側 ←指定されてなかったらnil
            # $3 cmnd / $4 prmt ←指定されていなかったら空文字列

            # begin
                # p "cmd_#{$3}" # for debug
                unless $3.empty? #コマンドが指定された時
                    self.send("cmd_#{$3}", $1, $2, $3, $4)
                else #数字だけの時(改行コマンド)
                    # p "eps" # for debug
                    self.send("cmd_eps", $1, $2, $3, $4 )
                end
            # rescue # コマンドとして認識されたけどそれ以降の処理でエラーになったやつを全部キャッチして？だす
            #     @output = "?"
            # end
        else
            @output = "?" #どのコマンドにも当てはまらない時
        end
    end
    
    def ed_print # 結果を出力
        puts @output unless @output.empty? # 出力内容がある時だけ
    end

    def addr_num a, b # 記号とか数字とか解釈してユーザが指定した行の数字を配列で返すマン
        case a
        when "." then # カレント行
            [@cl + 1, @cl + 1]
        when "$" then # 最後の行
            [@buffer.size, @buffer.size]
        when "," then # 1,$
            [1, @buffer.size]
        when ";" then # .,$
            [@cl + 1, @buffer.size]
        when /\d/ then # 数字で直接指定
            if b # $2がnilじゃない時
                ans = a.split(",") # カンマ区切りで前と後ろに分ける
                [ans[0].to_i, ans[1].to_i] # int配列にして返す
            else # $2に何も入ってなくてアドレスが一個しか指定されない時
                [a.to_i, a.to_i] # nをn,nという認識にして配列で返す
            end
        when /.*/ then # 正規表現
            # あとで
        else # アドレスが指定されなかった場合
            [@cl + 1, @cl + 1] # カレント行
        end
    end

    def cmd_p *d
        if d[3].empty? # prmtが指定されていないとき
            n = addr_num d[0], d[1]
            unless n[0].nil?
                n[0].step(n[1]) do |i| # n,mの時nからmまで繰り返す
                    puts @buffer[i-1]
                    @cl = i-1 # カレント行は出力した最後の行
                end
            else
                @output = "?"
            end
        else # エラー
            @output = "?"
        end
    end

    def cmd_n *d
        if d[3].empty? # prmtが指定されていないとき
            n = addr_num d[0], d[1]
            unless n[0].nil?
                n[0].step(n[1]) do |i| # n,mの時nからmまで繰り返す
                    puts "#{i}: #{@buffer[i-1]}"
                    @cl = i-1 # カレント行は出力した最後の行
                end
            else
                @output = "?"
            end
        else # エラー
            @output = "?"
        end
    end

    def cmd_q *d
        # p d # for debug
        if d[0] or d[1] or !d[3].empty? # いらないaddr/prmtがある時
            @output = "?"
        else
            exit
        end
    end

    def cmd_d *d
        if d[3].empty?
            n = addr_num d[0], d[1]
            unless n[0].nil?
                n[0].step(n[1]) do |i| # n,mの時nからmまで繰り返す
                    @buffer.delete_at i-1 #指定された行を削除
                    @cl = 0 # カレント行は0に
                end
            else
                @output = "?"
            end
        else
            @output = "?"
        end
    end

    def cmd_a *d
        if d[3].empty?
            n = addr_num d[0], d[1]
            
            insert = Array.new
            while true # 入力を受け付ける
                str = STDIN.gets(chomp: true)
                if str =~ /\./ # .単体が入力された時
                    break
                else #それ以外のなんらかの文字
                    insert << str
                end
            end
            insert.each_with_index do |i, idx| # バッファに追加する(n行目の次に追加)
                @buffer.insert n[1]+idx, i
                @cl = n[1] + idx # カレント行は最後に挿入された行
            end
        else
            @output = "?"
        end
    end

    def cmd_i *d
        if d[3].empty?
            n = addr_num d[0], d[1]
            
            insert = Array.new
            if n[1] != 0
                while true # 入力を受け付ける
                    str = STDIN.gets(chomp: true)
                    if str =~ /\./ # .単体が入力された時
                        break
                    else #それ以外のなんらかの文字
                        insert << str
                    end
                end
                insert.each_with_index do |i, idx| # バッファに追加する(n行目の前に追加)
                    @buffer.insert n[1]-1+idx, i
                    @cl = n[1] - 1 + idx # カレント行は最後に挿入された行
                end
            else
                @output = "?" # アドレスに0は無効
            end
        else
            @output = "?"
        end
    end

    def cmd_j *d
        if d[3].empty?
            n = addr_num d[0], d[1]
            if n[0]+1 == n[1] # (a, a+1)で指定された時のみ結合を実行する
                newrow = @buffer[n[0]-1] + @buffer[n[1]-1]
                @buffer[n[0]-1] = newrow #置き換える
                @buffer.delete_at n[1]-1 #くっつけた後ろの行を消す
                @cl = n[0]-1 # カレント行は結合された側にする
            else # 同じ数字同士とか複数行とか変なアドレス指定の仕方をされたらエラーにする
                @output = "?"
            end
        else
            @output = "?"
        end
    end

    def cmd_c *d
        if d[3].empty?
            n = addr_num d[0], d[1]

            insert = Array.new
            while true # 入力を受け付ける
                str = STDIN.gets(chomp: true)
                if str =~ /\./
                    break
                else
                    insert << str
                end
            end
            n[0].step n[1] do |i| # 指定行を削除
                # 一応アドレス二つ取れるようになってるけど
                # 本来そんなような使い方はされないものだと思います。
                @buffer.delete_at i-1
            end
            insert.each_with_index do |i, idx| # 内容を挿入
                @buffer.insert n[0]-1+idx, i
                @cl = n[0] - 1 + idx # カレント行は最終入力行
            end

        else
            @output = "?"
        end
    end

    def cmd_w *d
        #アドレスの数字処理
        if d[0].nil? and d[1].nil? # アドレスが指定されないとき
            n = [1, @buffer.size]
        else
            n = addr_num d[0], d[1]
        end

        #ファイル名関係の処理
        if d[3].empty?
            filename = @file || "file.txt" # 開いた元のファイル名orデフォルトファイル名
        else
            filename = d[3].to_s
        end
        
        #書き込みと書き込みバイト数出力
        size = 0
        File.open(filename, "w") do |f|
            @buffer.each do |b|
                size += f.write b.to_s + "\n"
            end
        end
        @output = (size - @buffer.size).to_s # 書き込んだbyte数を出力
    end

    def cmd_wq *d
        cmd_w *d
        exit
    end

    def cmd_= *d
        if d[0].nil? and d[1].nil? and d[3].empty? # アドレスとパラメータが空の時
            @output = (@cl+1).to_s
        else
            @output = "?"
        end
    end

    def cmd_eps *d
        begin
            if d[2].empty? and d[3].empty? # コマンドとパラメータが空である時
                n = addr_num d[0], d[1]
                if n[1] <= @buffer.size
                    @cl = n[1]-1 unless n[1].nil? # 後に指定された方をカレント行にする
                    @output = @buffer[@cl] # カレント行を出力
                else # 指定された行がまだ存在してなかった場合
                    @output = "?"
                end
            else
                @output = "?"
            end
        rescue
            @output = "?"
        end
    end

end

REPL.new
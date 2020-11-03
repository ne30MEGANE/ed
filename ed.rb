class REPL
    def initialize
        @buffer = Array.new # バッファ
        @input = Array.new # 毎回の入力用
        @output = Array.new # 毎回の出力用
        @prompt = "command>" # プロンプト
        if ARGV[0] # ファイルが指定された時
            f = open(ARGV[0])
            f.each do |line|
                @buffer.push line.chomp # 改行コードを消してバッファーに読み込む
            end
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
        print @prompt # プロンプト出力
        @input = STDIN.gets(chomp: true)
    end

    def ed_eval # 解釈
        addr = "(?:\d+|[.$,;]|\/.*\/)"
        cmnd = "(?:[acdgijnpqw=]|wq|\z)" # 1文字のコマンド各種 or wqコマンド
        prmt = "(?:.*)"
        if @input =~ /\A(#{addr}(,#{addr})?)?(#{cmnd})(#{prmt})?\z/
        
        else
            @output = "?" #どのコマンドにも当てはまらない時
        end
    end
    
    def ed_print # 結果を出力
        puts @output
    end
end

REPL.new
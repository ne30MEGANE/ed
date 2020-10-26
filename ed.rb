class REPL
    def initialize
        @buffer = Array.new # バッファ
        @input = Array.new # 毎回の入力用
        @output = Array.new # 毎回の出力用
        @prompt = "command>" # プロンプト
        if ARGV[0] # ファイルが指定された時
            f = open(ARGV[0])
            f.each do |line|
                @buffer.push(line.chomp) # 改行コードを消してバッファーに読み込む
            end
            puts("-- #{ARGV[0]} opend --")
            puts(@buffer)
        end
        loop{
            ed_read
            ed_eval
            ed_print
        }
    end

    def ed_read # コマンド受け付け
        print(@prompt) # プロンプト出力
        @input = STDIN.gets(chomp: true).split(" ")
    end

    def ed_eval # 解釈
        case @input[0]
        when "a" then
            @output = "a"
        when "c" then
            @output = "c"
        when "d" then
            @output = "d"
        when "g" then
            @output = "g"
        when "i" then
            @output = "i"
        when "j" then
            @output = "j"
        when "n" then
            @output = "n"
        when "q" then
            @output = "q"
        when "w" then
            @output = "w"
        when "wq" then
            @output = "wq"
        when "=" then
            @output = "="
        else
            @output = "?" #どのコマンドにも当てはまらない時
        end
    end
    
    def ed_print # 結果を出力
        puts(@output)
    end
end

REPL.new
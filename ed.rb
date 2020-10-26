class REPL
    def initialize
        loop{
            read
            eval
            print
        }
    end
    @buffer = [] # バッファ
    @

    def read # コマンド受け付け
        STDIN.gets
        puts($_)
    end

    def eval # 解釈
        puts($_)
    end
    
    def print # 結果を出力
        puts("print")
    end
end

REPL.new
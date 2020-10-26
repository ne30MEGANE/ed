class REPL
    def initialize do
        loop{
            read
            eval
            print
        }
    end

    def read # コマンド受け付け
    end

    def eval # 解釈
    end
    
    def print # 結果を出力
    end
end

REPL.new
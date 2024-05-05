class Array
  def SliceTableRow(columnIndex)
    sideSize = Math.sqrt(size).to_i
    slice(columnIndex * sideSize, sideSize)
  end

  def SliceTableColumn(rowIndex)
    sideSize = Math.sqrt(size).to_i
    sideSize.times.map{|i| self[i * sideSize + rowIndex]}
  end

  def SliceTableBlock(blockIndex)
    values = []
    sideSize = Math.sqrt(size).to_i
    blockSideSize = Math.sqrt(sideSize).to_i
    blockSideSize.times{|columnIndex|
      SliceTableRow(blockIndex / blockSideSize * blockSideSize + columnIndex).slice(blockIndex % blockSideSize * blockSideSize, blockSideSize).each{|value| values << value}
    }
    values
  end

  def ToTableString(delimiter = " | ")
    sideSize = Math.sqrt(size).to_i
    sideSize.times.each_with_object([]){|i, object|
      object << SliceTableRow(i).map{|value|
        block_given? ? yield(value) : value.to_s
      }.join(delimiter)
    }.join("\n")
  end
end

module NumberPlaceSolver
  class SatSolver
    class Cnf
      attr_reader :SideSize

      def initialize(inputNumbers)
        @InputNumbers = inputNumbers
        @SideSize = Math.sqrt(inputNumbers.size).to_i
        @Rules = []

        fields = []
        inputNumbers.size.times{|fieldIndex|
          variables = @SideSize.times.each_with_object([]){|numberIndex, object| object << fieldIndex * @SideSize + numberIndex + 1}
          fields << variables

          # フィールド
          AddRule(variables)
        }

        @SideSize.times{|i|
          # 列
          fields.SliceTableRow(i).transpose.each{|variables| AddRule(variables)}

          # 行
          fields.SliceTableColumn(i).transpose.each{|variables| AddRule(variables)}

          # ブロック
          fields.SliceTableBlock(i).transpose.each{|variables| AddRule(variables)}
        }

        # 確定数値
        inputNumbers.each_with_index{|number, i| AddRule([i * @SideSize + number]) if 0 < number}
      end

      def AddRule(variables)
        # いずれかの数値が入る
        @Rules << (variables + [0]).join(" ")
        return if variables.size == 1

        # 重複排除
        variables.combination(2).each{|combination|
          @Rules << (combination.map{|v| -v} + [0]).join(" ")
        }
      end

      def ToString
        (["p cnf #{@InputNumbers.size * @SideSize} #{@Rules.size}"] + @Rules).join("\n")
      end
    end

    def initialize(inputNumbers)
      @Cnf = Cnf.new(inputNumbers)
    end

    def Solve(cnfFilePath, solvedFilePath)
      GenerateCnfFile(cnfFilePath)
      block_given? ? yield(cnfFilePath, solvedFilePath) : `#{ENV["MINISAT"]} #{cnfFilePath} #{solvedFilePath}`
      ToSolvedNumbers(solvedFilePath)
    end

    def GenerateCnfFile(cnfFilePath)
      File.write(cnfFilePath, @Cnf.ToString())
    end

    def ToSolvedNumbers(solvedFilePath)
      return nil if !File.exist?(solvedFilePath)

      solvedNumbers = []
      File.open(solvedFilePath, "r"){|file|
        return nil if file.readline.chomp != "SAT"

        file.readline.split(" ").each{|string|
          value = string.to_i
          next if value <= 0

          solvedNumbers << (value - 1) % @Cnf.SideSize + 1
        }
      }
      solvedNumbers
    end
  end
end
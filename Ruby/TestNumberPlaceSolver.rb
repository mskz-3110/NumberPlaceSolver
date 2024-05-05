require 'test/unit'
require './NumberPlaceSolver.rb'

class TestNumberPlaceSolver < Test::Unit::TestCase
  def StringToArray(string)
    string.delete("\n").each_char.each_with_object([]){|c, object| object << c.to_i}
  end

  def Solve(name, questionNumbers, answerNumbers)
    assert_equal(answerNumbers, NumberPlaceSolver::SatSolver.new(questionNumbers).Solve("#{name}_cnf.txt", "#{name}_solved.txt"))
  end

  def test_Solve_1
    # https://www.nikoli.co.jp/ja/puzzles/sudoku/
    questionNumbers = StringToArray(<<NUMBERS)
800005100
001000800
040200090
000030002
123406789
600010000
080009050
002000400
007600001
NUMBERS
    answerNumbers = StringToArray(<<NUMBERS)
839765124
261394875
745281396
594837612
123456789
678912543
386149257
912573468
457628931
NUMBERS
    Solve(caller_locations(0).first.label, questionNumbers, answerNumbers)
  end

  def test_Solve_2
    # https://rocketnews24.com/2012/07/03/22654/
    questionNumbers = StringToArray(<<NUMBERS)
800000000
003600000
070090200
050007000
000045700
000100030
001000068
008500010
090000400
NUMBERS
    answerNumbers = StringToArray(<<NUMBERS)
812753649
943682175
675491283
154237896
369845721
287169534
521974368
438526917
796318452
NUMBERS
    Solve(caller_locations(0).first.label, questionNumbers, answerNumbers)
  end

  def test_Solve_3
    questionNumbers = StringToArray(<<NUMBERS)
000000000
000000000
000000000
000000000
000000000
000000000
000000000
000000000
000000000
NUMBERS
    answerNumbers = StringToArray(<<NUMBERS)
276135849
835249176
149786235
563412798
412978563
798563412
654321987
321897654
987654321
NUMBERS
    Solve(caller_locations(0).first.label, questionNumbers, answerNumbers)
  end
end
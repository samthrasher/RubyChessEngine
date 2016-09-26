require_relative 'board'

class ChessEngine
  attr_accessor :position, :transposition_table
  def initialize(board, color)
    @position = {board: board, color: color}
    @transposition_table = {}
    @killer = nil
  end

  def best_moves(position, depth)
    @transposition_table = {}
    moves = position[:board].pseudo_legal_moves(position[:color])
    results = moves.map do |move|
      board = position[:board].dup
      board.pseudo_move(position[:color], *move)
      pos = {board: board, color: next_player(position[:color])}
      score = score_position(pos, depth - 1)

      {move: move, score: score}
    end

    results.sort_by {|res| res[:score] * (position[:color] == :white ? -1 : 1)}
  end

  def score_position(position, depth, alpha = -Float::INFINITY, beta = Float::INFINITY)
    return evaluate(position) if depth == 0

    if position[:color] == :white
      score = -Float::INFINITY
      return score if position[:board].in_check?(position[:color])
      if @transposition_table[position_hash(position)]
        # puts "already checked this"
        return @transposition_table[position_hash(position)]
      end
      moves = next_moves(position)
      if @killer && moves.include?(@killer)
        moves = [@killer] + moves
      end

      moves.each do |move|
        board = position[:board].dup
        board.pseudo_move(position[:color], *move)
        pos = {board: board, color: next_player(position[:color])}

        score = [score, score_position(pos, depth - 1, alpha, beta)].max
        alpha = [alpha, score].max
        if beta <= alpha
          @killer = move
          break
        end
      end

      @transposition_table[position_hash(position)] = score
      return score

    else
      score = Float::INFINITY
      return score if position[:board].in_check?(position[:color])
      if @transposition_table[position_hash(position)]
        # puts "already checked this"
        return @transposition_table[position_hash(position)]
      end
      moves = next_moves(position)
      if @killer && moves.include?(@killer)
        moves = [@killer] + moves
      end

      moves.each do |move|
        board = position[:board].dup
        board.pseudo_move(position[:color], *move)
        pos = {board: board, color: next_player(position[:color])}

        score = [score, score_position(pos, depth - 1, alpha, beta)].min
        beta = [beta, score].min
        if beta <= alpha
          @killer = move
          break
        end
      end


      @transposition_table[position_hash(position)] = score
      return score
    end
  end

  def evaluate(position)
    position[:board].value(:white) - position[:board].value(:black)
  end

  def next_positions(position)
    position[:board].pseudo_legal_moves(position[:color]).map do |move|
      board = position[:board].dup
      board.move(position[:color], *move)
      {board: board, color: next_player(position[:color])}
    end
  end

  def next_moves(position)
    position[:board].pseudo_legal_moves(position[:color])
  end

  def position_hash(pos)
    (pos[:board].hash).hash ^ pos[:color].hash
  end

  def next_player(color)
    color == :black ? :white : :black
  end
end


if __FILE__ == $PROGRAM_NAME
  board = Board.tactic1
  e = ChessEngine.new(board, :white)
  start = Time.now
  p start
  p e.best_moves(e.position, 5)
  p Time.now - start
end

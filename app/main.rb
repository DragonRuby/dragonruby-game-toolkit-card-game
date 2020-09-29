require 'app/sound_board.rb'

$sound_board = SoundBoard.new

def tick args
  $sound_board.inputs = args.inputs
  $sound_board.state = args.state
  $sound_board.grid = args.grid
  $sound_board.args = args
  $sound_board.outputs = args.outputs
  $sound_board.tick
end

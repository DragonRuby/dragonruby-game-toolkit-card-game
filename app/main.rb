require 'app/sound_board.rb'

$sound_board = SoundBoard.new

def tick args
=begin
	args.state.query ||= nil
	args.state.stop ||= false
	if args.state.query.nil?
		args.state.query = $gtk.http_post("https://icculus.org/~icculus/testpost.php", { data: 'bloop' } )
	end
	if !args.state.stop
		args.state.stop = args.state.query[:complete]
		puts(args.state.query)
	end
=end
  $sound_board.inputs = args.inputs
  $sound_board.state = args.state
  $sound_board.grid = args.grid
  $sound_board.args = args
  $sound_board.outputs = args.outputs
  $sound_board.tick
end

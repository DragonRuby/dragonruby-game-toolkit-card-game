require 'app/sound_board.rb'

class GTK::Runtime
	def http_post url, form_fields=nil, extra_headers=nil
		form_fields_array = nil
		if !form_fields.nil?
			form_fields_array = []
			form_fields.each do |key, value|
				form_fields_array << key.to_s
				form_fields_array << value.to_s
			end
		end
		http = HTTPCallbacks.new @protect_from_gc
		puts "HTTP: #{s http}", "URL: #{s url}", "HEADS: #{s extra_headers}", "FIELDS: #{form_fields_array.class}"
		post = @ffi_misc.http_post(http, url, extra_headers, form_fields_array)
		puts "POST: #{s post}"
		ready = http.ready(post)
		puts "READY: #{s ready}"
		ready
	end
end

def s obj
	"#{obj.class} | #{obj}"
end

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

#require 'app/sound.rb'
require 'app/grid.rb'
require 'app/button.rb'

# Server address for sending/pulling game state
URL = 'http://localhost:3000/'

class SoundBoard
  attr_accessor :inputs, :state, :outputs, :grid, :args

  def tick
    init unless state.did_init
    check_keyboard
    check_mouse
		upload_state
		download_state
    render
  end

  def check_keyboard
		# C sets all buttons (of size 1,1) to a random color
    if inputs.keyboard.key_down.c
      state.buttons.each do |btn|
				btn.color = [rand(256), rand(256), rand(256)] if btn.size_x == 1 && btn.size_y == 1
      end
    end

		# Up arrow creates more buttons as long as it's held
    if inputs.keyboard.key_held.up
      #state.sounds.push(Sound.new((state.sounds.size + 1).to_s, '', 25))
			i = state.buttons.size + 4 # reset and pattern btns take up 6 spaces (not 2), so need to +4
			btn = Button.new(i % Grid.cols, (i / Grid.cols).floor, 1, 1, *rand_color)
			if btn.valid?
				state.buttons.push(btn)
			else
				puts "ERROR creating button: invalid grid placement."
			end
    end

		# Down arrow removes buttons as long as it's held
    if inputs.keyboard.key_held.down
      #state.sounds.pop
			state.buttons.pop
    end

		##
		# Game state up/down load
		# Multiple clients can send/receive state from the same server.
		# In this way, if one client uploads and the other downloads,
		# both clients will have the same state
		##

		# O sends the game state to a server
		if inputs.keyboard.key_down.o
			export_state
			state.last_pressed = 'O'
			state.last_pressed_at = args.tick_count
		end

		# I pulls the game state from a server
		if inputs.keyboard.key_down.i
			import_state
			state.last_pressed = 'I'
			state.last_pressed_at = args.tick_count
		end
  end

  def check_mouse
    # Check if a button is clicked
    if inputs.mouse.click
			# Check if the click was within a button
      btn = state.buttons.find { |btn| inputs.mouse.click.point.inside_rect?(btn.rect) }
      if btn
				# A button was clicked, so perform left/right click action
        btn.press if inputs.mouse.button_left
        btn.press_alt if inputs.mouse.button_right
      end
    end

		# Check for buttons clicked with mouse middle
    if inputs.mouse.button_middle
      btn = state.buttons.find { |btn| inputs.mouse.point.inside_rect?(btn.rect) }
      btn.press_mid if btn
    end
  end
  
  def render
		# Render FPS
    outputs.labels << [1200, 710, $gtk.current_framerate] if state.verbose
		# Render last pressed button
		outputs.labels << [10, 710, "Last Pressed: #{state.last_pressed} at #{state.last_pressed_at}"]
    # Render buttons
    state.buttons.each do |btn|
      btn.render
    end
  end

	# Construct the grid of buttons
  def init
    state.did_init = true
    state.verbose = true
		state.last_pressed ||= 'None'
		state.last_pressed_at ||= 0
    state.buttons = []
		# Choose the pattern
    formula = case state.pattern
              when :all, nil
                ->(i) { true }
              when :checkers
                ->(i) { ((i%Grid.cols) % 2 == 0 && (i/Grid.cols).floor % 2 == 0) || ((i%Grid.cols)%2==1&&(i/Grid.cols).floor%2==1) }
              when :v_lines
                ->(i) { (i % Grid.cols) % 2 == 0 }
              when :h_lines
                ->(i) { (i / Grid.cols).floor % 2 == 0 }
              when :d_lines
                ->(i) { (((i / Grid.cols).floor - (i % Grid.cols)) % 4 == 0) }
              when :rand
                ->(i) { rand(3) == 1 }
              when :invisible
                ->(i) { true }
              end
		# Create buttons using the pattern
    (6...288).each do |i|
      if formula.call(i)
        btn = Button.new(i % Grid.cols, (i / Grid.cols).floor, 1, 1, *rand_color)
        btn.invisible = true if state.pattern == :invisible
        state.buttons.push(btn)
      end
      i += 1
    end
		# Reset and pattern buttons are independent of the pattern
		add_reset_and_pattern_btns
  end

	def add_reset_and_pattern_btns
    reset_btn = Button.new(0, 0, 3, 1, 200, 20, 20, label: 'RESET')
		# Overload `reset_btn.press` to reconstruct the grid
    reset_btn.define_singleton_method(:press) do
      $gtk.args.state.did_init = false
    end
		args.state.pattern_label ||= 'Checkers'
		puts args.state.pattern_label
		pattern_btn = Button.new(3, 0, 3, 1, 20, 200, 20, label: args.state.pattern_label)
		# Overload `pattern_btn.press` to update the grid pattern
    pattern_btn.define_singleton_method(:press) do
      labels = ['All', 'Checkers', 'V_Lines', 'H_Lines', 'D_Lines', 'Rand', 'Invisible']
      $gtk.args.state.pattern = label.downcase.to_sym
      @label = labels[(labels.index(@label) + 1) % labels.size]
      @update_label = true
      $gtk.args.state.pattern_label = @label
      $gtk.args.state.did_init = false
    end
		args.state.buttons.prepend(reset_btn, pattern_btn)
	end

  def rand_color
    [rand(256), rand(256), rand(256)]
  end

	##
	# To make a POST request:
	# 	$gtk.http_post(String: url, Hash: form_fields, Array: extra_headers)
	# 	Returns a callback (let's call it `response`, so check it each tick until `response[:complete]` is true
	# 	then the response data is in `response[:response_data]`
	def export_state
		args.state.state_upload = $gtk.http_post(URL + 'state', { data: $gtk.serialize_state(args.state).to_s })# ['Content-Type: text/plain'])
	end

	def upload_state
		return if args.state.state_upload.nil?

		if $gtk.args.state.state_upload[:complete]
			if args.state.state_download[:http_response_code] == 200
				puts 'Successfully uploaded state.'
			end
			args.state.state_upload = nil
		end
	end

	##
	# To make a GET request:
	# 	$gtk.http_get(String: url)
	# 	Returns a callback, just like $gtk.http_post. You should handle it in the same way.
	def import_state
		args.state.state_download = $gtk.http_get(URL + 'state')
	end

	def download_state
		return if args.state.state_download.nil?

		if args.state.state_download[:complete]
			if args.state.state_download[:http_response_code] == 200
				pressed = [state.last_pressed, state.last_pressed_at]
				parsed_state = $gtk.deserialize_state(args.state.state_download[:response_data])
				throw StandardError 'Invalid state.' unless parsed_state
				parsed_state.buttons.map! do |btn|
					Button.new(*btn[:args], btn.reject { |k, v| k == :args }) unless [[0,0],[3,0]].include?(btn[:args][0,2])
				end.compact!
				args.state = parsed_state
				add_reset_and_pattern_btns
				$gtk.args.state.last_pressed = pressed[0]
				$gtk.args.state.last_pressed_at = pressed[1]
			end
			args.state.state_download = nil
			args.state.state_upload = nil
		end
	end
end

require 'app/sound.rb'

class SoundBoard
  attr_accessor :inputs, :state, :outputs, :grid, :args

  def initialize
    state.change_pos = true
  end

  def tick
    init
    check_keyboard
    check_mouse
    render
  end

  def check_keyboard
    state.change_pos = false

    if inputs.keyboard.key_down.c
      state.sounds.each do |sound|
        sound.rand_color
      end
    end

    if inputs.keyboard.key_down.up
      state.sounds.push(Sound.new((state.sounds.size + 1).to_s, '', 25))
      state.change_pos = true
    end

    if inputs.keyboard.key_down.down
      state.sounds.pop
      state.change_pos = true
    end
  end

  def check_mouse
    # Check if a button is clicked
    if inputs.mouse.click
      sound = state.sounds.find { |s| inputs.mouse.click.point.inside_rect?(s.rect) }
      sound.play(outputs.sounds, state.tick_count) unless sound.nil?
    end
  end
  
  def render
    # Render buttons
    num_sounds = state.sounds.size
    state.sounds.each_with_index do |sound, i|
      sound.set_pos(i, num_sounds, grid)
      sound.render(outputs, state.tick_count)
    end
    outputs.labels << [1200, 710, $gtk.current_framerate]
  end

  def init
    # Set vars on load
    state.sounds ||= [
      Sound.new('Airhorn', 'sounds/airhorn.wav', 90),
      Sound.new('Hit Marker', 'sounds/hit_marker.wav', 2)
    ]
    while state.sounds.size < 288
      state.sounds.push(Sound.new((state.sounds.size + 1).to_s, '', 25))
    end
  end
end

require 'app/color.rb'

class Button
  attr_reader :col, :row, :size_x, :size_y, :label, :rect
  attr_accessor :color, :invisible

	##
	# All instance variables can be set with Button.new
	# This ensures that a previously serialized button can be
	# reconstructed as a button instance
  def initialize col = 0, row = 0, size_x = 1, size_y = 1, r = 0, g = 0, b = 0, label: nil, label_color: [0,0,0], invisible: false
    @col = col
    @row = row
    @size_x = size_x
    @size_y = size_y
    @color = [r,g,b]
    @label = label.nil? ? "#{col},#{row}" : label
    @label_color = label_color
    @invisible = invisible
    @update_rect = true
    @update_label = !label.nil?
  end
	
	##
	# `serialize`, `to_s`, and `inspect` are required to ensure
	# that buttons can be converted into data that can be written
	# to a file or sent to a server
  def serialize
    { args: [@col, @row, @size_x, @size_y, @color[0], @color[1], @color[2]],
			label: @label, label_color: @label_color, invisible: invisible }
  end

  def to_s
    serialize.to_s
  end
	alias :inspect :to_s # `inspect` is the same function as `to_s`, so we can just alias it

  def press
    # Overload me!
    @color = Color.rand
  end
  alias :left_click :press

  def press_alt
    # Overload me!
    @color = Color.invert(@color)
  end
  alias :right_click :press_alt

  def press_mid
    # Overload me!
    return if @last_invis_toggle && ($gtk.args.state.tick_count - @last_invis_toggle) < 10
    @last_invis_toggle = $gtk.args.state.tick_count
    @invisible = !@invisible
  end
  alias :middle_click :press_mid

  def render
		# Move button position
    if @update_rect
      @update_rect = false
      @update_label = true # Label always has to move to match rect
      @rect = Grid.rect([@col, @row, @size_x, @size_y])
    end

		# Move label position or change label text
    if @update_label
      @update_label = false
      @label_rect = [@rect[0] + @rect[2].half, @rect[1] + @rect[3].half + 10, @label, 0, 1, *@label_color] if @label
    end

		# Don't render if the button is invisible
    return if @invisible

    outputs.solids << [*@rect, *@color]
    outputs.labels << @label_rect if @label_rect
  end

	# Check if button is on a valid grid placement
	def valid?
		Grid.rect([@col, @row, @size_x, @size_y])
		true
	rescue ArgumentError
		false
	end

	# Manually implement setters because `@update_rect` and `@update_label` need to be updated too
  def col= x
    @col = x
    @update_rect = true
  end

  def row= x
    @row = x
    @update_rect = true
  end

  def size_x= x
    @size_x = x
    @update_rect = true
  end

  def size_y= x
    @size_y = x
    @update_rect = true
  end

  def label= str
    @label = str
    @update_label = true
  end

  def label_color= x
    @label_color = x
    @update_label = true
  end

  def rect= x
    @rect = x
    @update_label = true
    @update_rect = false
  end

  def outputs
    $gtk.args.outputs
  end
end

class SoundButton < Button
  attr_reader :path, :title, :color, :rect, :index, :duration

  def initialize label, path, duration, color = nil
    @label = label
    @path = path
    @duration = duration
    color ? @color = color : rand_color
  end

  def press sounds, tick_count
    @playing = true
    @clicked_at = tick_count
    sounds << path
  end

  def stop
    @playing = false
  end

  def render outputs, tick_count
    pos = rect[0..1]
    size = rect[2..3]
    if playing?
      if  tick_count - @clicked_at <= @duration
        outputs.solids << [*pos, *size, *color.map { |e| 255 - e }]
        pos.map! { |e| e + 5 }
        size.map! { |e| e - 10 }
      else
        @playing = false
      end
    end
    outputs.solids << [*pos, *size, *color]
    outputs.labels << [pos[0]+size[0].half, pos[1]+size[1].half+10, title, 0, 1, 0, 0, 0]
  end

  def set_pos i, total, grid
    # Only change position of index or total sounds has changed
    return if @index == i && @total == total
    
    """
    # Ratio of width/height = ratio of cols/rows
    ratio = grid.w / grid.h
    cols = Math.sqrt(ratio * total)
    rows = (cols / ratio).ceil
    cols = cols.round
    # Fix some rounding errors manually because math is hard
    if [2, 8, 18, 32, 45, 65, 66].include?(total)
      rows -= 1
    elsif [16, 61, 62].include?(total)
      rows += 1
    end
    """

    cols = 24
    rows = 12

    # Which col & row is the sound
    col = i % cols
    row = (i / cols).floor

    # Offset from center of screen
    col_width = (cols * @@size[0]) + ((cols - 1) * @@space)
    row_height = (rows * @@size[1]) + ((rows - 1) * @@space)
    x_offset = grid.center_x - col_width.half
    y_offset = grid.center_y - row_height.half

    @index = i
    @total = total
    @rect = [col*(@@size[0] + @@space)+x_offset, row*(@@size[1] + @@space)+y_offset, *@@size]
  end

  def playing?
    @playing
  end

  def rand_color
		puts "rand color"
    @color = [rand(256), rand(256), rand(256)]
  end

  def serialize
    { path: @path, title: @title, color: @color }
  end

  def to_s
    serialize.to_s
  end
  alias :inspect :to_s
end

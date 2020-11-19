class Grid
  class << self
    @@gutter = 4			# Spacing around the edge of the screen 
    @@padding = 4			# Spacing between grid spaces
    @@rows = 12				# Number of valid rows
    @@cols = 24				# Number of valid columns
    @@size = 48				# Size of the side of a 1x1 space
    @@centered = true	# If the grid should be centered on the screen or aligned to the bottom left

    ##
    # obj = [col, row, size_x = 1, size_y = 1 ]
    def rect obj
      throw ArgumentError, "Invalid grid object." unless obj.size >= 2
      col, row, size_x, size_y = obj
      raise ArgumentError, "Invalid grid placement." if (col < 0 || col > @@cols-1 || row < 0 || row > @@rows-1)
      x = col * (@@size + @@gutter) + (@@centered ? x_offset : @@padding)
      y = row * (@@size + @@gutter) + (@@centered ? y_offset : @@padding)
      size_x = size_x.nil? ? 1 : (size_x * @@size) + ((size_x - 1) * @@gutter)
      size_y = size_y.nil? ? 1 : (size_y * @@size) + ((size_y - 1) * @@gutter)
      [x, y, size_x, size_y]
    end

    def cols
      @@cols
    end

    def rows
      @@rows
    end

    def col_width
      @@col_width ||= (@@cols * @@size) + ((@@cols - 1) * @@gutter)
    end

    def row_height
      @@row_height ||= (@@rows * @@size) + ((@@rows - 1) * @@gutter)
    end

    def x_offset
      @@x_offset ||= grid.center_x - col_width.half
    end

    def y_offset
      @@y_offset ||= grid.center_y - row_height.half
    end

    def grid
      $gtk.args.grid
    end

    def outputs
      $gtk.args.outputs
    end
  end
end

class Color
  class << self
    def rand
      [Random.rand(256), Random.rand(256), Random.rand(256)]
    end

    def invert color
      color.map { |e| 255 - e }
    end
  end
end

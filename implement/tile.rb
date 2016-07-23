module Implement

  class Tile
    attr_accessor :tile, :id

    def initialize(t, i)
      @tile = t
      @id = i
    end

    def start_tile?
      @tile[:start] != nil
    end

    def start
      @tile[:start]
    end

    def units
      @tile.fetch(:units, []).map { |u| Unit.new(u, @id) }
    end

    def units=(units)
      @tile[:units] = units.map(&:unit)
    end

    def nutrients
      @tile[:N]
    end

    def minerals
      @tile[:M]
    end

    def city
      @tile[:city].nil? ? nil : City.new(@tile[:city], self)
    end

    def city=(c)
      @tile[:city] = c.city
    end
  end

end

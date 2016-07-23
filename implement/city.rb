module Implement
  class City
    attr_accessor :city, :tile

    def initialize(c, t)
      @city = c
      @tile = t
    end

    def units
      0
    end

    def population
      @city[:population].to_i
    end

    def grow
      return if @city[:population] >= 10
      @city[:population] += (nutrients.to_f / 50.0)
    end

    def civilians
      population - units
    end

    def player_id
      @city[:player_id]
    end

    def nutrients
      @tile.nutrients
    end

    def minerals
      @city[:minerals]
    end

    def minerals=(m)
      @city[:minerals] = m
    end

    def culture
      @city[:culture].to_i
    end

    def grow_culture
      return if is_legendary?
      years_in_turn = get_years_in_next_turn()
      @city[:culture] += (civilians * years_in_turn / 20.0)
    end

    def production_target=(p)
      @city[:production_target] = p
    end

    def production_target
      return nil if @city[:production_target].nil?
      Unit.new(@city[:production_target], @tile.id)
    end

    def is_legendary?
      @city[:culture] >= 20_000
    end
  end
end


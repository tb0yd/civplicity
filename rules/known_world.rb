require 'pp'

class KnownWorld
  def initialize(player)
    @player = player

    compute
  end

  def is_visible?(tile_id)
    tile_id = tile_id.to_s.chars
    tile_id = [tile_id[0], tile_id[1..-1].join("")]

    surrounding_tiles = (tile_id[0].ord-1..tile_id[0].ord+1).map(&:chr).product(
      (tile_id[1].to_i-1..tile_id[1].to_i+1).map(&:to_s)).map(&:join).map(&:to_sym)

    surrounding_tiles.any? do |id|
      @units[id] || @cities[id]
    end
  end

  def visible_city(city)
    size = case
           when city.population >= 7
             :large
           when city.population <= 7 && city.population >= 3
             :medium
           else
             :small
           end

    {name: city.name, player_id: city.player_id, size: size}
  end

  def compute
    @units, @cities, @visible_units, @visible_cities = {}, {}, {}, {}

    for_each_tile_in_world do |tile|
      my_units_in_tile = tile.units.select { |u| u.player == @player }
      @units[tile.id] = my_units_in_tile.map(&:unit)

      if tile.city && tile.city.player_id == @player
        @cities[tile.id] = tile.city.city
      end
    end

    for_each_tile_in_world do |tile|
      if is_visible?(tile.id)
        other_units_in_tile = tile.units.select { |u| u.player != @player }

        @visible_units[tile.id] = other_units_in_tile.map(&:unit)

        if tile.city && tile.city.player_id != @player
          @visible_cities[tile.id] = visible_city(tile.city)
        end
      end
    end
  end

  def units_on_tile(tile_id)
    @units.fetch(tile_id, []) + @visible_units.fetch(tile_id, [])
  end

  def city_on_tile(tile_id)
    @cities.fetch(tile_id, nil) || @visible_cities.fetch(tile_id, nil)
  end

  def to_s
    hash = {}

    for_each_tile_in_world do |tile|
      if is_visible?(tile.id)
        hash[tile.id] = tile.tile.clone
        hash[tile.id][:units] = units_on_tile(tile.id).map(&:clone)
        hash[tile.id][:city] = city_on_tile(tile.id).clone if city_on_tile(tile.id)
      end
    end

    str = ""
    PP.singleline_pp hash, str
    str
  end
end

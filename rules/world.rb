module World
  def movement_actions_for_unit(unit)
    possible_moves_for_unit(unit).map do |tile_id|
      Action.new(Action::MOVE_UNIT, unit: unit, to_tile_id: tile_id)
    end
  end

  def possible_moves_for_unit(unit)
    tiles_surrounding_tile_id(unit.tile).select do |tile_id|
      tile = get_tile(tile_id)

      tile.is_land? &&
        (!tile.city || tile.city.player_id != unit.player_id) && 
        tile_id != unit.tile
    end
  end

  def tiles_surrounding_tile_id(tile_id)
    last_row = ""
    for_each_tile_in_world do |tile|
      last_row = tile.id.to_s[0] if tile.id.to_s[0] != last_row
    end

    last_col = 1
    for_each_tile_in_world do |tile|
      last_col = tile.id.to_s[1..-1].to_i if tile.id.to_s[1..-1].to_i != last_col
    end

    tiles = (tile_id[0].ord-1..tile_id[0].ord+1).map(&:chr).product(
        (tile_id[1..-1].to_i-1..tile_id[1..-1].to_i+1).map(&:to_s)).map(&:join).map(&:to_sym)

    tiles = tiles.select { |tile| tile.to_s[0].ord > "A".ord-1 }
    tiles = tiles.select { |tile| tile.to_s[0].ord < last_row.ord+1 }
    tiles = tiles.map { |tile| tile.to_s[1..-1].to_i < 1 ? :"#{tile.to_s[0]}#{last_col}" : tile }
    tiles = tiles.map { |tile| tile.to_s[1..-1].to_i > last_col ? :"#{tile.to_s[0]}1" : tile }
    tiles
  end
end

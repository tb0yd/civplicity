module Implement
  def get_current_player
    Player.new($players[$turn], $turn)
  end

  def get_player(id)
    Player.new($players[id], id)
  end

  def get_years_in_next_turn
    100
  end

  def for_each_tile_in_world
    $world.each do |id, tile|
      yield Tile.new(tile, id)
    end
  end

  def for_each_player
    $players.each.with_index do |player, idx|
      yield Player.new(player, idx), idx
    end
  end

  def get_targeted_tech(player)
    player.tech_target
  end

  def get_research_center_city(player)
    cities = []
    for_each_tile_in_world do |tile|
      if tile.city && tile.city.player_id == player.id
        cities << tile.city
      end
    end

    cities.sort_by(&:population).last
  end

  def save_player(player, idx=$turn)
    $players[idx] = player.player
  end

  def save_tile(tile)
    $world[tile.id] = tile.tile
    $world[tile.id][:units] = tile.units.map(&:unit)
  end

  def save_city(city)
    $world[city.tile.id][:city] = city.city

    production_target = city.production_target ? city.production_target : nil
    production_target = production_target.respond_to?(:unit) ? production_target.unit : production_target
    $world[city.tile.id][:city][:production_target] = production_target if production_target
  end

  def end_turn
    for_each_tile_in_world do |tile|
      if city = tile.city
        city.grow
        save_city(city)
      end
    end

    $turn += 1

    if $turn >= $players.size
      $turns += 1
      curve = -> (y) { y ** (1.3) }
      yit = -> (y) { [50, [1, (50 - curve[((y + 4000)/6000.0)]*50+1).to_i].max].min }

      $year += yit[$year]
      $turn = 0
    end
  end

  def starting_techs
    $techs.keys - $techs.values.map { |t| t[:unlocks].map(&:to_sym) }.flatten
  end

  def select_units_in_tile(tile_id, player)
    tile = Tile.new($world[tile_id], tile_id)
    tile.units.select { |u| u.player == player }.map { |u| Unit.new(u, tile_id) }
  end

  def get_city_in_tile(tile_id, player_id)
    tile = Tile.new($world[tile_id], tile_id)

    if tile.city && (tile.city.player_id == player_id)
      tile.city
    else
      nil
    end
  end

  def get_opponent_units(tile_id)
    tile = Tile.new($world[tile_id], tile_id)
    tile.units.select { |u| u.player != $turn }
  end

  def is_conscripted_type?(unit)
    $units[unit.type][:prerequisites].include?(:Conscription)
  end

  def players_are_at_peace?(p1, p2)
    $players[p1][:relations] ||= {}
    $players[p1][:relations][p2] == :Peace
  end

  def destroy_unit(unit)
    new_units = []
    destroyed = false
    $world[unit.tile][:units].each do |u|
      u = Unit.new(u, unit.tile)
      if unit.rank == u.rank && unit.type == u.type && destroyed == false
        destroyed = true
        next
      end

      new_units << u.unit
    end

    $world[unit.tile][:units] = new_units
  end

  def save_unit(unit)
    if unit.new_tile_id
      $world[unit.new_tile_id][:units] += [unit.unit]
    end
  end

  def get_tile(tile)
    Tile.new($world[tile], tile)
  end

  def flag_unit_for_promotion(unit)
    unit.flagged_for_promotion = true
  end

  def create_proposition(prop)
    $players[prop.player_id][:propositions] += [prop.proposition]
  end

  def destroy_proposition(prop_to_destroy)
    all_props = Player.new($players[prop_to_destroy.player_id], prop_to_destroy.player_id).propositions.map(&:proposition)
    player_id = prop_to_destroy.player_id
    prop_to_destroy = prop_to_destroy.proposition

    new_props = all_props.select { |p|
      p[:type] != prop_to_destroy[:type] && p[:to] != prop_to_destroy[:to]
    }

    $players[player_id][:propositions] = new_props
  end

  def save_proposition(prop)
    player_id = prop.player_id
    $players[player_id][:propositions] += [prop.proposition]
  end

  def create_city(unit)
    if unit.type != :Settler
      return false
    end

    if get_city_in_tile(unit.tile, get_current_player.id)
      return false
    end

    destroy_unit(unit)
    $world[unit.tile][:city] = City.new({
      name: "MyCity#{unit.tile}",
      player_id: unit.player,
      population: 1.0,
      minerals: 0,
      culture: 0
    }, unit.tile).city
  end

  def propose_peace(to_player)
    from_player = get_current_player
    create_proposition(Proposition.new({to: to_player, type: "Peace"}, from_player.id))
  end

  def accept_peace(from_player)
    to_player = get_current_player
    to_player.propositions = to_player.propositions.select { |p| p.from != from_player || p.type != "Peace" }.map(&:proposition)
    to_player.relations = to_player.relations.merge(from_player => "Peace")
    save_player(to_player, to_player.id)

    from_player = get_player(from_player)
    from_player.relations = from_player.relations.merge(to_player.id => "Peace")
    save_player(from_player, from_player.id)
  end

  def pop_unit_from_queue(city)
    {type: :Archer, player: city.player_id}
  end

end

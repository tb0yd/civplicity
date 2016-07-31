def test(rules: :pick)
  test = test_game rules: :combat_only, name: :shots_fired
  test.instance_eval do
    init
    archer = select_units_in_tile(:A1, 0)[0]
    move_unit_to_tile(archer, :B1)
    turn
    print
  end

  test = test_game rules: :research_only, name: :farming
  test.instance_eval do
    init
    for_each_tile_in_world do |tile|
      if tile.id == :A1
        tile.units += [Unit.new({type: :Settler, player: tile.start}, tile.id)]
      end
    end
    settler = select_units_in_tile(:A1, 0)[0]
    create_city(settler)
    player = get_current_player
    player.tech_target = :Farming
    20.times { turn }
    print
  end

  test = test_game rules: :diplomacy_only, name: :peace_treaty
  test.instance_eval do
    init
    propose_peace(1)
    turn
    accept_peace(0)
    turn
    print
  end

  test = test_game rules: :production_only, name: :produce_archer
  test.instance_eval do
    init
    settler = select_units_in_tile(:A1, 0)[0]
    create_city(settler)
    city = get_city_in_tile(:A1, 0)
    city.production_target = Unit.new({type: :Archer, player: 0}, city.tile)
    10.times { turn }
    print
  end

  test = test_game rules: :culture_only, name: :legendary_city
  test.instance_eval do
    init

    tile = get_tile(:A1)
    tile.units += [Unit.new({type: :Settler, player: tile.start}, tile.id)]
    save_tile(tile)

    settler = select_units_in_tile(:A1, 0)[0]
    create_city(settler)
    city = get_city_in_tile(:A1, 0)

    while !city.is_legendary?
      turn
      city = get_city_in_tile(:A1, 0)
    end
    print
  end

  test = test_game rules: :all, name: :shots_fired
  test.instance_eval do
    init
    archer = select_units_in_tile(:A1, 0)[0]
    move_unit_to_tile(archer, :B1)
    turn
    print
  end

  test = test_game rules: :all, name: :farming
  test.instance_eval do
    init
    for_each_tile_in_world do |tile|
      if tile.id == :A1
        tile.units += [Unit.new({type: :Settler, player: tile.start}, tile.id)]
      end
    end
    settler = select_units_in_tile(:A1, 0)[1]
    create_city(settler)
    player = get_current_player
    player.tech_target = :Farming
    20.times { turn }
    print
  end

  test = test_game rules: :all, name: :peace_treaty
  test.instance_eval do
    init
    propose_peace(1)
    turn
    accept_peace(0)
    turn
    print
  end

  test = test_game rules: :all, name: :produce_archer
  test.instance_eval do
    init
    settler = select_units_in_tile(:A1, 0)[1]
    create_city(settler)
    city = get_city_in_tile(:A1, 0)
    city.production_target = Unit.new({type: :Archer, player: 0}, city.tile)
    10.times { turn }
    print
  end

  test = test_game rules: :all, name: :legendary_city
  test.instance_eval do
    init

    tile = get_tile(:A1)
    tile.units += [Unit.new({type: :Settler, player: tile.start}, tile.id)]
    save_tile(tile)

    settler = select_units_in_tile(:A1, 0)[1]
    create_city(settler)
    city = get_city_in_tile(:A1, 0)

    while !city.is_legendary?
      turn
      city = get_city_in_tile(:A1, 0)
    end
    print
  end

  test = test_game rules: :all, name: :enemy_city
  test.instance_eval do
    init

    tile = get_tile(:B1)
    tile.units += [Unit.new({type: :Settler, player: tile.start}, tile.id)]
    save_tile(tile)

    turn

    settler = select_units_in_tile(:B1, 1)[1]
    create_city(settler)

    turn

    print
  end

  test = test_game rules: :combat_only, name: :conquest_victory
  test.instance_eval do
    init
    archer = select_units_in_tile(:A1, 0)[0]
    while test_for_victory == nil
      move_unit_to_tile(archer, :B1)
      turn
      turn
    end
    print
  end

  test = test_game rules: :research_only, name: :space_race_victory
  test.instance_eval do
    init
    for_each_tile_in_world do |tile|
      if tile.id == :A1
        tile.units += [Unit.new({type: :Settler, player: tile.start}, tile.id)]
      elsif tile.id == :B1
        tile.units += [Unit.new({type: :Archer, player: tile.start}, tile.id)]
      end
    end
    settler = select_units_in_tile(:A1, 0)[0]
    create_city(settler)
    while test_for_victory == nil
      turn
    end
    print
  end
end

def test_game(world: :simplest, rules: :all, name: :blank)
  puts "test_#{world}_world_#{rules}_#{name}".yellow

  test_class = Class.new do
    include Civplicity

    if rules == :all
      include Combat
      include Diplomacy
      include Research
      include Production
      include Culture
    elsif rules == :combat_only
      include Combat
    elsif rules == :diplomacy_only
      include Diplomacy
    elsif rules == :research_only
      include Research
    elsif rules == :culture_only
      include Culture
    elsif rules == :production_only
      include Production
    end

    def init
      self.send(:init_game)
      self.send(:init_game_for_combat)
      self.send(:init_game_for_culture)
      self.send(:init_game_for_production)
      self.send(:init_game_for_research)
      self.send(:init_game_for_diplomacy)
    end

    def turn
      self.send(:end_turn_for_combat)
      self.send(:end_turn_for_culture)
      self.send(:end_turn_for_production)
      self.send(:end_turn_for_research)
      self.send(:end_turn_for_diplomacy)
      self.send(:end_turn)
    end

    def print
      str = "World:      "
      PP.singleline_pp $world, str
      puts str.cyan
      str = "KnownWorld: "
      str += KnownWorld.new(0).to_s
      puts str.cyan
      str = "Players:    "
      PP.singleline_pp $players, str
      puts str.cyan
      str = "Year:       #{$year}"
      puts str.green
      str = "Turn:       #{$turns}"
      puts str.green
    end
  end

  test_class.new
end

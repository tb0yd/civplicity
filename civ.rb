require 'colorize'
require 'rubygems'
require 'byebug'
require 'pp'

class Array
  alias sample_without_log sample

  def sample
    res = sample_without_log()
    puts "sample: #{res}"
    res
  end
end

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

  class Player
    attr_accessor :player, :id

    def initialize(player, id)
      @player = player.respond_to?(:player) ? player.player : player
      @id = id
    end

    def research
      @player[:research]
    end

    def research=(r)
      @player[:research] = r
    end

    def tech_target
      Tech.new($techs[@player[:tech_target].to_sym], @player[:tech_target].to_sym)
    end

    def tech_target=(t)
      @player[:tech_target] = t
    end

    def government=(g)
      @player[:government] = g
    end

    def techs
      @player[:techs]
    end

    def techs=(t)
      @player[:techs] = t
    end

    def propositions
      @player[:propositions].map { |p| Proposition.new(p, @id) }
    end

    def propositions=(p)
      @player[:propositions] = p.map(&:proposition)
    end

    def relations
      @player[:relations]
    end

    def relations=(r)
      @player[:relations] = r
    end
  end

  class Proposition
    attr_writer :proposition
    attr_accessor :player_id

    def proposition
      prop = @proposition.clone
      prop.delete(:player)
      prop
    end

    def initialize(p, i)
      @proposition = p.respond_to?(:proposition) ? p.proposition : p
      @player_id = i
    end

    def player
      @proposition[:player]
    end

    def from
      @proposition[:from]
    end

    def from=(f)
      @proposition[:from] = f
    end

    def to
      @proposition[:to]
    end

    def to_player_id
      @proposition[:to]
    end

    def to=(t)
      @proposition.delete(:to) and return if t.nil?
      @proposition[:to] = t
    end

    def player
      @proposition[:player]
    end

    def player=(p)
      @proposition[:player] = p
    end

    def type
      @proposition[:type]
    end
  end

  class Tech
    attr_accessor :tech, :name

    def initialize(t, n)
      @tech = t
      @name = n
    end

    def research
      @tech[:research]
    end
  end

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

  class Unit
    attr_accessor :unit, :tile, :moves, :new_tile_id, :minerals_needed

    def initialize(u, t)
      @unit = u.respond_to?(:unit) ? u.unit : u
      @tile = t
      @moves = $units[@unit[:type]][:moves]
    end

    def player
      @unit[:player]
    end

    def type
      @unit[:type]
    end

    def rank
      @unit[:rank]
    end

    def rank=(r)
      @unit[:rank] = r
    end

    def tile_id=(id)
      @new_tile_id=id
    end

    def flagged_for_promotion
      @unit[:flagged_for_promotion]
    end

    def minerals_needed
      @unit[:minerals_needed].nil? ? $units[type][:resources] : @unit[:minerals_needed]
    end

    def flagged_for_promotion=(f)
      if f
        @unit[:flagged_for_promotion] = f
      else
        @unit.delete(:flagged_for_promotion)
      end
    end
  end
end


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
      str = "World:   "
      PP.singleline_pp $world, str
      puts str.cyan
      str = "Players: "
      PP.singleline_pp $players, str
      puts str.cyan
      str = "Year:     #{$year}"
      puts str.green
      str = "Turn:     #{$turns}"
      puts str.green
    end
  end

  test_class.new
end

module Civplicity
  def init_game_for_combat
  end

  def init_game_for_culture
  end

  def init_game_for_diplomacy
  end

  def init_game_for_production
  end

  def init_game_for_research
  end

  def init_game
    $world = {
      A1: {N: 8, M: 6, start: 0},
      B1: {N: 6, M: 8, start: 1}
    }

    $turn = 0
    $turns = 0

    $year = -4000

    $UN = []

    $techs = {
      Money: {unlocks: ["Monarchy"], research: 500},
      Wheel: {unlocks: ["Combustion"], research: 500},
      Farming: {unlocks: ["Combustion"], research: 700},
      Ironworking: {unlocks: ["Steel"], research: 500},
      Chemistry: {unlocks: ["Medicine"], research: 500},
      Astronomy: {unlocks: ["Calculus"], research: 500},
      Monarchy: {unlocks: ["Conscription"], research: 500},
      Combustion: {unlocks: ["Atomic Theory", "Spaceship"], research: 500},
      Steel: {unlocks: ["Atomic Theory", "Spaceship"], research: 500},
      Medicine: {unlocks: ["Spaceship"], research: 500},
      Calculus: {unlocks: ["Atomic Theory", "Spaceship"], research: 500},
      Conscription: {unlocks: ["Atomic Theory"], research: 500},
      Spaceship: {unlocks: [], research: 500},
      :"Atomic Theory" => {unlocks: [], research: 500}
    }

    $units = {
      Archer: {prerequisites: [], moves: 1, resources: 25},
      Settler: {prerequisites: [], moves: 1},
      Swordsman: {prerequisites: ["Ironworking"], moves: 1},
      Boat: {prerequisites: ["Astronomy"], moves: 3},
      Chariot: {prerequisites: ["Wheel", "Farming"], moves: 2},
      Infantry: {prerequisites: ["Conscription"], moves: 1},
      Cavalry: {prerequisites: ["Conscription", "Farming"], moves: 2},
      Battleship: {prerequisites: ["Conscription", "Steel", "Astronomy"], moves: 5},
      Tank: {prerequisites: ["Conscription", "Steel", "Combustion"], moves: 2},
      Nuke: {prerequisites: ["Atomic Theory"], moves: 0},
    }

    $players = [
      {
        name: "Foo",
        techs: [],
        research: 0,
        money: 0
      },
      {
        name: "Fee",
        techs: [],
        research: 0,
        money: 0
      }
    ]
  end

  def end_turn_for_combat
  end

  def move_unit_to_tile_for_combat(unit, tile)
  end

  def end_turn_for_production
  end

  def end_turn_for_research
  end

  def end_turn_for_culture
  end

  def end_turn_for_diplomacy
  end

  def turn
    end_turn_for_combat
    end_turn_for_culture
    end_turn_for_production
    end_turn_for_research
    end_turn_for_diplomacy
    end_turn
  end

  def move_unit_to_tile(unit, tile_id)
    unit.moves -= 1

    if move_unit_to_tile_for_combat(unit, tile_id) == :return
      return
    end

    unit.tile_id = tile_id
    save_unit(unit)
  end
end

module Combat
  def end_turn_for_combat
    for_each_tile_in_world do |tile|
      tile.units.each do |unit|
        if unit.flagged_for_promotion
          unit.rank = :Veteran
          unit.flagged_for_promotion = false
          save_unit(unit)
        end
      end
    end
  end

  def move_unit_to_tile_for_combat(unit, tile_id)
    if opponents = get_opponent_units(tile_id)
      opponent = choose_opponent_fairly(unit, opponents)
      outcome = challenge_opponent(unit, opponent)

      if outcome == :win
        destroy_unit(opponent)
        flag_unit_for_promotion(unit)

        if get_opponent_units(tile_id)
          return :return
        end
      elsif outcome == :lose
        destroy_unit(unit)
        return :return
      else
        return :return
      end
    end
  end

  def init_game_for_combat
    for_each_tile_in_world do |tile|
      if tile.start_tile?
        tile.units += [Unit.new({type: :Archer, player: tile.start}, tile)]
        save_tile(tile)
      end
    end
  end

  def quality_of_defense(unit, opponent)
    return 0 if opponent.nil?

    q = 0
    q += 1 if opponent.type != :Settler
    q += 1 unless is_unlosable_challenge?(unit, opponent)

    q
  end

  def choose_opponent_fairly(unit, opponents)
    sorted = opponents.sort_by do |o1, o2|
      quality_of_defense(unit, o1) <=> quality_of_defense(unit, o2)
    end

    sorted.first
  end

  def is_unlosable_challenge?(unit, opponent)
    (unit.type == :Tank && opponent.tile.has_city?) ||
      (unit.rank == :Veteran && opponent.rank != :Veteran) ||
      (is_conscripted_type?(unit) && !is_conscripted_type?(opponent)) ||
      (players_are_at_peace?(unit.player, opponent.player))
  end

  def challenge_opponent(unit, opponent)
    if is_unlosable_challenge?(unit, opponent)
      [:win, :draw].sample
    else
      [:win, :lose, :draw].sample
    end
  end
end

module Production
  def end_turn_for_production
    for_each_tile_in_world do |tile|
      if city = tile.city
        if unit = city.production_target
          if unit.minerals_needed < city.minerals
            city.minerals -= unit.minerals_needed
            unit.new_tile_id = tile.id
            city.production_target = pop_unit_from_queue(city)
            save_unit(unit)
          end

          city.minerals += tile.minerals

          save_city(city)
        end
      end
    end
  end

  def init_game_for_production
    for_each_tile_in_world do |tile|
      if tile.start_tile?
        tile.units += [Unit.new({type: :Settler, player: tile.start}, tile)]
        save_tile(tile)
      end
    end
  end
end

module Research
  def end_turn_for_research
    player = get_current_player()
    tech_target = get_targeted_tech(player)

    research_city = get_research_center_city(player)

    return if research_city.nil?

    player.research += research_city.civilians

    if tech_target.research <= player.research
      player.techs += [tech_target.name]
      player.research -= tech_target.research
    end

    save_player(player, player.id)
  end

  def init_game_for_research
    for_each_player do |player, idx|
      player.tech_target = starting_techs.sample
      save_player(player, idx)
    end
  end
end

module Culture
  def end_turn_for_culture

    for_each_tile_in_world do |tile|
      if city = tile.city
        city.grow_culture
        save_city(city)
      end
    end
  end

  def init_game_for_culture

  end
end

module Diplomacy
  def end_turn_for_diplomacy
    player = get_current_player
    player.propositions.each do |prop|
      destroy_proposition(prop) and return if prop.to.nil?

      sent_prop = Proposition.new(prop.proposition, prop.to_player_id)
      sent_prop.from = player.id
      sent_prop.to = nil

      destroy_proposition(prop)
      save_proposition(sent_prop)
    end
  end

  def init_game_for_diplomacy
    for_each_player do |player, idx|
      player.government = :Anarchy
      player.propositions = []
      player.relations = {}
      save_player(player, idx)
    end
  end
end

include Implement
test




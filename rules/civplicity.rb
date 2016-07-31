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

  def test_for_victory
    conquest = nil
    research = nil

    # test for conquest
    players_vanquished = {}
    for_each_player do |player|
      players_vanquished[player.id] = true
    end

    for_each_tile_in_world do |tile|
      unless tile.units.empty?
        tile.units.each do |unit|
          players_vanquished[unit.player] = false
        end
      end

      players_vanquished[tile.city.player_id] = false if tile.city
    end

    if players_vanquished.select { |k,v| v == false }.keys.size < 2
      conquest = players_vanquished.select { |k,v| v == false }.keys[0]
    end

    # test for space race
    for_each_player do |player|
      if player.techs.include?(:Spaceship)
        research = player.id
      end
    end

    if conquest
      return {conquest: conquest}
    elsif research
      return {research: research}
    end

    nil
  end
end



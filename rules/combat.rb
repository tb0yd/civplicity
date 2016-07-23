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


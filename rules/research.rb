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


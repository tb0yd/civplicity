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
      player.tech_target = choose_next_tech_target(player)
    end

    save_player(player, player.id)
  end

  def init_game_for_research
    for_each_player do |player, idx|
      player.tech_target = starting_techs.sample
      save_player(player, idx)
    end
  end

  def get_possible_techs(player)
    techs = []

    for_each_tech do |tech|
      if player.has_tech?(tech)
        next
      end

      if (tech.get_dependencies.map(&:name) - player.techs).empty?
        techs += [tech]
      end
    end

    techs
  end

  def choose_next_tech_target(player)
    target = player.tech_goal
    possible_techs = get_possible_techs(player)

    next_tech = nil
    possible_techs.each do |tech|
      if tech.name == target.name
        next_tech = tech
        break
      end

      if tech.is_dependency_for?(target)
        next_tech = tech
        break
      end
    end

    if next_tech
      next_tech.name
    else
      # you've won
      :Spaceship
    end
  end
end


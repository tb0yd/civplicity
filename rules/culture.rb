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

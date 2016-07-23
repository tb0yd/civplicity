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


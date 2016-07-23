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


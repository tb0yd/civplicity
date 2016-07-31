module Implement

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

    def tech_goal
      if @player[:tech_goal]
        Tech.new($techs[@player[:tech_goal].to_sym], @player[:tech_goal].to_sym)
      else
        get_tech(:Spaceship)
      end
    end

    def tech_goal=(t)
      @player[:tech_goal] = t
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

    def has_tech?(tech)
      @player[:techs].include?(tech.name)
    end
  end

end

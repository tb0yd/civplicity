
module Implement
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

end

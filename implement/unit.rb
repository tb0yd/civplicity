module Implement

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

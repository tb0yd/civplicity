class Action
  END_TURN = 0
  MOVE_UNIT = 1

  attr_accessor :key, :payload

  def initialize(key, payload={})
    @key, @payload = key, payload
  end

  def to_s
    if key == END_TURN
      "[End Turn]"
    elsif key == MOVE_UNIT
      unit = payload[:unit]
      to_tile_id = payload[:to_tile_id]
      tile_id = unit.tile
      "[#{unit.type}: Move from #{tile_id} to #{to_tile_id}]"
    end
  end
end


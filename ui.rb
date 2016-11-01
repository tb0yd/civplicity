require 'colorize'
require 'curses'

require './boot.rb'

include Curses
include Implement
include Civplicity
include Combat
include World

init_screen

def one_tile_up_for_unit(unit)
  tile_id = unit.tile
  nextchr = (tile_id.to_s[0].ord-1).chr
  :"#{nextchr}#{tile_id[1]}"
end

def tile_id_from_coords(xy)
  :"#{%w(A B C D E F G H I J K L)[xy[0]]}#{xy[1]+1}"
end

def tile_id_to_coords(tile_id)
  [tile_id.to_s[0].ord-65, tile_id[1..-1].to_s.to_i-1]
end

def world_tiles
  world = {}

  12.times do |x|
    12.times do |y|
      tile = [
        {N: 6, M: 4, type: :land},
        {N: 0, M: 0, type: :water}
      ].sample

      tile_id = tile_id_from_coords([x,y])
      world[tile_id] = tile
    end
  end

  start_0 = world.to_a.select { |id, tile| tile[:type] == :land && tile[:start].nil? }.sample[0]
  world[start_0][:start] = 0
  start_1 = world.to_a.select { |id, tile| tile[:type] == :land && tile[:start].nil? }.sample[0]
  world[start_1][:start] = 1

  world
end

def world_tile_display(tile)
  if tile.units.size > 1
    disp = {text: "%%%"}
    disp[:color] = tile.units.first.player == 0 ? COLOR_RED : COLOR_MAGENTA
    disp
  elsif tile.units.size > 0
    unit = tile.units.first
    disp = {text: unit.type == :Archer ? "o->" : "-o-"}
    disp[:color] = tile.units.first.player == 0 ? COLOR_RED : COLOR_MAGENTA
    disp
  elsif tile.is_land?
    {color: COLOR_GREEN, text: 'XXX'}
  else
    {color: COLOR_BLUE, text: '~~~'}
  end
end

def cursor_color(player)
  player == 0 ? COLOR_RED : COLOR_MAGENTA
end

begin
  crmode
  curs_set(0)
  cursor_pos = [0,0]
  key = nil
  selection = nil
  $world = world_tiles
  stdscr.keypad = true
  player = 0
  actions = [Action.new(Action::END_TURN)]

  start_color

  init_game(world: :custom)
  init_game_for_combat

  for_each_tile_in_world do |tile|
    unless tile.start.nil?
      tile.units += [Unit.new({type: :Settler, player: tile.start}, tile.id)]
    end
  end

  init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK)
  init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
  init_pair(COLOR_YELLOW,COLOR_YELLOW,COLOR_BLACK)
  init_pair(COLOR_WHITE,COLOR_WHITE,COLOR_BLACK)
  init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)
  init_pair(COLOR_MAGENTA,COLOR_MAGENTA,COLOR_BLACK)

  while true
    case key
    when KEY_LEFT
      cursor_pos[1] = (cursor_pos[1] - 1) % 12
    when KEY_RIGHT
      cursor_pos[1] = (cursor_pos[1] + 1) % 12
    when KEY_UP
      cursor_pos[0] = (cursor_pos[0] - 1) % 12
    when KEY_DOWN
      cursor_pos[0] = (cursor_pos[0] + 1) % 12
    when 9 # tab
      if cursor_pos[0] == :action && cursor_pos[1] == actions.size-1
        cursor_pos = [0, 0]
      elsif cursor_pos[0] == :action
        cursor_pos = [:action, cursor_pos[1]+1]
      else
        cursor_pos = [:action, 0]
      end
    when 10 # enter
      if cursor_pos[0] == :action
        if actions[cursor_pos[1]].key == Action::END_TURN
          end_turn
        elsif actions[cursor_pos[1]].key == Action::MOVE_UNIT
          unit = actions[cursor_pos[1]].payload[:unit]
          move_unit_to_tile(unit, actions[cursor_pos[1]].payload[:to_tile_id])
          cursor_pos = [0,0]
          selection = nil
        end
      elsif select_units_in_tile(tile_id_from_coords(cursor_pos), player).size > 0
        selection = cursor_pos.clone
      end
    when "q"
      break
    end

    clear

    player = get_current_player.id
    actions = [Action.new(Action::END_TURN)]

    setpos(20,0)
    addstr(key.inspect)

    setpos(1, 1)
    addstr("Map:")

    setpos(10,40)
    addstr("Year: #{get_year.to_s}")

    for_each_tile_in_world do |tile|
      xy = tile_id_to_coords(tile.id)
      obj = world_tile_display(tile)

      if cursor_pos == xy
        setpos(3 + xy[0], 1 + xy[1]*3)
        color = tile.units.size > 0 ? COLOR_WHITE : cursor_color(player)
        attron(color_pair(color) | A_NORMAL) do
          addstr(obj[:text])
        end

        setpos(21,0)
        addstr(tile.inspect)

      elsif selection == xy
        setpos(3 + xy[0], 1 + xy[1]*3)
        color = tile.units.size > 0 ? COLOR_WHITE : cursor_color(player)
        attron(color_pair(color) | A_NORMAL) do
          addstr(obj[:text])
        end

        setpos(22,0)
        addstr("Selected: #{tile.units.first.inspect}")

      else
        setpos(3 + xy[0], 1 + xy[1]*3)
        color = obj[:color]
        attron(color_pair(color) | A_NORMAL) do
          addstr(obj[:text])
        end
      end
    end

    if selection
      units = select_units_in_tile(tile_id_from_coords(selection), player)
      units.each do |unit|
        if unit.has_move?
          actions += movement_actions_for_unit(unit)
        end
      end
    end

    setpos(1,40)
    addstr("Actions:")

    actions.each.with_index do |action, idx|
      setpos(3+idx,40)

      if cursor_pos[0] == :action && cursor_pos[1] == idx
        color = cursor_color(player)
        attron(color_pair(color) | A_NORMAL) do
          addstr(action.to_s)
        end

      else
        addstr(action.to_s)
      end
    end

    key = getch
  end
ensure
  close_screen
end

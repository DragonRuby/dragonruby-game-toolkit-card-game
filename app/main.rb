def ui args
  #Deck information
  args.state.deck_x ||= 20
  args.state.deck_y ||= 40
  deck = [ args.state.deck_x, args.state.deck_y, 64, 128, 'sprites/hexagon-indigo.png' ]
  args.outputs.sprites << deck

  args.state.deck_count ||= 30
  args.state.deck_label_alpha ||= 0
  args.state.deck_count_x = args.state.deck_x
  args.state.deck_count_y = args.state.deck_y + 150
  deck_label = [ args.state.deck_count_x, args.state.deck_count_y, "Cards in Deck: #{args.state.deck_count}", 0, 0, 0, args.state.deck_label_alpha ]
  args.outputs.labels << deck_label

  if args.inputs.mouse.point.inside_rect? deck
    args.state.deck_label_alpha = 255
  end
  if !args.inputs.mouse.point.inside_rect? deck
    args.state.deck_label_alpha = 0
  end


  #Discard information
  args.state.discard_x ||= 1150
  args.state.discard_y ||= 40
  discard = [ args.state.discard_x, args.state.discard_y, 64, 128, 'sprites/hexagon-black.png' ]
  args.outputs.sprites << discard

  args.state.discard_count ||= 0
  args.state.discard_label_alpha ||= 0
  args.state.discard_count_x = args.state.discard_x
  args.state.discard_count_y = args.state.discard_y + 150
  discard_label = [ args.state.discard_count_x, args.state.discard_count_y, "Discarded: #{args.state.discard_count}", 0, 0, 0, args.state.discard_label_alpha ]
  args.outputs.labels << discard_label

  if args.inputs.mouse.point.inside_rect? discard
    args.state.discard_label_alpha = 255
  end
  if !args.inputs.mouse.point.inside_rect? discard
    args.state.discard_label_alpha = 0
  end


  #Energy information (resource is a WIP name)
  args.state.resource ||= 3
  args.outputs.labels << [ 25, 650, "Energy: #{args.state.resource}" ]

  #Player information
  args.state.player_x ||= 250
  args.state.player_y ||= 400
  player = [ args.state.player_x, args.state.player_y, 100, 100,  'sprites/dragon-0.png' ]
  args.outputs.sprites << player

  args.state.player_health ||= 100
  args.state.player_health_x ||= args.state.player_x
  args.state.player_health_y ||= args.state.player_y + 150
  args.outputs.labels << [ args.state.player_health_x, args.state.player_health_y, "Your Health: #{args.state.player_health}" ]

  #Cards information
  red_x ||= 300
  red_y ||= 100
  green_x ||= 600
  green_y ||= 100
  red_card   = [ red_x,     red_y,     64, 128, 'sprites/hexagon-red.png' ]
  green_card = [ green_x,   green_y,   64, 128, 'sprites/hexagon-green.png' ]
  args.outputs.sprites << red_card
  args.outputs.sprites << green_card


  if args.inputs.mouse.click
    args.state.last_mouse_click = args.inputs.mouse.click
  end

  if args.state.last_mouse_click
    if args.state.last_mouse_click.point.inside_rect? red_card
      if(args.state.resource != 0)
        args.state.resource -= 1
        args.state.health -= 5
        args.state.last_mouse_click = nil
        args.state.discard_count += 1
      end
    elsif args.state.last_mouse_click.point.inside_rect? green_card
      args.state.health += 5
      args.state.last_mouse_click = nil
    end
  end
end

def tick args
  ui(args)
end

#$gtk.reset

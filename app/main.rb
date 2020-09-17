def ui args
  args.state.resource ||= 3
  args.state.health ||= 100
  args.state.discard_count ||= 0
  discard_count_x ||= 800
  discard_count_y ||= 250
  args.state.discard_label_alpha ||= 0
  red_x ||= 200
  red_y ||= 100
  green_x ||= 500
  green_y ||= 100
  discard_x ||= 800
  discard_y ||= 100
  args.outputs.labels << [ 580, 500, "Health: #{args.state.health}" ]
  args.outputs.labels << [ 25, 650, "Energy: #{args.state.resource}" ]
  red_card   = [ red_x,     red_y,     128, 128, 'sprites/hexagon-red.png' ]
  green_card = [ green_x,   green_y,   128, 128, 'sprites/hexagon-green.png' ]
  discard   = [ discard_x, discard_y, 128, 128, 'sprites/hexagon-black.png' ]
  discard_label = [ discard_count_x, discard_count_y, "Discarded: #{args.state.discardCount}", 0, 0, 0, args.state.discard_label_alpha ]
  args.outputs.labels << discard_label
  args.outputs.sprites << red_card
  args.outputs.sprites << green_card
  args.outputs.sprites << discard

  if args.inputs.mouse.click
    args.state.last_mouse_click = args.inputs.mouse.click
  end

  if args.inputs.mouse.point.inside_rect? discard
    args.state.discard_label_alpha = 255
  end
  if !args.inputs.mouse.point.inside_rect? discard
    args.state.discard_label_alpha = 0
  end

  if args.state.last_mouse_click
    if args.state.last_mouse_click.point.inside_rect? red_card
      if(args.state.resource != 0)
        args.state.resource -= 1
        args.state.health -= 5
        args.state.last_mouse_click = nil
        args.state.discardCount += 1
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

def tick args
  args.state.health ||= 100
  args.state.redX ||= 200
  args.state.greenX ||= 500
  args.state.greenY ||= 100
  args.state.redY ||= 100
  args.outputs.labels << [ 580, 500, "Health: #{args.state.health}" ]
  redCard = [ args.state.redX, args.state.redY, 128, 128, 'sprites/hexagon-red.png' ]
  greenCard = [ args.state.greenX, args.state.greenY, 128, 128, 'sprites/hexagon-green.png' ]
  args.outputs.sprites << redCard
  args.outputs.sprites << greenCard

  if args.inputs.mouse.click
    args.state.last_mouse_click = args.inputs.mouse.click
  end

  if args.state.last_mouse_click
    if args.state.last_mouse_click.point.inside_rect? redCard
      args.state.health -= 5
      args.state.last_mouse_click = nil
    elsif args.state.last_mouse_click.point.inside_rect? greenCard
      args.state.health += 5
      args.state.last_mouse_click = nil
    end
  end
end

#$gtk.reset

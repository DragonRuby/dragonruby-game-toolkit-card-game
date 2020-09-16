def tick args
  args.state.playerX ||= 5
  args.state.playerY ||= 100
  args.state.count ||= 0
  args.outputs.labels << [ 580, 400, "#{args.state.x}, #{args.state.y}"]
  args.outputs.labels << [ 580, 520, "#{args.state.count}" ]
  args.outputs.labels << [ 580, 500, 'Hi World!' ]
  args.outputs.labels << [ 640, 460, 'Go to docs/docs.html and read it!', 5, 1 ]
  args.outputs.sprites << [ args.state.x, args.state.y, 128, 101, 'sprites/dragon-0.png' ]

  if args.inputs.mouse.click
    args.state.x = args.inputs.mouse.x
    args.state.y = args.inputs.mouse.y
  end

  args.state.count += 1
end

$gtk.reset

#Player stats array

# def game_state args
#   args.state.game_state = {
#       player: {
#         max_health: 20,
#         health: 20,
#         energy: 3
#       },
#
#       enemies: {
#           max_health: 20,
#           health: 10,
#           actions: [:attack, :heal],
#           next_move: :attack
#       }
#   }
# end

class Card
    attr_accessor :title
    attr_accessor :description
    attr_accessor :cost
end

class Heal < Card
  class << self
    @title = "Heal"
    @description = "Heal 5 HP"
    @cost = 1
    def action
        $Player.health += 5
    end
  end
end

class Attack < Card
  class << self
    @title = "Attack"
    @description = "Deal 5 damage to an enemy"
    @cost = 1
    def action target
      target -= 5
    end
  end
end

$Heal = Heal.new
$Attack = Attack.new

class Player
  attr_accessor :state, :max_health, :health, :energy, :strength, :sprite
  def initialize
    @max_health = 20
    @health ||= 20
    @energy ||= 3
    @strength ||= 0
    @sprite ||= 'sprites/dragon-0.png'
  end
end

#attack is separate from action
class Enemy
  attr_accessor :state, :name, :health, :armor, :sprite
end

class Blob < Enemy
  def initialize
    @name = "Blob"
    @health = 10
    @armor = 0
    @sprite = 'sprites/square-red.png'
  end

  def attack

  end

  def action

  end
end

class Discard
  attr_accessor :state, :cards, :sprite, :card_count

  def initialize
    @cards = []
    @sprite = 'sprites/hexagon-black.png'
    @card_count = @cards.length
  end
end

class Deck
  attr_accessor :state, :cards, :sprite, :card_count

  def initialize
    @cards = [$Attack, $Attack, $Attack, $Attack, $Attack,
              $Heal, $Heal, $Heal, $Heal, $Heal]
    @card_count = @cards.length
    @sprite = 'sprites/hexagon-indigo.png'
  end

  #draw a single card
  # def draw
  #
  # end

  #drawing at the start of a new turn
  # def draw_start
  #
  # end

end

# def player args
#   args.state.energy ||= 3
#   args.state.player_health ||= 100
# end
#
# def enemy args
#   args.state.enemy_health ||= 100
# end
#
# def discard args
#   args.state.discard_count ||= 0
# end

# def deck args
#
#   #args.state.deck = [ :attack, :attack, :attack, :attack, :attack,
#   #                    :heal, :heal, :heal, :heal, :heal ]
#   args.state.deck = ["attack", "heal"]
#   args.state.deck_count ||= args.state.deck.length()
#
#   #args.state.cards = {
#   #     attack: {
#   #         sprite: 'sprites/hexagon-red.png',
#   #         title: 'Attack',
#   #         description: 'Attack the Enemy for 5 damage',
#   #         cost: 1,
#   #         action: -> (args.state.enemy_health) {
#   #           args.state.enemy_health -= 5
#   #         }
#   #     },
#   #     heal: {
#   #         sprite: 'sprites/hexagon-green.png',
#   #         title: 'Heal',
#   #         description: 'Heal yourself for 7 health',
#   #         cost: 1,
#   #         action: -> (args.state.player_health) {
#   #           args.state.player_health += 7
#   #         }
#   #     }
#   # }
# end

$PlayerDeck = Deck.new
$Player = Player.new
$DiscardPile = Discard.new
$Blob = Blob.new

# class UI
#   attr_accessor :state, :outputs, :inputs
#                 # :deck_x, :deck_y,
#                 # :hand_x, :hand_y,
#                 # :discard_x, :discard_y,
#                 # :player_x, :player_y,
#                 # :player_health_x, :player_health_y,
#                 # :player_energy_x, :player_energy_y,
#                 # :enemies_x, :enemies_y,
#                 # :enemies_health_x, :enemies_health_y
#   def tick
#     defaults
#     render
#   end
#
#   def defaults
#     state.deck_count = 10
#     state.discard_count = 0
#     state.deck_x           = 20
#     state.deck_y           = 60
#     state.deck_label_alpha ||= 0
#     state.hand_x           = 110
#     state.hand_y           = 60
#     state.discard_x        = 1150
#     state.discard_y        = 60
#     state.discard_label_alpha ||= 0
#     state.player_x         = 90
#     state.player_y         = 250
#     state.player_energy_x  = 25
#     state.player_energy_y  = 650
#     state.enemies_x        = 800
#     state.enemies_y        = 250
#   end
#
#   def render
#     render_deck
#     render_hand
#     render_discard
#     render_enemies
#     render_player
#   end
#
#   def render_deck
#     deck_symbol = [ state.deck_x, state.deck_y, 64, 128, 'sprites/hexagon-indigo.png' ]
#     outputs.sprites << deck_symbol
#     outputs.labels  << [ state.deck_x, state.deck_y + 150, "Cards in Deck: #{state.deck_count}", 0, 0, 0, args.state.deck_label_alpha ]
#
#     if inputs.mouse.point.inside_rect? deck_symbol
#       state.deck_label_alpha = 255
#     end
#     if !inputs.mouse.point.inside_rect? deck_symbol
#       state.deck_label_alpha = 0
#     end
#   end
#
#   def render_hand
#     red_x ||= 300
#     red_y ||= 100
#     green_x ||= 600
#     green_y ||= 100
#     outputs.sprites << [ red_x,     red_y,     64, 128, 'sprites/hexagon-red.png' ]
#     outputs.sprites << [ green_x,   green_y,   64, 128, 'sprites/hexagon-green.png' ]
#   end
#
#   def render_discard
#     discard_symbol =  [ state.discard_x, state.discard_y, 64, 128, 'sprites/hexagon-black.png' ]
#     outputs.sprites << discard_symbol
#     outputs.labels  << [ state.discard_x, args.state.discard_y + 150, "Discarded: #{state.discard_count}", 0, 0, 0, state.discard_label_alpha ]
#
#     if inputs.mouse.point.inside_rect? discard
#       state.discard_label_alpha = 255
#     end
#     if !inputs.mouse.point.inside_rect? discard
#       state.discard_label_alpha = 0
#     end
#   end
#
#   def render_enemies
#     outputs.labels << [ state.enemies_x, state.enemies_y + 150, "Enemy Health: 30" ]
#     outputs.sprites << [state.enemies_x, state.enemies_y, 100, 100, 'sprites/square-red.png']
#   end
#
#   def render_player
#     outputs.sprites << [ state.player_x, state.player_y, 100, 100,  'sprites/dragon-0.png' ]
#     outputs.labels << [ state.player_x, args.state.player_y + 150, "Your Health: 30" ]
#   end
# end

def ui args

  #Deck information
  args.state.deck_x ||= 20
  args.state.deck_y ||= 40
  deck_symbol = [ args.state.deck_x, args.state.deck_y, 64, 128, $PlayerDeck.sprite ]
  args.outputs.sprites << deck_symbol

  args.state.deck_label_alpha ||= 0
  deck_label = [ args.state.deck_x, args.state.deck_y + 150, "Cards in Deck: #{$PlayerDeck.card_count}", 0, 0, 0, args.state.deck_label_alpha ]
  args.outputs.labels << deck_label

  if args.inputs.mouse.point.inside_rect? deck_symbol
    args.state.deck_label_alpha = 255
  end
  if !args.inputs.mouse.point.inside_rect? deck_symbol
    args.state.deck_label_alpha = 0
  end


  #Discard Display
  args.state.discard_x ||= 1150
  args.state.discard_y ||= 40
  discard = [ args.state.discard_x, args.state.discard_y, 64, 128, $DiscardPile.sprite ]
  args.outputs.sprites << discard

  args.state.discard_label_alpha ||= 0
  args.state.discard_count_x = args.state.discard_x
  args.state.discard_count_y = args.state.discard_y + 150
  discard_label = [ args.state.discard_count_x, args.state.discard_count_y, "Discarded: #{$DiscardPile.card_count}", 0, 0, 0, args.state.discard_label_alpha ]
  args.outputs.labels << discard_label

  if args.inputs.mouse.point.inside_rect? discard
    args.state.discard_label_alpha = 255
  end
  if !args.inputs.mouse.point.inside_rect? discard
    args.state.discard_label_alpha = 0
  end


  #Energy display
  args.outputs.labels << [ 25, 650, "Energy: #{$Player.energy}" ]

  #Player display
  args.state.player_x ||= 250
  args.state.player_y ||= 400
  args.outputs.sprites << [ args.state.player_x, args.state.player_y, 100, 100,  $Player.sprite ]
  args.outputs.labels << [ args.state.player_x, args.state.player_y + 150, "Your Health: #{$Player.health}" ]

  #Enemy Display
  args.state.enemy_x ||= 750
  args.state.enemy_y ||= 400
  args.state.enemy_health_x ||= args.state.player_x
  args.state.player_health_y ||= args.state.player_y + 150
  args.outputs.sprites << [args.state.enemy_x, args.state.enemy_y, 100, 100, $Blob.sprite ]
  args.outputs.labels << [ args.state.enemy_x, args.state.enemy_y + 150, "Enemy Health: #{$Blob.health}" ]

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

  #If a card is moused over move it up by 50 px and leave it there if it's selected
  if args.state.last_mouse_click
    if args.state.last_mouse_click.point.inside_rect? red_card
      if(args.state.energy != 0)
        args.state.energy -= 1
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
  $PlayerDeck.state = args.state
  $Player.state = args.state
  $DiscardPile.state = args.state
  $Blob.state = args.state
  # player(args)
  # enemy(args)
  # deck(args)
  ui(args)
end

$gtk.reset

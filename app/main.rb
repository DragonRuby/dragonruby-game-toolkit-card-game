#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Questions/ known issues:
# Click card, click enemy, card is spent, then if I click on another card and then the same enemy I have to click on that enemy twice for any effect to occur
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TODO:
# Get heal cards working
# Allow targeting of player
# Change the Sprites
# Change position
#   Cards don't just move over after one is played
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# EXTRAS:
# Mousing over player, enemy, or card makes them bigger/ shows they are being hovered over (with a green border)?
# More enemies
# More cards
# Animations
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Cards
  attr_accessor :items, :selected_card_history
  def initialize items #array
    @items = items
    @selected_card_history = []
  end
end
class Card
  attr_accessor :title, :description, :cost, :sprite, :pos_x, :pos_y, :width, :height, :on_screen, :selected

  def render
    return [@pos_x, @pos_y, @width, @height, @sprite]
  end

  def setDisplay x, y, w, h
    @pos_x = x
    @pos_y ||= y
    @width ||= w
    @height ||= h
  end

  def select
    if(!@selected)
      @pos_y += 50
      @selected = true
      $gtk.notify! "Card is selected"
    elsif(@selected)
      @pos_y -= 50
      @selected = false
    end
  end

  def deselect
    if((@pos_y > 100) && (@selected))
      @pos_y -= 50
    end
    @selected = false
  end

end
class Attack < Card
  def initialize
    @sprite ||= 'sprites/hexagon-red.png'
    @title ||= "Attack"
    @description ||= "Deal 5 damage to an enemy"
    @cost ||= 1
    @pos_x ||= nil
    @pos_y ||= nil
    @length ||= nil
    @height ||= nil
    @on_screen ||= false
    @selected ||= false
  end

  def action target, player
    target.health -= (5 + player.strength)
  end

end
class Heal < Card
  def initialize
    @title = "Heal"
    @description = "Heal 5 HP"
    @cost = 1
    @sprite = 'sprites/hexagon-green.png'
    @pos_x ||= nil
    @pos_y ||= nil
    @length ||= nil
    @height ||= nil
    @on_screen ||= false
    @selected ||= false
  end

  def action target
    if($Player.energy >= @cost)
      target.health += 5
      $Player.energy -= @cost
    end
  end

  def select
    @pos_y += 50
  end
end

class Deck
  attr_accessor :cards, :sprite, :deck_label_alpha, :deck_symbol

  def initialize
    #@cards = [Attack.new, Attack.new, Attack.new, Attack.new, Attack.new]#,
              #Heal.new, Heal.new, Heal.new, Heal.new, Heal.new]
    @cards = Cards.new([Attack.new, Attack.new, Attack.new, Attack.new, Attack.new])
    @sprite = 'sprites/hexagon-indigo.png'
    @deck_label_alpha = 0
    # @outputs = outputs
  end

  def addCard card
    @cards.items << card
  end

  # def tick args
  #   #display info
  #   #Deck information
  #   deck_x ||= 20
  #   deck_y ||= 40
  #   deck_symbol = [ deck_x, deck_y, 64, 128, @sprite ]
  #   args.outputs.sprites << deck_symbol
  #
  #   args.state.deck_label_alpha ||= 0
  #   deck_label = [ deck_x, deck_y + 150, "Cards in Deck: #{@cards.items.length}", 0, 0, 0, args.state.deck_label_alpha ]
  #   args.outputs.labels << deck_label
  #
  #   if args.inputs.mouse.point.inside_rect? deck_symbol
  #     args.state.deck_label_alpha = 255
  #   end
  #   if !args.inputs.mouse.point.inside_rect? deck_symbol
  #     args.state.deck_label_alpha = 0
  #   end
  # end

  def render args
    deck_x ||= 20
    deck_y ||= 40
    @deck_symbol = [ deck_x, deck_y, 64, 128, @sprite ]
    args.outputs.sprites << @deck_symbol

    deck_label = [ deck_x, deck_y + 150, "Cards in Deck: #{@cards.items.length}", 0, 0, 0, @deck_label_alpha ]
    args.outputs.labels << deck_label
  end

  def inputs args
    if args.inputs.mouse.point.inside_rect? @deck_symbol
      @deck_label_alpha = 255
    end
    if !args.inputs.mouse.point.inside_rect? @deck_symbol
      @deck_label_alpha = 0
    end
  end

  def isEmpty
    if(@cards.items.length == 0)
      return true
    end
  end

end

class Discard
  attr_accessor :cards, :sprite, :discard_label_alpha, :discard_symbol

  def initialize
    @cards = Cards.new([])
    @sprite = 'sprites/hexagon-black.png'
    @discard_label_alpha = 0
  end

  def shuffle
    #$PlayerDeck.card_count = @card_count
    #@card_count = 0
    @cards.items.each_with_index do |card, i|
      $PlayerDeck.cards << @cards.items[i]
    end
  end

  # def tick args
  #   discard_x ||= 1150
  #   discard_y ||= 40
  #   discard = [ discard_x, discard_y, 64, 128, @sprite ]
  #   args.outputs.sprites << discard
  #
  #   args.state.discard_label_alpha ||= 0
  #   discard_label = [ discard_x, discard_y + 150, "Discarded: #{@cards.items.length}", 0, 0, 0, args.state.discard_label_alpha ]
  #   args.outputs.labels << discard_label
  #
  #   if args.inputs.mouse.point.inside_rect? discard
  #     args.state.discard_label_alpha = 255
  #   end
  #   if !args.inputs.mouse.point.inside_rect? discard
  #     args.state.discard_label_alpha = 0
  #   end
  # end

  def render args
    discard_x ||= 1150
    discard_y ||= 40
    @discard_symbol = [ discard_x, discard_y, 64, 128, @sprite ]
    args.outputs.sprites << @discard_symbol

    discard_label = [ discard_x, discard_y + 150, "Discarded: #{@cards.items.length}", 0, 0, 0, @discard_label_alpha ]
    args.outputs.labels << discard_label
  end

  def inputs args
    if args.inputs.mouse.point.inside_rect? @discard_symbol
      @discard_label_alpha = 255
    end
    if !args.inputs.mouse.point.inside_rect? @discard_symbol
      @discard_label_alpha = 0
    end
  end

  def addCard card
    @cards.items << card
  end

  def isEmpty
    if(@cards.items.length == 0)
      return true
    end
  end

end

class Hand
  attr_accessor  :cards

  def initialize
    @cards = Cards.new([])
  end

  def render args
    @cards.items.each_with_index do |card, i|
      card.setDisplay((i+1)*100, 100, 64, 128)
      args.outputs.sprites << card.render
    end
  end

  def addCard card
    @cards.items << card

  end

  def draw_start
    for i in 1..3 do
      x = rand($PlayerDeck.cards.length)
      @cards.items << $PlayerDeck.cards[x]
    end
  end

  # def tick args
  #   #display function
  #   render args
  #
  #   # play function
  #   inputs args
  #
  #   debug_hand args
  #
  # end

  def debug_hand args
    args.outputs.debug << [10, 710, "#{args.inputs.mouse.x}, #{args.inputs.mouse.y}"].label
    @cards.items.each do |c|
      contains_mouse = args.inputs.mouse.point.inside_rect? [c.pos_x, c.pos_y, c.width, c.height]
      args.outputs.debug << [c.pos_x, c.pos_y, c.width, c.height].border
      if(c.selected)
        args.outputs.debug << [c.pos_x, c.pos_y, c.width, c.height, 0, 255, 0].border
      end
      args.outputs.debug << [c.pos_x, c.pos_y - 30, "#{contains_mouse}"].label
    end

    if(args.inputs.mouse.click)
      # notify! "Click Ocurred at #{args.inputs.mouse.click.x}, #{args.inputs.mouse.click.y}"
    end

  end

  def inputs args
    if args.inputs.mouse.down && (@cards.items.length > 0)
      found_card = @cards.items.find {|card| args.inputs.mouse.click.point.inside_rect? card.render}
      if(found_card)
        @cards.items.each(&:deselect)
        if(@cards.selected_card_history.last != found_card)
          found_card.select
          @cards.selected_card_history << found_card
        else
          @cards.selected_card_history = @cards.selected_card_history[0..-2]
        end
      end
    end
  end

  def isEmpty
    if(@cards.items.length == 0)
      return true
    end
  end

end

class Enemies
  attr_accessor :items, :selected_enemy_history
  def initialize items #array
    @items = items
    @selected_enemy_history = []
  end
end
class EnemiesOnScreen
  attr_accessor :enemies

  def initialize
    @enemies = Enemies.new([Blob.new(750, 400), Blob.new(950, 400)])
  end

  def inputs args
    if args.inputs.mouse.down && (@enemies.items.length > 0)
      found_enemy = @enemies.items.find {|enemy| args.inputs.mouse.click.point.inside_rect? enemy.render}
      if(found_enemy)
        @enemies.items.each(&:deselect)
        if(@enemies.selected_enemy_history.last != found_enemy)
          found_enemy.select
          @enemies.selected_enemy_history << found_enemy
        else
          @enemies.selected_enemy_history = @enemies.selected_enemy_history[0..-2]
        end
      end
    end
  end

  def render args
    @enemies.items.each do |enemy|
      enemy.setDisplay(enemy.pos_x, enemy.pos_y, 100, 100)
      args.outputs.sprites << enemy.render
      args.outputs.labels << [ enemy.pos_x, enemy.pos_y + 150, "Enemy Health: #{enemy.health}" ]
      args.outputs.borders << [enemy.pos_x - 10, enemy.pos_y - 10, enemy.width + 20, enemy.height + 20, 255, 0, 0, enemy.border_alpha]
    end
  end
end
class Enemy
  attr_accessor :name, :health, :armor, :sprite, :number_of_actions, :pos_x, :pos_y, :width, :height, :selected, :border_alpha

  def render
    return [@pos_x, @pos_y, @width, @height, @sprite]
  end

  def setDisplay x, y, w, h
    @pos_x = x
    @pos_y = y
    @width = w
    @height = h
  end

  def select
    if(!@selected)
      @selected = true
      $gtk.notify! "Enemy is selected"
      @border_alpha = 128
    elsif(@selected)
      @selected = false
    end
  end

  def deselect
    @selected = false
    @border_alpha = 0
  end

end
class Blob < Enemy
  def initialize x,y
    @name = "Blob"
    @health = 10
    @armor = 0
    @sprite = 'sprites/square-red.png'
    @number_of_actions = 2
    @pos_x ||= x
    @pos_y ||= y
    @length ||= 100
    @height ||= 100
    @selected ||= false
    @border_alpha ||= 0
  end

  #decreases the player's health
  def attack target
    target.health -= 5
  end

  #decreases the player's strength
  def ability_1 target
    target.strength -= 1
  end

  # def tick args
  #   #Enemy Display
  #   args.outputs.sprites << [@pos_x, @pos_y, @length, @height, @sprite ]
  #   args.outputs.labels << [ @health_x, @health_y, "Enemy Health: #{@health}" ]
  # end
end

class Player
  attr_accessor :max_health, :health, :max_energy, :energy, :strength, :sprite
  def initialize
    @max_health = 30
    @health = @max_health
    @max_energy = 3
    @energy = @max_energy
    @strength = 0
    @sprite = 'sprites/dragon-0.png'
  end

  def tick args
    #Energy display
    args.outputs.labels << [ 25, 650, "Energy: #{@energy}" ]

    #Player display
    args.state.player_x ||= 250
    args.state.player_y ||= 400
    args.outputs.sprites << [ args.state.player_x, args.state.player_y, 100, 100,  @sprite ]
    args.outputs.labels << [ args.state.player_x, args.state.player_y + 150, "Your Health: #{@health}" ]
  end

  def render args
    #Energy display
    args.outputs.labels << [ 25, 650, "Energy: #{@energy}" ]
    args.outputs.labels << [ 25, 625, "Strength: #{@strength}" ]

    #Player display
    args.state.player_x ||= 250
    args.state.player_y ||= 400
    args.outputs.sprites << [ args.state.player_x, args.state.player_y, 100, 100,  @sprite ]
    args.outputs.labels << [ args.state.player_x, args.state.player_y + 150, "Your Health: #{@health}" ]
  end

  def inputs args

  end

end

class UI
  attr_accessor :end_turn_button, :end_turn

  def initialize
    @end_turn_button = [400, 625, 300, 30, 'sprites/square-blue.png']
    @end_turn = false
  end

  def render args
    args.outputs.sprites << @end_turn_button
  end

  def inputs args
    if args.inputs.mouse.click
      if args.inputs.mouse.click.point.inside_rect? @end_turn_button
        @end_turn = true
      end
    end
  end

end

class Game
  attr_accessor :hand

  def initialize
    #alphabetized
    @deck = Deck.new
    @discard = Discard.new
    @enemiesOnScreen = EnemiesOnScreen.new
    @hand = Hand.new
    @player = Player.new
    @UI = UI.new
    @start_turn = true
  end

  # this is the entry point for Game (which is the ~tick~ method).
  def tick args
    #@deck.tick args
    #@discard.tick args
    #@hand.tick args
    #@player.tick args
    # @enemies.items.each do |enemy|
    #   enemy.tick args
    # end
    render args
    inputs args
    calc args
  end

  def defaults args

  end

  def render args
    @deck.render args
    @discard.render args
    @hand.render args
    @player.render args
    @enemiesOnScreen.render args
    @UI.render args

    #Temporary Draw Button in the top right-hand corner
    draw = [1150, 650, 200, 100, 180, 0, 0, 360]
    args.outputs.solids << draw
    if args.inputs.mouse.click
      if args.inputs.mouse.click.point.inside_rect? draw
        if(!@deck.isEmpty)
          x = rand(@deck.cards.items.length)
          @hand.addCard(@deck.cards.items[x])
          @deck.cards.items.delete_at(x)
        end
      end
    end
  end

  def inputs args
    @deck.inputs args
    @discard.inputs args
    @hand.inputs args
    @enemiesOnScreen.inputs args
    @player.inputs args
    @UI.inputs args
  end

  def calc args
    #Draw 3 at the start of each turn
    # if(@start_turn)
    #   @start_turn = false
    #   3.times do
    #     if(@hand.cards.items.length < 3 && !@deck.isEmpty)
    #       x = rand(@deck.cards.items.length)
    #       @hand.addCard(@deck.cards.items[x])
    #       @deck.cards.items.delete_at(x)
    #     elsif(@deck.isEmpty)
    #       reshuffle_deck
    #     end
    #   end
    # end

    while(@start_turn)
      if(@hand.cards.items.length < 3)
        if(!@deck.isEmpty)
          x = rand(@deck.cards.items.length)
          @hand.addCard(@deck.cards.items[x])
          @deck.cards.items.delete_at(x)
        elsif(@deck.isEmpty)
          reshuffle_deck
        end
      else
        @start_turn = false
      end
    end

    #Allows the user to play cards (ATTACK CARDS ONLY RIGHT NOW)(Switch case for the types of cards)
    @hand.cards.items.each do |card|
      @enemiesOnScreen.enemies.items.each do |enemy|
        if(card.selected && enemy.selected && (@player.energy >= card.cost)) #add selected value to enemy
          card.action(enemy, @player)
          @player.energy -= card.cost
          card.deselect
          enemy.deselect
          @discard.addCard(card)
          @hand.cards.items.delete(card)
          enemy.deselect
        end
      end
    end

    #Refills deck from Discard
    if(@deck.isEmpty)
      # while @discard.cards.items.length > 0 do
      #   x = rand(@discard.cards.items.length)
      #   @deck.addCard(@discard.cards.items[x])
      #   @discard.cards.items.delete_at(x)
      # end
      reshuffle_deck
    end

    #Determines and removes Enemies if they are killed
    @enemiesOnScreen.enemies.items.each do |enemy|
      if(enemy.health <= 0)
        @enemiesOnScreen.enemies.items.delete(enemy)
      end
    end

    #Ends the players turn and lets Enemies take theirs
    if(@UI.end_turn) #If it's NOT the player's turn
      #Deselect's any cards in the player's hand
      @hand.cards.items.each do |card|
        card.deselect
      end

      #Any unused cards are added to the discard pile
      while @hand.cards.items.length > 0 do
        x = rand(@hand.cards.items.length)
        @discard.addCard(@hand.cards.items[x])
        @hand.cards.items.delete_at(x)
      end

      #Enemies do their actions
      @enemiesOnScreen.enemies.items.each do |enemy|
        action_choice = rand(2)
        case action_choice

        when 0
          enemy.attack @player

        when 1
          enemy.ability_1 @player

        end
      end

      $gtk.notify! "Turn ended!"

      #The player's energy is reset
      @player.energy = @player.max_energy

      #It is now the player's turn
      @UI.end_turn = false
      @start_turn = true
    end

  end

  #Made purely because this gets used twice
  def reshuffle_deck
    while @discard.cards.items.length > 0 do
      x = rand(@discard.cards.items.length)
      @deck.addCard(@discard.cards.items[x])
      @discard.cards.items.delete_at(x)
    end
  end

end


def tick args
  # On ~tick~, create a new instances of the Game class
  $game ||= Game.new

  # Call ~tick~ on the game class.
  $game.tick args
end

$gtk.reset
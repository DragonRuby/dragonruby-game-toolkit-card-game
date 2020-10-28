#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Questions/ known issues:
#   Click card, click enemy, card is spent, then if I click on another card and then the same enemy I have to click on that enemy twice for any effect to occur
#   Cleaner way to have one slime target enemies and a different slime target friendlies in the same ability slot (ability 3)
#   Pause the game loop? If enemies are cleared and I want to wait for player input before continuing
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TODO:
#   1. Fix the known issues
#   2a. Get heal cards working (Done)
#   2b. Allow targeting of player (Kinda Done)
#   2c. Prevent targeting of both player AND Enemy at the same time
#   3. Change positions of objects on screen
#       -Cards don't just move over after one is played
#   4. Change the Sprites
#   5. Remove comments and clean up code
#     -Change order of card attr_accessor
#   6. Remove any deprecated methods
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# EXTRAS:
#   Mousing over player, enemy, or card makes them bigger/ shows they are being hovered over (with a green border)?
#   More enemies
#   More cards
#   Animations
#   Make things more streamlined (go through the RubyMine warnings)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Cards
  attr_accessor :items, :selected_card_history
  def initialize items #array
    @items = items
    @selected_card_history = []
  end
end
class Card
  attr_accessor :title, :description, :cost, :sprite, :pos_x, :pos_y, :width, :height, :on_screen, :selected, :id, :info_alpha

  def initialize
    @pos_x, @pos_y, @width, @height = nil
    @on_screen, @selected = false
    @info_alpha = 0
  end
  def render
    [@pos_x, @pos_y, @width, @height, @sprite]
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
class AttackCard < Card
  def initialize
    super()
    @title = "Attack"
    @id = "base_attack"
    @description = "Deal 5 damage to an enemy"
    @sprite = 'sprites/hexagon-red.png'
    @cost = 1
    # @pos_x, @pos_y, @length, @height = nil
    # @on_screen, @selected = false
    # @info_alpha = 0
  end
  def action target, player
    target.health -= (5 + player.strength)
  end
end
class HealCard < Card
  def initialize
    super()
    @title = "Heal"
    @id = "base_heal"
    @description = "Heal 5 HP"
    @sprite = 'sprites/hexagon-green.png'
    @cost = 1
    # @pos_x, @pos_y, @lengt, @height = nil
    # @on_screen, @selected = false
  end
  def action target
    target.health += 5
    if(target.health > target.max_health)
      target.health = target.max_health
    end
  end
end
class StrengthCard < Card
  def initialize
    super()
    @title = "Strength"
    @id = "base_strength"
    @description = "Grants 2 strength to the target"
    @sprite = 'sprites/hexagon-white.png'
    @cost = 2
    # @pos_x, @pos_y, @length, @height = nil
    # @on_screen, @selected = false
  end
  def action target
    target.strength += 2
  end
end
class DeadCard < Card
  def initialize
    super()
    @title = "Waste of Space"
    @id = "dead_card"
    @description = "Takes up space in the player's hand and deck"
    @sprite = 'sprites/hexagon-orange.png'
    @cost = 1
    # @pos_x, @pos_y, @length, @height = nil
    # @on_screen, @selected = false
  end
end
class DrawCard < Card
  def initialize
    super()
    @title = "Draw 2"
    @id = "base_draw"
    @description = "Draws two cards from the deck"
    @sprite = 'sprites/hexagon-blue.png'
    @cost = 2
    # @pos_x, @pos_y, @length, @height = nil
    # @on_screen, @selected = false
  end
  def action target, card
    target.addCard(card)
  end
end

class Deck
  attr_accessor :cards, :sprite, :deck_label_alpha, :deck_symbol

  def initialize
    @cards = Cards.new([AttackCard.new, AttackCard.new, AttackCard.new, AttackCard.new,
                        HealCard.new, HealCard.new, HealCard.new, HealCard.new,
                        StrengthCard.new, DrawCard.new])
    @sprite = 'sprites/hexagon-indigo.png'
    @deck_label_alpha = 0
  end

  def addCard card
    @cards.items << card
  end

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
    else
      @deck_label_alpha = 0
    end
  end

  def isEmpty
    if(@cards.items.length == 0)
      return true
    end
  end

  def levelComplete
    #Removes any dead cards from the deck
    @cards.items.each do |card|
      if(card.id == "dead_card")
        @cards.items.delete(card)
      end
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
    @cards.items.each_with_index do |card, i|
      $PlayerDeck.cards << @cards.items[i]
    end
  end

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
  attr_accessor :cards

  def initialize
    @cards = Cards.new([])
  end

  def render args
    @cards.items.each_with_index do |card, i|
      card.setDisplay(((i+1)*100)+300, 100, 64, 128)
      args.outputs.sprites << card.render
      args.outputs.labels << [card.pos_x, card.pos_y + 203, "#{card.title}", 0, 0, 0, card.info_alpha]
      args.outputs.labels << [card.pos_x, card.pos_y + 178, "#{card.description}", 0, 0, 0, card.info_alpha]
      args.outputs.labels << [card.pos_x, card.pos_y + 153, "Cost: #{card.cost}", 0, 0, 0, card.info_alpha]
    end
  end

  def addCard card
    @cards.items << card
  end

  #Deprecated
  def draw_start
    for i in 1..3 do
      x = rand($PlayerDeck.cards.length)
      @cards.items << $PlayerDeck.cards[x]
    end
  end

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

    @cards.items.each do |card|
      if(args.mouse.point.inside_rect? card.render)
        card.info_alpha = 255
      else
        card.info_alpha = 0
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
    @enemies = Enemies.new([RedBlob.new(750, 400), GreenBlob.new(950, 400)])
  end

  def inputs args
    if args.inputs.mouse.down && (@enemies.items.length > 0)
      found_enemy = @enemies.items.find {|enemy| args.inputs.mouse.click.point.inside_rect? enemy.enemy_render}
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

    @enemies.items.each do |enemy|
      if args.inputs.mouse.point.inside_rect? enemy.enemy_render
        enemy.info_alpha = 255
        enemy.border_alpha = 255
      else
        if(!enemy.selected)
          enemy.info_alpha = 0
          enemy.border_alpha = 0
        end
      end
    end

  end

  def render args
    @enemies.items.each do |enemy|
      enemy.setDisplay(enemy.pos_x, enemy.pos_y, 100, 100)
      args.outputs.sprites << enemy.enemy_render
      args.outputs.labels << [ enemy.pos_x, enemy.pos_y + 150, "Enemy Health: #{enemy.health}" ]
      args.outputs.borders << [enemy.pos_x - 10, enemy.pos_y - 10, enemy.width + 20, enemy.height + 20, 255, 0, 0, enemy.border_alpha]
      args.outputs.labels << [enemy.pos_x, enemy.pos_y - 30, "Enemy Strength: #{enemy.strength}", 0, 0, 0, enemy.info_alpha]
    end
  end
end
class Enemy
  attr_accessor :name, :health, :armor, :sprite, :number_of_actions, :pos_x, :pos_y, :width, :height, :selected, :border_alpha, :strength, :info_alpha

  def initialize
    @selected = false
    @border_alpha = 0
    @strength = 0
    @info_alpha = 0
  end
  def enemy_render
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
class GreenBlob < Enemy
#Adds useless cards to the player's Deck and heals its allies
  def initialize x,y
    @name = "Green Blob"
    @health = 15
    @armor = 0
    @sprite = 'sprites/square-green.png'
    @number_of_actions = 2
    @pos_x = x
    @pos_y = y
    @length = 100
    @height = 100
    super()
    # @selected = false
    # @border_alpha = 0
    # @strength = 0
    # @info_alpha = 0
  end

  #decreases the player's health
  def ability_0 target
    target.health -= 5 + @strength
  end

  #Adds useless card to deck
  def ability_1 player, deck
    deck.addCard(DeadCard.new)
  end

  #Heals allies
  def ability_2 target
    target.health += 3
  end

  #Attacks (see ability_0)
  def ability_3 target
    ability_0 target
  end
end
class KingBlob < Enemy
  def initialize x,y
    @name = "King Blob"
    @health = 40
    @armor = 0
    @sprite = 'sprites/square-yellow.png'
    @number_of_actions = 4
    @pos_x = x
    @pos_y = y
    @length = 200
    @height = 200
    super()
    # @selected = false
    # @border_alpha = 0
    # @strength = 0
    # @info_alpha = 0
  end

  #decreases the player's health
  def ability_0 target
    target.health -= 15 + @strength
    target.strength -= 2
    if(target.strength < target.min_strength)
      target.strength = taret.min_strength
    end
  end

  #decreases the player's strength
  def ability_1 target, deck
    target.strength -= 1
    if(target.strength < target.min_strength)
      target.strength = taret.min_strength
    end
    deck.addCard(DeadCard.new)
    deck.addCard(DeadCard.new)
  end

  #Increases a monster's strength
  def ability_2 target
    target.health += 20
    target.strength += 2
  end

  #Attacks (see ability_0)
  def ability_3 target
    ability_0 target
  end
end
class RedBlob < Enemy
  def initialize x,y
    @name = "Red Blob"
    @health = 20
    @armor = 0
    @sprite = 'sprites/square-red.png'
    @number_of_actions = 4
    @pos_x = x
    @pos_y = y
    @length = 100
    @height = 100
    super()
    # @selected = false
    # @border_alpha = 0
    # @strength = 0
    # @info_alpha = 0
  end

  #decreases the player's health
  def ability_0 target
    target.health -= 10 + @strength
  end

  #decreases the player's strength
  def ability_1 target, deck
    target.strength -= 1
    if(target.strength < target.min_strength)
      target.strength = target.min_strength
    end
  end

  #Increases a monster's strength
  def ability_2 target
    target.strength += 1
  end

  #Attacks (see ability_0)
  def ability_3 target
    ability_0 target
  end
end

class Player
  attr_accessor :max_health, :health, :max_energy, :energy, :max_strength, :strength, :min_strength, :sprite, :player_render, :player_x, :player_y, :selected, :border_alpha
  def initialize
    @max_health = 30
    @health = @max_health
    @max_energy = 3
    @energy = @max_energy
    @max_strength = 0
    @min_strength = -3
    @strength = @max_strength
    @sprite = 'sprites/dragon-0.png'
    @player_x = 250
    @player_y = 400
    @width = 100
    @height = 100
    @player_render = [ @player_x, @player_y, @width, @height,  @sprite ]
    @selected = false
    @border_alpha = 0
  end

  def select
    if(!@selected)
      @selected = true
      $gtk.notify! "Player is selected"
      @border_alpha = 255
    elsif(@selected)
      deselect
    end
  end

  def deselect
    @selected = false
    @border_alpha = 0
  end

  def render args
    #Energy display
    args.outputs.labels << [ 25, 650, "Energy: #{@energy}/#{@max_energy}" ]
    args.outputs.labels << [ 25, 625, "Strength: #{@strength}" ]

    #Player display
    args.outputs.sprites << @player_render
    args.outputs.labels << [ @player_x, @player_y + 150, "Your Health: #{@health}/#{@max_health}" ]

    #Select Display
    args.outputs.borders << [@player_x - 10, @player_y - 10, @width + 20, @height + 20, 0, 255, 0, @border_alpha]

  end

  def inputs args
    if args.inputs.mouse.down
      if(args.inputs.mouse.click.point.inside_rect? @player_render)
        select
      end
    end
    if(args.mouse.point.inside_rect? @player_render)
      @border_alpha = 255
    else
      if(!@selected)
        @border_alpha = 0
      end
    end
  end

  def levelComplete
    #Health Boost
    @max_health += 5
    @health += 10
    if(@health > @max_health)
      @health = @max_health
    end

    #Strength Boost
    @max_strength += 1
    @strength = @max_strength

    @energy = @max_energy
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
  attr_accessor :hand, :level

  def initialize
    #alphabetized
    @deck = Deck.new
    @discard = Discard.new
    @enemiesOnScreen = EnemiesOnScreen.new
    @hand = Hand.new
    @player = Player.new
    @UI = UI.new
    @start_turn = true
    @level = 1
  end

  # this is the entry point for Game (which is the ~tick~ method).
  def tick args
    render args
    inputs args
    calc args
  end

  #Defaults
  def defaults args

  end

  #Renders everything on screen
  def render args
    @deck.render args
    @discard.render args
    @hand.render args
    @player.render args
    @enemiesOnScreen.render args
    @UI.render args
    args.outputs.labels << [450, 700, "Level: #{@level}"]

    #Temporary Draw Button in the top right-hand corner
    # draw = [1150, 650, 200, 100, 180, 0, 0, 360]
    # args.outputs.solids << draw
    # if args.inputs.mouse.click
    #   if args.inputs.mouse.click.point.inside_rect? draw
    #     if(!@deck.isEmpty)
    #       x = rand(@deck.cards.items.length)
    #       @hand.addCard(@deck.cards.items[x])
    #       @deck.cards.items.delete_at(x)
    #     end
    #   end
    # end
  end

  #Hadles mouse and keyboard inputs
  def inputs args
    @deck.inputs args
    @discard.inputs args
    @hand.inputs args
    @enemiesOnScreen.inputs args
    @player.inputs args
    @UI.inputs args
    # if(args.inputs.mouse.down)
    #   @enemiesOnScreen.enemies.items.each do |enemy|
    #     if((args.inputs.mouse.click.inside_rect? @player.player_render) && (enemy.selected))
    #       @enemiesOnScreen.enemies.items.each do |enemy|
    #         enemy.deselect
    #       end
    #     elsif((args.inputs.mouse.click.inside_rect? enemy.enemy_render) && (@player.selected))
    #       @player.deselect
    #       enemy.select
    #     end
    #   end
    # end
  end

  #Handles the logic of the game
  def calc args

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

    #Allows the user to play cards
    @hand.cards.items.each do |card|
      @enemiesOnScreen.enemies.items.each do |enemy|
        if(card.selected && (enemy.selected || @player.selected) && (@player.energy >= card.cost))
          case card.id

          when "base_attack"
            if(enemy.selected)
              card.action(enemy, @player)
              @player.energy -= card.cost
              card.deselect
              enemy.deselect
              @discard.addCard(card)
              @hand.cards.items.delete(card)
              enemy.deselect
              @player.deselect
            end

          when "base_heal"
            if(@player.selected)
              card.action(@player)
              @player.energy -= card.cost
              card.deselect
              enemy.deselect
              @discard.addCard(card)
              @hand.cards.items.delete(card)
              enemy.deselect
              @player.deselect
            end

          when "base_strength"
            if(@player.selected)
              card.action(@player)
              @player.energy -= card.cost
              card.deselect
              enemy.deselect
              @discard.addCard(card)
              @hand.cards.items.delete(card)
              enemy.deselect
              @player.deselect
            end

          when "dead_card"
            if(@player.selected)
              @player.energy -= card.cost
              card.deselect
              enemy.deselect
              @hand.cards.items.delete(card)
              enemy.deselect
              @player.deselect
            end

          when "base_draw"
            if(@player.selected)
              2.times do
                if(!@deck.isEmpty)
                  x = rand(@deck.cards.items.length)
                  card.action(@hand, @deck.cards.items[x])
                  @deck.cards.items.delete_at(x)
                else
                  reshuffle_deck
                  x = rand(@deck.cards.items.length)
                  card.action(@hand, @deck.cards.items[x])
                  @deck.cards.items.delete_at(x)
                end
              end
              @player.energy -= card.cost
              card.deselect
              enemy.deselect
              @discard.addCard(card)
              @hand.cards.items.delete(card)
              enemy.deselect
              @player.deselect
            end
          end
        end
      end
    end

    #Refills deck from Discard
    if(@deck.isEmpty)
      reshuffle_deck
    end

    #Determines and removes Enemies if they are killed
    @enemiesOnScreen.enemies.items.each do |enemy|
      if(enemy.health <= 0)
        @enemiesOnScreen.enemies.items.delete(enemy)
      end
    end

    #When the current enemies are all beaten
    if(@enemiesOnScreen.enemies.items.length == 0)
      levelComplete
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
        action_choice = rand(4)
        case action_choice

          #Ability 0 is always an attack
        when 0
          enemy.ability_0 @player

          #Ability 1 always target the player
        when 1
          enemy.ability_1 @player, @deck

          #Ability 2 always targets a friendly monster (including self)
        when 2
          enemy.ability_2 @enemiesOnScreen.enemies.items[rand(@enemiesOnScreen.enemies.items.length)]

          #Ability 3 is a special attack that not every monster will have (if they don't they just perform a different ability again)
        when 3
          enemy.ability_3 @player
        end
      end


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

  #If the player clears the current enemies on screen
  def levelComplete
    #Heals and increases health as well as strength
    @player.levelComplete

    #Removes cards from hand for reshuffling
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

    #reshuffles any cards in the discard pile back into the deck
    reshuffle_deck

    #Clears the dead cards out of the deck
    @deck.levelComplete

    #Draws 3 cards for the start of the level
    while(@hand.cards.items.length < 3)
      if(!@deck.isEmpty)
        x = rand(@deck.cards.items.length)
        @hand.addCard(@deck.cards.items[x])
        @deck.cards.items.delete_at(x)
      elsif(@deck.isEmpty)
        reshuffle_deck
      end
    end

    @level += 1
    if(@level%5 != 0)
      @enemiesOnScreen.enemies.items << RedBlob.new(750, 400)
      @enemiesOnScreen.enemies.items << GreenBlob.new(950, 400)
    else
      @enemiesOnScreen.enemies.items << KingBlob.new(850, 350)
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
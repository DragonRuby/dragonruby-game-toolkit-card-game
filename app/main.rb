#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PICKING BACK UP:
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Questions/ known issues:
#   Click card, click enemy, card is spent, then if I click on another card and then the same enemy I have to click on that enemy twice for any effect to occur
#   Click card, deselect it by right-clicking, I have to double-click it to reselect it
#   Cleaner way to have one slime target enemies and a different slime target friendlies in the same ability slot (ability 3) - solved I think
#   Pause the game loop? If enemies are cleared and I want to wait for player input before continuing. Sleep isn't quite what I want
#   Animations don't play?
#   Getting the enemies to do their actions separately and not at the same time
#   Newline character in the description
#   Dragging cards by clicking on the card then on the enemy only deselects the card instead of using the card (FIXED)
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TODO:
#   1. Fix the known issues
#   2a. Get heal cards working (Done)
#   2b. Allow targeting of player (Kinda Done)
#   2c. Prevent targeting of both player AND Enemy at the same time (Nonissue?)
#   3. Change positions of objects on screen
#       -Cards don't just move over after one is played
#   4. Change the Sprites
#     -Make the Sword on the card back bigger
#   5. Remove comments and clean up code
#     -Change order of card attr_accessor
#   6. Remove any deprecated methods
#   7. Change id system (either remove "base" or group similar card styles together i.e. energy and strength) (DONE)
#   8. Right-click to deselect (DONE)
#   9. Mousing over a card shows who it can target
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# EXTRAS:
#   Mousing over player, enemy, or card makes them bigger/ shows they are being hovered over (with a green border)? (Mostly DONE)
#   More enemies
#   More cards
#   Animations
#   Make things more streamlined (go through the RubyMine warnings)
#   Console Commands
#   Implement Armor
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BALANCING/ RECOMMENDED
# Formulaic boss?
#
# enemy scaling
# less clicking on self
#
# increase health gains as time goes on
# Increase enemy health and damage
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
URL = 'http://localhost:3000/'

##
# Prepend to a class to add serialization and deserialization
module Serialize
	##
	# If serial = true -> create the object by deserializing instance variables
	# Else -> create the object normally
	def initialize *args, serial: false, **kwargs
		if serial
			return deserialize(args[0])
		elsif args.size > 0
			if kwargs.size > 0
				return super(*args, **kwargs)
			end
			return super(*args)
		elsif kwargs.size > 0
			return super(**kwargs)
		end
		super()
	end

	# Recursively deserialize arbitrary objects
	def deserialize vars
		# Remove any current instance variables
		instance_variables.each { |e| remove_instance_variable(e) }
		# Loop through input and set to instance variables
		vars.each do |var, val|
			val.transform_keys!(&:to_sym)
			klass = Kernel.const_get(val[:class])
			# Recursively deserialize
			if [Array, Hash].include?(klass)
				val[:value].deserialize
			elsif klass.instance_methods.include?(:deserialize)
				val[:value] = klass.new(val[:value], serial: true)
			end
			instance_variable_set(var.to_sym, val[:value])
		end unless vars.nil?
	end

	# Recursively serialize arbitrary objects
	def serialize
		Hash[instance_variables.map do |var|
			val = instance_variable_get(var)
			klass = val.class.name
			# Recursively serialize
			val = val.serialize if val.respond_to?(:serialize)
			[var, { class: klass, value: val }]
		end]
	end

	def to_s
		serialize.to_s
	end
	alias :inspect :to_s
end

##
# Custom serialization and deserialization for Arrays and Hashes
# The work differently than most other objects so the generic approach doesn't work
##

class Array
	def deserialize
		map! do |val|
			val.transform_keys!(&:to_sym)
			klass = Kernel.const_get(val[:class])
			# Recursively deserialize
			if [Array, Hash].include?(klass)
				val[:value].deserialize
			elsif klass.instance_methods.include?(:deserialize)
				val[:value] = klass.new(val[:value], serial: true)
			end
			val[:value]
		end
	end
	
	def serialize
		map do |val|
			klass = val.class.name
			val = val.serialize if val.respond_to?(:serialize)
			{ class: klass, value: val }
		end
	end
end

class Hash
	def deserialize
		transform_values! do |val|
			val.transform_keys!(&:to_sym)
			klass = Kernel.const_get(val[:class])
			# Recursively deserialize
			if [Array, Hash].include?(klass)
				val[:value].deserialize
			elsif klass.instance_methods.include?(:deserialize)
				val[:value] = klass.new(val[:value], serial: true)
			end
			val[:value]
		end
	end

	def serialize
		transform_values do |val|
			klass = val.class.name
			val = val.serialize if val.respond_to?(:serialize)
			{ class: klass, value: val }
		end
	end
end

class Cards
	prepend Serialize
  attr_accessor :items, :selected_card_history
  def initialize(items) #array
    @items = items
    @selected_card_history = []
  end
end
class Card
  attr_accessor :title, :id, :description, :sprite, :cost
  attr_accessor :pos_x, :pos_y, :width, :height, :dx, :dy
  attr_accessor :on_screen, :selected, :info_alpha

  def initialize
    @pos_x, @pos_y,@width, @height, @dx, @dy = nil
    @on_screen, @selected = false
    @info_alpha = 0
  end
	alias :name :title
  def render
    [@pos_x, @pos_y, @width, @height, @sprite]
  end
  def setDisplay(x, y, w, h)
    @pos_x = x
    @pos_y = y
    @width = w
    @height = h
  end
  def select(args)
    if(!@selected)
      #@pos_y += 50
      @dx = args.inputs.mouse.x - @pos_x
      @dy = args.inputs.mouse.y - @pos_y
      @selected = true
    # elsif(@selected)
    #   @selected = false
    end
  end
  # def select mouse_x, mouse_y, card
  #   if(!@selected)
  #     @dx = mouse_x - @pos_x
  #     @dy = mouse_y - @pos_y
  #     card.setDisplay(@dx, @dy, @width, @height)
  #     #@pos_y += 50
  #     @selected = true
  #   elsif(@selected)
  #     @pos_y -= 50
  #     @selected = false
  #   end
  # end
  def deselect
    @selected = false
  end
end
class ArmorCard < Card
	prepend Serialize
  def initialize
    super()
    @title = "Armor"
    @id = "friendly"
    @description = "Gain 3 armor"
    @sprite = 'sprites/card-armor-base.png'
    @cost = 1
  end
  def action(player)
    player.armor += 3
  end
end
class AttackCard < Card
	prepend Serialize
  def initialize
    super()
    @title = "Attack"
    @id = "single_enemy"
    @description = "Deal 5 damage to an enemy"
    @sprite = 'sprites/card-attack-base.png'
    @cost = 1
    # @pos_x, @pos_y, @length, @height = nil
    # @on_screen, @selected = false
    # @info_alpha = 0
  end
  def action(target, player)
    target.health -= (5 + player.strength)
  end
end
class DeadCard < Card
	prepend Serialize
  def initialize
    super()
    @title = "Waste of Space"
    @id = "dead"
    @description = "Takes up space in the player's hand and deck"
    @sprite = 'sprites/card-dead.png'
    @cost = 1
    # @pos_x, @pos_y, @length, @height = nil
    # @on_screen, @selected = false
  end
end
class DrawCard < Card
	prepend Serialize
  attr_accessor :amount
  def initialize
    super()
    @title = "Draw 2"
    @id = "draw"
    @description = "Draws two cards from the deck"
    @sprite = 'sprites/card-draw-base.png'
    @cost = 2
    @amount = 2
    # @pos_x, @pos_y, @length, @height = nil
    # @on_screen, @selected = false
  end
  def action(target, card)
    target.addCard(card)
  end
end
class EnergyCard < Card
	prepend Serialize
  def initialize
    super()
    @title = "Energy"
    @id = "friendly"
    @description = "Gives you 1 energy for this turn only"
    @sprite = 'sprites/card-energy-base.png'
    @cost = 0
  end
  def action(target)
    target.energy += 1
  end
end
class HealCard < Card
	prepend Serialize
  def initialize
    super()
    @title = "Heal"
    @id = "friendly"
    @description = "Heal 5 HP"
    @sprite = 'sprites/card-heal-base.png'
    @cost = 1
  end
  def action(target)
    target.health += 5
    if(target.health > target.max_health)
      target.health = target.max_health
    end
  end
end
class StrengthCard < Card
	prepend Serialize
  def initialize
    super()
    @title = "Strength"
    @id = "friendly"
    @description = "Grants 2 strength to the target"
    @sprite = 'sprites/card-strength-base.png'
    @cost = 2
  end
  def action(target)
    target.strength += 2
  end
end

class Deck
	prepend Serialize
  attr_accessor :cards, :sprite, :deck_label_alpha, :deck_symbol

  def initialize
    @cards = Cards.new([AttackCard.new, AttackCard.new, AttackCard.new, AttackCard.new,
                        HealCard.new, HealCard.new, HealCard.new, HealCard.new,
                        StrengthCard.new, DrawCard.new, EnergyCard.new, EnergyCard.new])
    @sprite = 'sprites/card-back.png'
    @deck_label_alpha = 0
  end

  def addCard card
    @cards.items << card
  end

  def render args
    deck_x ||= 20
    deck_y ||= 40
    @deck_symbol = [ deck_x, deck_y, 64, 108, @sprite ]
    args.outputs.sprites << @deck_symbol

    deck_label = [ deck_x, deck_y + 150, "Cards in Deck: #{@cards.items.length}", 0, 0, 0, @deck_label_alpha ]
    @cards.items.each_with_index do |card, i|
      args.outputs.labels << [deck_x, (deck_y + 175) + (i * 25), "#{card.title}", 0, 0, 0, @deck_label_alpha]
    end
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
	prepend Serialize
  attr_accessor :cards, :sprite, :discard_label_alpha, :discard_symbol

  def initialize
    @cards = Cards.new([])
    @sprite = 'sprites/card-back.png'
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
    @discard_symbol = [ discard_x, discard_y, 64, 108, @sprite ]
    args.outputs.sprites << @discard_symbol

    discard_label = [ discard_x, discard_y + 150, "Discarded: #{@cards.items.length}", 0, 0, 0, @discard_label_alpha ]
    @cards.items.each_with_index do |card, i|
      args.outputs.labels << [discard_x, (discard_y + 175) + (i * 25), "#{card.name}", 0, 0, 0, @discard_label_alpha]
    end
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
	prepend Serialize
  attr_accessor :cards

  def initialize
    @cards = Cards.new([])
  end

  def render args
    @cards.items.each_with_index do |card, i|
      if(card.selected)
        card.setDisplay(args.inputs.mouse.x - card.dx, args.inputs.mouse.y - card.dy, card.width, card.height)
      else
        card.setDisplay(((i+1)*100)+250, 75, 64, 108)
      end
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
    # if args.inputs.mouse.down && (@cards.items.length > 0)
    #   found_card = @cards.items.find {|card| args.inputs.mouse.click.point.inside_rect? card.render}
    #   if(found_card)
    #     @cards.items.each(&:deselect)
    #     if(@cards.selected_card_history.last != found_card)
    #       found_card.select
    #       @cards.selected_card_history << found_card
    #     else
    #       @cards.selected_card_history = @cards.selected_card_history[0..-2]
    #     end
    #   end
    # end

    # if args.inputs.mouse.button_left && (@cards.items.length > 0) && args.inputs.mouse.click
    #   found_card = @cards.items.find {|card| args.inputs.mouse.click.point.inside_rect? card.render}
    #   if(found_card)
    #     @cards.items.each(&:deselect)
    #     if(@cards.selected_card_history.last != found_card)
    #       #found_card.select(args.inputs.mouse.x, args.inputs.mouse.y, found_card)
    #       found_card.select args
    #       @cards.selected_card_history << found_card
    #     else
    #       @cards.selected_card_history = @cards.selected_card_history[0..-2]
    #     end
    #   end
    # end
    if args.inputs.mouse.button_left && (@cards.items.length > 0) && args.inputs.mouse.click
      found_card = @cards.items.find {|card| args.inputs.mouse.click.point.inside_rect? card.render}
      if(found_card)
        #@cards.items.each(&:deselect)
        if(@cards.selected_card_history.last != found_card)
          #found_card.select(args.inputs.mouse.x, args.inputs.mouse.y, found_card)
          found_card.select args
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
      if(args.mouse.button_right && card.selected && args.inputs.mouse.click)
        card.deselect
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
	prepend Serialize
  attr_accessor :items, :selected_enemy_history
  def initialize items #array
    @items = items
    @selected_enemy_history = []
  end
end
class EnemiesOnScreen
	prepend Serialize
  attr_accessor :enemies

  def initialize
    @enemies = Enemies.new([RedBlob.new(750, 260), GreenBlob.new(950, 260)])
  end

  def inputs args
    # if args.inputs.mouse.down && (@enemies.items.length > 0)
    #   found_enemy = @enemies.items.find {|enemy| args.inputs.mouse.click.point.inside_rect? enemy.enemy_render}
    #   if(found_enemy)
    #     @enemies.items.each(&:deselect)
    #     if(@enemies.selected_enemy_history.last != found_enemy)
    #       found_enemy.select
    #       @enemies.selected_enemy_history << found_enemy
    #     else
    #       @enemies.selected_enemy_history = @enemies.selected_enemy_history[0..-2]
    #     end
    #   end
    # end

    if args.inputs.mouse.up && (@enemies.items.length > 0)
      found_enemy = @enemies.items.find {|enemy| args.inputs.mouse.up.point.inside_rect? enemy.enemy_render}
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
      args.outputs.labels << [ enemy.pos_x, enemy.pos_y + 150, "Enemy Health: #{enemy.health}/#{enemy.max_health}" ]
      args.outputs.borders << [enemy.pos_x - 10, enemy.pos_y - 10, enemy.width + 20, enemy.height + 20, 255, 0, 0, enemy.border_alpha]
      args.outputs.labels << [enemy.pos_x, enemy.pos_y - 30, "Enemy Strength: #{enemy.strength}", 0, 0, 0, enemy.info_alpha]
      if(enemy.move == true)
        enemy.animation
      end
    end
  end
end
class Enemy
  attr_accessor :name, :max_health, :health, :armor, :sprite, :number_of_actions, :pos_x, :pos_y, :width, :height, :selected, :border_alpha, :strength, :info_alpha, :move

  def initialize
    @selected = false
    @border_alpha = 0
    @strength = 0
    @info_alpha = 0
    move = false
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
      #$gtk.notify! "Enemy is selected"
      @border_alpha = 128
    elsif(@selected)
      @selected = false
    end
  end
  def deselect
    @selected = false
    @border_alpha = 0
  end
  def animation
    $gtk.notify! "Animated!"
    # while(@pos_x > (@pos_x - 50)) do
    #   @pos_x = @pos_x - 2
    # end
    25.times do
      @pos_x -= 2
    end
    25.times do
      @pos_x += 2
    end
  end
end
class GreenBlob < Enemy
	prepend Serialize
#Adds useless cards to the player's Deck and heals its allies
  def initialize x,y
    @name = "Green Blob"
    @max_health = 15
    @health = @max_health
    @armor = 0
    @sprite = 'sprites/square-green.png'
    @pos_x = x
    @pos_y = y
    @length = 100
    @height = 100
    super()
  end

  #@enemiesOnScreen.enemies.items[rand(@enemiesOnScreen.enemies.items.length)]
  #Green attack twice with the loop, figure out a better way to check health
  def turn player, deck, enemies
    enemies.each do |enemy|
      if(enemy.health != enemy.max_health)
        x = rand(3)
        case x
        when 0
          attack(player)
        when 1
          sap(player, deck)
        when 2
          heal(enemies[rand(enemies.length)])
        end
      else
        x = rand(3)
        case x
        when 0
          attack(player)
        when 1
          sap(player, deck)
        when 2
          attack(player)
        end
      end
    end


  end

  #decreases the player's health
  def attack player
    player.health -= 5 + @strength
  end

  #Adds useless card to deck
  def sap player, deck
    deck.addCard(DeadCard.new)
  end

  #Heals allies
  def heal enemy
    enemy.health += 3
    if(enemy.health > enemy.max_health)
      enemy.health = enemy.max_health
    end
  end
end
class KingBlob < Enemy
	prepend Serialize
  def initialize x,y
    @name = "King Blob"
    @max_health = 60
    @health = @max_health
    @armor = 0
    @sprite = 'sprites/square-yellow.png'
    @pos_x = x
    @pos_y = y
    @length = 300
    @height = 300
    @healed = false
    super()
  end

  #@enemiesOnScreen.enemies.items[rand(@enemiesOnScreen.enemies.items.length)]
  def turn player, deck, enemies
    if((@health <= @max_health / 2) && (!@healed))
      found = enemies.detect{|king| king.name == "King Blob"}
      buff(found) #Buffs the King Blob if its health has dropped below half and it hasn't already healed
      @healed = true
    else
      x = rand(3)
      case x
      when 0
        attack(player)
      when 1
        attack(player)
      when 2
        sap(player, deck)
      end
    end
  end

  #decreases the player's health
  def attack target
    target.health -= 15 + @strength
  end

  #decreases the player's strength
  def sap target, deck
    target.strength -= 2
    if(target.strength < target.min_strength)
      target.strength = target.min_strength
    end
    deck.addCard(DeadCard.new)
    deck.addCard(DeadCard.new)
  end

  #Increases a monster's strength
  def buff target
    target.health += 20
    target.strength += 5
  end
end
class RedBlob < Enemy
	prepend Serialize
  def initialize x,y
    @name = "Red Blob"
    @max_health = 20
    @health = @max_health
    @armor = 0
    @sprite = 'sprites/square-red.png'
    @pos_x = x
    @pos_y = y
    @length = 100
    @height = 100
    super()
  end

  #enemies == @enemiesOnScreen.enemies.items
  def turn player, deck, enemies
    x = rand(3)
    case x
    when 0
      attack(player)
    when 1
      weaken(player, deck)
    when 2
      buff(enemies[rand(enemies.length)])
    end
  end

  #decreases the player's health
  def attack target
    target.health -= 7 + @strength
  end

  #decreases the player's strength
  def weaken target, deck
    target.strength -= 1
    if(target.strength < target.min_strength)
      target.strength = target.min_strength
    end
  end

  #Increases a monster's strength
  def buff target
    target.strength += 2
  end
end

class Player
	prepend Serialize
  attr_accessor :max_health, :health, :max_energy, :energy, :max_strength, :strength, :min_strength, :sprite, :player_render, :player_x, :player_y, :selected, :border_alpha, :armor
  def initialize
    @max_health = 30
    @health = @max_health
    @max_energy = 3
    @energy = @max_energy
    @max_strength = 0
    @min_strength = -4
    @strength = @max_strength
    @sprite = 'sprites/knight-0.png'
    @player_x = 250
    @player_y = 260
    @width = 100
    @height = 100
    @player_render = [ @player_x, @player_y, @width, @height,  @sprite ]
    @selected = false
    @border_alpha = 0
    @armor = 0
  end

  def select
    if(!@selected)
      @selected = true
      #$gtk.notify! "Player is selected"
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
    if args.inputs.mouse.up
      if(args.inputs.mouse.up.point.inside_rect? @player_render)
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
	prepend Serialize
  attr_accessor :end_turn_button, :end_turn_label, :end_turn, :play_area, :play

  def initialize
    #@end_turn_button = [400, 15, 300, 50, 0, 0, 255, 255]
    @end_turn_button = [400, 15, 300, 50, "sprites/square-blue.png"]
    @play_area = [245, 260, 500, 300, 0, 0, 0, 64]
    @end_turn_label = [500, 45, "End Turn"]
    @end_turn = false
    @play = false
  end

  def render args
    #args.outputs.solids << @end_turn_button
    args.outputs.sprites << @end_turn_button
    args.outputs.borders << @play_area
    args.outputs.labels << @end_turn_label
  end

  def inputs args
    if args.inputs.mouse.click
      if args.inputs.mouse.click.point.inside_rect? @end_turn_button
        @end_turn = true
      end
    end
    if(args.inputs.mouse.up)
      if(args.inputs.mouse.up.point.inside_rect? @play_area)
        if(@play)
          @play = false
        else
          @play = true
        end
      end
    end
  end

  def played
    @play = false
  end

end

class Game
	prepend Serialize
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
		state_download
		state_upload
  end

  #Defaults
  def defaults args

  end

  #Renders everything on screen
  def render args
    args.outputs.sprites << [0, 0, 1300, 750, "sprites/backgroundColorGrass.png"]
    @deck.render args
    @discard.render args
    @hand.render args
    @hand.debug_hand args
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

		if args.inputs.keyboard.key_down.i
			# Import state
			$gtk.args.state.state_download = $gtk.http_get(URL + 'state')
		end

		if args.inputs.keyboard.key_down.o
			# Export state
			$gtk.args.state.state_upload = $gtk.http_post(URL + 'state', { data: $gtk.serialize_state($game.serialize) }, ['Content-Type: application/x-www-form-urlencoded'])
		end
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
      if(@hand.cards.items.length < 4)
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
        if(card.selected && (enemy.selected || @player.selected || @UI.play) && (@player.energy >= card.cost))
          case card.id

          when "single_enemy"
            if(enemy.selected)
              card.action(enemy, @player)
              @player.energy -= card.cost
              card.deselect
              enemy.deselect
              @discard.addCard(card)
              @hand.cards.items.delete(card)
              enemy.deselect
              @player.deselect
              @UI.played
            end

          when "friendly"
            if(@player.selected || @UI.play)
              card.action(@player)
              @player.energy -= card.cost
              card.deselect
              enemy.deselect
              @discard.addCard(card)
              @hand.cards.items.delete(card)
              enemy.deselect
              @player.deselect
              @UI.played
            end

          when "draw"
            if(@player.selected || @UI.play)
              card.amount.times do
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
              @UI.played
            end

          when "dead"
            if(@player.selected || @UI.play)
              @player.energy -= card.cost
              card.deselect
              enemy.deselect
              @hand.cards.items.delete(card)
              enemy.deselect
              @player.deselect
              @UI.played
            end

          # when "base_attack"
          #   if(enemy.selected)
          #     card.action(enemy, @player)
          #     @player.energy -= card.cost
          #     card.deselect
          #     enemy.deselect
          #     @discard.addCard(card)
          #     @hand.cards.items.delete(card)
          #     enemy.deselect
          #     @player.deselect
          #   end
          #
          # when "base_heal"
          #   if(@player.selected || @UI.play)
          #     card.action(@player)
          #     @player.energy -= card.cost
          #     card.deselect
          #     enemy.deselect
          #     @discard.addCard(card)
          #     @hand.cards.items.delete(card)
          #     enemy.deselect
          #     @player.deselect
          #     @UI.played
          #   end
          #
          # when "base_strength"
          #   if(@player.selected || @UI.play)
          #     card.action(@player)
          #     @player.energy -= card.cost
          #     card.deselect
          #     enemy.deselect
          #     @discard.addCard(card)
          #     @hand.cards.items.delete(card)
          #     enemy.deselect
          #     @player.deselect
          #     @UI.played
          #   end
          #
          # when "dead_card"
          #   if(@player.selected || @UI.play)
          #     @player.energy -= card.cost
          #     card.deselect
          #     enemy.deselect
          #     @hand.cards.items.delete(card)
          #     enemy.deselect
          #     @player.deselect
          #     @UI.played
          #   end
          #
          # when "base_draw"
          #   if(@player.selected || @UI.play)
          #     2.times do
          #       if(!@deck.isEmpty)
          #         x = rand(@deck.cards.items.length)
          #         card.action(@hand, @deck.cards.items[x])
          #         @deck.cards.items.delete_at(x)
          #       else
          #         reshuffle_deck
          #         x = rand(@deck.cards.items.length)
          #         card.action(@hand, @deck.cards.items[x])
          #         @deck.cards.items.delete_at(x)
          #       end
          #     end
          #     @player.energy -= card.cost
          #     card.deselect
          #     enemy.deselect
          #     @discard.addCard(card)
          #     @hand.cards.items.delete(card)
          #     enemy.deselect
          #     @player.deselect
          #     @UI.played
          #   end
          #
          # when "base_energy"
          #   if(@player.selected || @UI.play)
          #     card.action(@player)
          #     @player.energy -= card.cost
          #     card.deselect
          #     enemy.deselect
          #     @discard.addCard(card)
          #     @hand.cards.items.delete(card)
          #     enemy.deselect
          #     @player.deselect
          #     @UI.played
          #   end
          #
          # when "base_armor"
          #   if(@player.selected || @UI.play)
          #     card.action(@player)
          #     @player.energy -= card.cost
          #     card.deselect
          #     enemy.deselect
          #     @discard.addCard(card)
          #     @hand.cards.items.delete(card)
          #     enemy.deselect
          #     @player.deselect
          #     @UI.played
          #   end
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
        #enemy.move = true
        #enemy.animation
        #Performs the enemies action(s). The three parameters are what might be influenced by the attacks
        enemy.turn @player, @deck, @enemiesOnScreen.enemies.items
        #sleep(3)
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
    while(@hand.cards.items.length < 4)
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
      @enemiesOnScreen.enemies.items << RedBlob.new(750, 260)
      @enemiesOnScreen.enemies.items << GreenBlob.new(950, 260)
    else
      @enemiesOnScreen.enemies.items << KingBlob.new(850, 260)
    end
  end

	def state_download
		download = $gtk.args.state.state_download
		return if download.nil?

		if download[:complete]
			if download[:http_response_code] == 200
				new_state = $gtk.deserialize_state(download[:response_data])
				$game.deserialize(new_state)
			else
				puts "ERROR downloading state. Response code: #{download[:http_response_code]}"
			end
			$gtk.args.state.state_download = nil
		end
	end

	def state_upload
		upload = $gtk.args.state.state_upload
		return if upload.nil?

		if upload[:complete]
			if upload[:http_response_code] == 204
				puts "Successfully uploaded state."
			else
				puts "ERROR uploading state. Response code: #{upload[:http_response_code]}"
			end
			$gtk.args.state.state_upload = nil
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

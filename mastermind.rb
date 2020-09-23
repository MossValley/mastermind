#frozen_string_literal: true
require 'pry'

module Colors
  def colorize(number, peg)
    colors_array = [31, 32, 33, 34, 35, 36, 30, 37] 
    #colors respond to red, green, yellow, blue, pink, light_blue, black (correct color+place), grey (correct color) respectively
    result = "\e[#{colors_array[number]}m#{peg}\e[0m" #turns the peg into the particular color responding to the color code
    return result
  end
end


class Computer
  include Colors
  attr_accessor :peg, :code_array

  def initialize
    @peg = "O"
    @code_array = (0...4).to_a
    generate_code
  end

  def check_guess(player_guess)
    @guesses_remaining = player_guess.clone
    return guess_checker(@guesses_remaining)
  end

  def show_answer
    puts @code_array.join(' - ')
  end

  private

  def generate_code
    @code_array.each do |slot|
      @code_array[slot] = color_randomizer
    end
  end

  def color_randomizer
    random_number = Random.new.rand(0...6)
    return colorize(random_number, @peg)
  end

  def guess_checker(guesses_remaining)
    hint = []
    @unsolved = @code_array.clone
    guesses_remaining.each_index { |p_index| hint.push(correct_guesses(guesses_remaining[p_index], p_index)).delete(0) }
    unless @unsolved.length == 0
      guesses_remaining.each_index { |p_index| hint.push(incorrect_guesses(guesses_remaining[p_index], p_index)) }
    end
    # binding.pry
    return hint

  end

  def correct_guesses(p_slot, p_index)
    if @code_array[p_index] == p_slot
      @unsolved.delete_at(p_index)
      @guesses_remaining.delete_at(p_index)
      return colorize(6, "")                       # correct color + place
    else
      return 0
    end
  end

  def incorrect_guesses(p_slot, p_index)
    if @unsolved.any? { |c_slot| c_slot == p_slot } #correct color: wrong place
      @unsolved.delete_at(@unsolved.index(p_slot))
      return colorize(7, "")
    else
      return "x"                                    #incorrect color
    end
  end
end

class Player
  include Colors
  attr_accessor :guess_array
  attr_reader :peg, :slots_to_guess, :color_hash

  def initialize
    @peg = 'O'
    @guess_array = (1..4).to_a
    @guess_array.each { |slot| @guess_array[slot-1] = @peg }
    @color_hash = {
      ['red', 'r'] => 0,
      ['green', 'g']=> 1,
      ['yellow', 'y'] => 2,
      ['blue', 'b'] => 3,
      ['pink', 'p'] => 4,
      ['light blue', 'l'] => 5
    }
  end

  def guess_the_code
    guess_code
  end

  private 

  def color_options #to display the colors available as colored text
    options = []
    @color_hash.each do |color, key|
      if color == @color_hash.keys[-1]
        options.push("or #{colorize(key, color[0])}")
      else
        options.push("#{colorize(key, color[0])}, ")
      end
    end
    return options
  end

  def guess_code
    colors = color_options()
    print "Chose 4 colors. No spaces. Options: #{colors.join('')}. | "
    input_checker
    puts @guess_array.join(' - ')
    return @guess_array
  end

  def input_checker
    input_array = gets.chomp.split('')
    input_array.each_index do |slot|
      unless @color_hash.any? { |color, number| color.any? { |i| i == input_array[slot]}}
        print "Incorrect input. Try again. | "
        input_array = gets.chomp.split('')
      end
      update_guess_array(slot, color_choice(input_array[slot]))
    end
  end

  def update_guess_array(slot, color_choice)
    @guess_array[slot] = colorize(@color_hash[color_choice], @peg)
  end

  def color_choice(input_slot)
    @color_hash.filter_map { |color, number| color if color.any? { |i| i == input_slot} }.flatten
  end
end

class Game
  include Colors 

  def self.init_game  
    @comp = Computer.new
    @player = Player.new
    @rounds_taken = 0
    play_game
  end

  def self.play_game
    player_guess = @player.guess_the_code
    hint = @comp.check_guess(player_guess)
    puts hint.join('-')
    win_check(hint)
  end

  def self.win_check(hint)
    if @rounds_taken > 12
      puts "Game over"
      show_answer
    elsif hint.all? { |a| a == "\e[30m\e[0m"}
      puts "You win! It took you #{@rounds_taken} rounds!"
      print "Play again? Y/N: "
      replay = gets.chomp.to_s.downcase
      if replay == 'y' then init_game end
    else 
      @rounds_taken ++
      print "R: #{@rounds_taken}"
      play_game
    end
  end

  def self.show_answer
    @comp.show_answer
  end

end

Game.init_game

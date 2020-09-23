#frozen_string_literal: true
require 'pry'

module Colors
  def colorize(number, peg)
    colors_array = [31, 32, 33, 34, 35, 36, 30, 37] #colors respond to red, green, yellow, blue, pink, light_blue, black outline, grey outline respectively
    result = "\e[#{colors_array[number]}m#{peg}\e[0m" #turns the peg into the particular color responding to the color code
    return result
  end
end


class Computer
  include Colors
  attr_accessor :peg, :code_array

  def initialize
    @peg = "O"
    @code_array = (1..4).to_a
    generate_code
  end

  def check_guess(player_guess)
    return guess_checker(player_guess)
  end

  def show_answer
    puts @code_array.join(' - ')
  end

  private

  def generate_code
    @code_array.each do |slot|
      @code_array[slot-1] = color_randomizer
    end
  end

  def color_randomizer
    random_number = Random.new.rand(0...6)
    return colorize(random_number, @peg)
  end

  def guess_checker(player_guess)
    hint = []
    @unsolved = @code_array.clone
    player_guess.each_index do |p_index|
      hint.push(code_checker(player_guess[p_index], p_index))
    end
    return hint.sort
  end

  def code_checker(p_slot, p_index)
    if @code_array[p_index] == p_slot
      @unsolved.delete_at(p_index)
      return colorize(6, "")
    elsif @unsolved.any? { |c_slot| c_slot == p_slot }
      @unsolved.delete_at(@unsolved.index(p_slot))
      return colorize(7, "")
    else
      return "x"
    end
    binding.pry
  end
end

class Player
  include Colors
  attr_accessor :guess_array
  attr_reader :peg, :slots_to_guess, :color_hash

  def initialize
    @peg = 'O'
    @slots_to_guess = (1..4).to_a
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

  def color_options
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
    @slots_to_guess.each do |slot|
      puts @guess_array.join(' - ')
      print "Slot #{slot} color? Options: #{colors.join('')}. | "
      color_choice = input_checker
      update_guess_array(slot, color_choice)
    end 
    return @guess_array
  end

  def update_guess_array(slot, color_choice)
    @guess_array[slot-1] = colorize(@color_hash[color_choice], @peg)
  end

  def input_checker
    input = gets.chomp.to_s
    unless @color_hash.any? { |color, number| color.any? { |i| i == input}}
      puts "Incorrect input. Try again"
      input = gets.chomp.to_s
    end
    return @color_hash.filter_map { |color, number| 
            color if color.any? { |i| i == input} }.flatten
  end
end

class Game
  include Colors 

  def self.init_game  
    @comp = Computer.new
    @player = Player.new
    play_game
  end

  def self.play_game
    guess = @player.guess_the_code
    hint = @comp.check_guess(guess)
    puts hint.join('-')
    win_check(hint)
  end

  def self.win_check(hint)
    if hint.all? { |a| a == "\e[30m\e[0m"}
      puts "You win!"
      print "Play again? Y/N: "
      replay = gets.chomp.to_s.downcase
      if replay == 'y' then init_game end
    else 
      answer_check
      play_game
    end
  end

  def self.answer_check
    print "Show answer? Y/N: "
    response = gets.chomp.to_s.downcase
    if response == 'y' then @comp.show_answer end
  end

end

Game.init_game

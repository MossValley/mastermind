#frozen_string_literal: true
require 'pry'

module Colors
  def colorize(number, peg)
    colors_array = [31, 32, 33, 34, 35, 36, 30, 37] 
    #colors respond to red, green, yellow, blue, pink, light_blue, black (correct color+place), grey (correct color) respectively
    result = "\e[#{colors_array[number]}m#{peg}\e[0m" #turns the peg into the particular color responding to the color code
    return result
  end

  def color_randomizer
    random_number = Random.new.rand(0...6)
    return colorize(random_number, @peg)
  end
end

class Codemaker
  include Colors
  attr_accessor :peg, :code_array

  def initialize
    @peg = "O"
    @code_array = (0...4).to_a
    generate_code
  end

  def check_guess(codebreaker_guess)
    guesses_remaining = codebreaker_guess.clone
    return guess_checker(guesses_remaining)
  end

  def show_answer
    puts "Answer: #{@code_array.join(' - ')}"
  end

  private

  def generate_code
    @code_array.each do |slot|
      @code_array[slot] = color_randomizer
    end
  end

  def guess_checker(guesses_remaining)
    hint = []
    @unsolved = @code_array.clone
    guesses_remaining.each_index { |g_index| hint.push(correct_guesses(guesses_remaining[g_index], g_index)) }
    return hint.sort
  end

  def correct_guesses(g_slot, g_index)
    if @unsolved[g_index] == g_slot
      @unsolved[g_index] = "zero"
      return colorize(6, "")                        # correct color + place
    elsif @unsolved.any? { |u_slot| u_slot == g_slot } 
      @unsolved[@unsolved.index(g_slot)] = "zero"
      return colorize(7, "")                       #correct color: wrong place
    else
      return "x"                                    #incorrect color
    end
  end
end

class Codebreaker
  include Colors
  attr_accessor :guess_array
  attr_reader :peg, :slots_to_guess, :color_hash

  def initialize
    @peg = 'O'
    @guess_array = (1..4).to_a
    @guess_array.each_index { |slot| @guess_array[slot] = @peg }
    @color_hash = {
      ['red', 'r'] => 0,
      ['green', 'g']=> 1,
      ['yellow', 'y'] => 2,
      ['blue', 'b'] => 3,
      ['pink', 'p'] => 4,
      ['light blue', 'l'] => 5
    }
    @color_array = [0, 1, 2, 3, 4, 5] # r, g, y, b, p, l respectively
    @possible_combintation = color_combinations
  end

  def guess_the_code(player, hints_to_give)
    @hints_to_give = hints_to_give
    case player
    when true
      guess_code_player
    when false
      guess_code_computer
    end
  end

  private 

  # --- code for when the player is the codebreaker ---
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

  def guess_code_player
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

  # --- code for when the computer is the codebreaker ---

  def guess_code_computer
    @hints_to_give.each do |hint_slot|
      puts hint_slot
      if hint_slot == 'x'
        @guess_array.each_index { |slot| @guess_array[slot] = color_randomizer }
      end
    end 
  end

  def color_combinations
    start = ['1', '1', '1', '1']
    combination_array = []
    while numberize(start) <= 6666
      print "#{start} \n"
      combination_array.push(start)
      start = arrayize((numberize(start) + 1))
      start = max_number(start)
    end
    return combination_array.length
  end

  def max_number(array)
    range = [3, 2, 1]
    for i in range do
      if array[i] == '7'
        array[i-1] = add_one(array, i-1)
        array[i] = '1'
      end
    end
    return array
  end

  def add_one(array, i)
    return (array[i].to_i + 1).to_s
  end

  def numberize(array)
    return array.join('').to_i
  end

  def arrayize(number)
    return number.to_s.split('')
  end
end

class Game
  include Colors 

  def self.init_game(player_is_codebreaker)
    @player_is_codebreaker = player_is_codebreaker
    @codemaster = Codemaker.new
    @codebreaker = Codebreaker.new
    @rounds_taken = 1
    @hints_to_give = (0...4).to_a
    @hints_to_give.each_index { |i| @hints_to_give[i] = 'x'}
    start_game
  end

  def self.start_game
    play_round
  end

  def self.play_round
    while @rounds_taken < 13
      hints_given = play_game
      winner = win_check(hints_given)
      if winner == true then return end
    end
    puts "Game over"
    show_answer
  end
    
  private 

  def self.play_game
    codebreaker_guess = @codebreaker.guess_the_code(@player_is_codebreaker, @hints_to_give)
    @hints_to_give = @codemaster.check_guess(codebreaker_guess)
    print "#{@hints_to_give.join('-')}  ~ Turns: #{@rounds_taken} \n"
    return @hints_to_give
  end

  def self.win_check(hints_given)
    unless hints_given.all? { |a| a == "\e[30m\e[0m"}
      @rounds_taken += 1
      return false
    end
    puts "You win! It took you #{@rounds_taken} rounds!"
    return true
  end

  def self.show_answer
    @codemaster.show_answer
  end
end

class Start_program
  def self.initialize
    choose_game
  end
  def self.choose_game
    play = 'y'
    while play == 'y'
      puts "Do you want to:\n1) be the codemaker? \n2) be the codebreaker? "
      codebreaker = gets.chomp.to_s
      case codebreaker
      when "1"
        Game.init_game(false)
      when "2"
        Game.init_game(true)
      else
        puts "Incorrect choice. Please try again"
      end
      print "Play again? Y/N: "
      play = gets.chomp.to_s.downcase
    end
  end
end

Start_program.initialize

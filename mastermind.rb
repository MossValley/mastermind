#frozen_string_literal: true

module Colors
  def colorize(number, peg)
    colors_array = [31, 32, 33, 34, 35, 36, 30, 37] 
    #colors respond to red, green, yellow, blue, pink, light_blue, black (correct color+place), grey (correct color) respectively
    result = "\e[#{colors_array[number]}m#{peg}\e[0m" #turns the peg into the particular color responding to the color code
    return result
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

  def check_guess(player_guess)
    guesses_remaining = player_guess.clone
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

  def color_randomizer
    random_number = Random.new.rand(0...6)
    return colorize(random_number, @peg)
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

  def self.init_game(player_is_codebreaker)
    @player_codebreaker = player_is_codebreaker
    @codemaster = Codemaker.new
    @codebreaker = Codebreaker.new
    @rounds_taken = 1
    play_round
  end

  def self.start_game
    if @player_codebreaker
      play_round
    else
      #code
    end
  end

  def self.play_round
    while @rounds_taken < 13
      hint = play_game
      winner = win_check(hint)
      if winner == true then return end
    end
    puts "Game over"
    show_answer
  end

  private 

  def self.play_game
    player_guess = @codebreaker.guess_the_code
    hint = @codemaster.check_guess(player_guess)
    print "#{hint.join('-')}  ~ Turns: #{@rounds_taken} \n"
    return hint
  end

  def self.win_check(hint)
    unless hint.all? { |a| a == "\e[30m\e[0m"}
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

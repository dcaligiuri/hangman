
class Hangman
  attr_reader :guesser, :referee, :board, :length, :secret_length, :checked_arr_letters, :your_guess, :guess_comma_matches, :dictionary, :my_matches, :my_guess
  attr_writer :board, :dictionary, :your_guess, :checked_arr_letters, :guess_comma_matches, :my_guess, :my_matches
  
  def initialize(players)
    @guesser = players[:guesser]
    @referee = players[:referee]
  end
  
  def play 
      while @board.count {|element| element == nil } > 0 
        take_turn
      end 
  end 
  
  
  def take_turn
      @my_guess = guesser.guess(current_board)
      @my_matches = referee.check_guess(my_guess)
      guesser.handle_response(my_guess, my_matches)
      update_board(current_board)
      print_board
  end 
  
  def current_board
    @board
  end 
  

  def print_board
    printed_board = []
    @board.each do |letter|
        if letter == nil
            letter = "_"
        end 
        printed_board << letter
    end 
    puts printed_board.join("")
  end 
  
    def update_board(board)
      display_board = []
      @board.each_with_index do |element, index|
          if @my_matches.include?(index)
              element = @my_guess
          end 
          display_board << element 
      end 
      @board = display_board
    end
    
    
  def setup
    secret_length = @referee.pick_secret_word
    @guesser.register_secret_length(secret_length)
    @board = [nil] * secret_length
  end
  
 
end 

class ComputerPlayer
    
    attr_accessor :dictionary, :board, :secret_length, :secret_word, :dictionary
    
    def initialize(dictionary)
        if dictionary == [] 
            File.readlines('dictionary.txt').each do |line|
                dictionary << line.chomp
            end 
        end 
            @dictionary = dictionary 
    end 
    
    def candidate_words
        @dictionary.delete_if { |word| word.length != secret_length }
    end
    
    def pick_secret_word 
        @secret_word = @dictionary.sample.chomp
        @secret_word.length
    end
  
    
    def secret_word 
        @secret_word
    end 
    
    def register_secret_length(length)
        @secret_length = length 
    end 
    
    def secret_length
        @secret_length
    end 

    
    def check_guess(letter)
        letter_arr = @secret_word.split("")
        arr_match = []
        letter_arr.each_with_index do |x, i|
            if letter == x
                arr_match << i
            end
        end
        arr_match
    end
    
    
    def guess(board)
        counting_hash = { } 
        for word in 0...candidate_words.length 
           for letters in 0...candidate_words[word].length 
               count = 1 
               if counting_hash.include?(candidate_words[word][letters])
                    count = count + counting_hash[candidate_words[word][letters]]
               end 
              counting_hash[candidate_words[word][letters]] = count 
           end 
        end 
        board.each {|letter| counting_hash.delete(letter) if counting_hash.include?(letter) }
        counting_hash.key(counting_hash.values.max)
    end 
    

    def handle_response(guess, matches)
        @dictionary.delete_if { |word| word.length != secret_length }
        @dictionary.delete_if do |word|
            letter_arr = word.split("")
            in_word_matches = []
            letter_arr.each_with_index do |letter, index|
                if guess == letter 
                    in_word_matches << index
                end 
            end
            in_word_matches != matches 
        end
        return guess, matches 
    end 
    
    
end


class HumanPlayer
	attr_accessor :dictionary, :board, :secret_length, :secret_word, :dictionary
	
    def initialize(dictionary)
        if dictionary == [] 
            File.readlines('dictionary.txt').each do |line|
                dictionary << line.chomp
            end 
        end 
            @dictionary = dictionary 
    end 
    
    
    def guess(board)
    	puts "The length of the word is #{@secret_length}"
    	puts "Guess a letter"
    	gets.chomp
    end
    
    def register_secret_length(length)
        @secret_length = length 
    end 
    
    def secret_length
     	@secret_length
    end 
    
    def pick_secret_word
        puts "Enter the length of your word!"
        @secret_length = gets.chomp.to_i
        
    end 
    
    
    def check_guess(letter)
        puts "The computer guessed the letter #{letter}"
        puts "Enter the indices where the letter is present, separated by a comma."
        puts "If the letter isn't present, enter []"
        arr_match = gets.chomp
        if arr_match == "[]"
        	arr_match = []
        else 
        	arr_match.split(",").map {|element| element.to_i}
        end 
    end

    
    def handle_response(guess, matches)
        @dictionary.delete_if { |word| word.length != secret_length }
        @dictionary.delete_if do |word|
            letter_arr = word.split("")
            in_word_matches = []
            letter_arr.each_with_index do |letter, index|
                if guess == letter 
                    in_word_matches << index
                end 
            end
            in_word_matches != matches 
        end
        return guess, matches 
    end 
    
    
    def candidate_words
        @dictionary 
    end 
    
    
end


if $PROGRAM_NAME == __FILE__
  puts "Do you want to be the guesser or the referee?"
  puts "Type 'g' for guesser, or 'r' for referee"
  player_response = gets.chomp
  human = HumanPlayer.new([])
  computer = ComputerPlayer.new([])
  if player_response == "g"
    players = {:referee => computer, :guesser => human }
  elsif player_response == "r"
    players = {:referee => human, :guesser => computer }
  end 
  game = Hangman.new(players)
  game.setup
  game.play
end



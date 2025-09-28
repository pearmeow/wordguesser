require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  set :host_authorization, { permitted_hosts: [] }

  before do
    @game = session[:game] || WordGuesserGame.new('')
  end

  after do
    session[:game] = @game
  end

  # These two routes are good examples of Sinatra syntax
  # to help you with the rest of the assignment
  get '/' do
    redirect '/new'
  end

  get '/new' do
    erb :new
  end

  post '/create' do
    # NOTE: don't change next line - it's needed by autograder!
    word = params[:word] || WordGuesserGame.get_random_word
    # NOTE: don't change previous line - it's needed by autograder!

    @game = WordGuesserGame.new(word)
    redirect '/show'
  end

  # Use existing methods in WordGuesserGame to process a guess.
  # If a guess is repeated, set flash[:message] to "You have already used that letter."
  # If a guess is invalid, set flash[:message] to "Invalid guess."
  post '/guess' do
    begin
      (flash[:message] = 'You have already used that letter.') unless @game.guess(params[:guess].to_s[0])
    rescue ArgumentError
      flash[:message] = 'Invalid guess.'
    end
    redirect '/show'
  end

  # Everytime a guess is made, we should eventually end up at this route.
  # Use existing methods in WordGuesserGame to check if player has
  # won, lost, or neither, and take the appropriate action.
  # Notice that the show.erb template expects to use the instance variables
  # wrong_guesses and word_with_guesses from @game.
  get '/show' do
    redirect '/win' if @game.check_win_or_lose == :win
    redirect '/lose' if @game.check_win_or_lose == :lose

    erb :show # You may change/remove this line
  end

  get '/win' do
    redirect '/show' if @game.check_win_or_lose == :play
    redirect '/lose' if @game.check_win_or_lose == :lose

    return erb :win
  end

  get '/lose' do
    redirect '/show' if @game.check_win_or_lose == :play
    redirect '/win' if @game.check_win_or_lose == :win

    return erb :lose
  end
end

class WordGuesserGame
  attr_accessor :word, :guesses, :wrong_guesses

  def initialize(word)
    self.word = word
    self.guesses = ''
    self.wrong_guesses = ''
  end

  def guess(letter)
    raise ArgumentError if letter.nil?
    raise ArgumentError unless letter.length == 1
    raise ArgumentError unless /[A-Za-z]/.match?(letter)

    letter.downcase!
    if word.include?(letter)
      return false if guesses.include?(letter)

      return self.guesses += letter
    end
    return false if wrong_guesses.include?(letter)

    self.wrong_guesses += letter
  end

  def word_with_guesses
    word.each_char.reduce('') do |memo, letter|
      if guesses.include?(letter)
        "#{memo}#{letter}"
      else
        "#{memo}-"
      end
    end
  end

  def check_win_or_lose
    return :lose if wrong_guesses.length >= 7
    return :win if word == word_with_guesses

    :play
  end
end

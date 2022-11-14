require 'open-uri'
require 'json'

class ApplicationController < ActionController::Base
  # skip_before_action :verify_authenticity_token

  def new
    grid_size = 10
    letters = ('A'..'Z').to_a + %w[A E I O U Y] * 2
    @letters = grid_size.times.map { letters.sample }
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    @answer = params[:answer]
    @letters = params[:letters].split
    @start_time = DateTime.parse(params[:start_time])
    dont_exist = check_in_grid(@answer, @letters)
    not_english = check_english(@answer)
    @ellapsed_time = (end_time - @start_time).to_f.round(10)
    message_score = message_score(dont_exist, not_english, @answer, @ellapsed_time)
    @message = message_score[:message]
    @score = message_score[:score]
  end

  def check_in_grid(attempt, grid)
    grid = grid.join
    dont_exist = []
    attempt.upcase.chars { |char| grid.include?(char) ? grid.sub!(char, '') : dont_exist << char }
    dont_exist
  end

  def check_english(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    user_serialized = URI.open(url).read
    user = JSON.parse(user_serialized)
    user['found'] != true
  end

  def message_score(dont_exist, not_english, attempt, ellapsed_time)
    score = 0
    if dont_exist.length.positive?
      message = ['Sorry but ', @answer.upcase, " can\'t be built out of #{@letters.join(',')}"]
    elsif not_english
      message = ['Sorry but ', @answer.upcase, ' does not seem to be a valid English word...']
    else
      score = (20 / (ellapsed_time * 1 / attempt.length)).round
      message = if score > 50
                  ['Congratulations! ', @answer.upcase, ' is a valid English word']
                else
                  ['Congratulations! ', @answer.upcase, ' is a valid English word. BUT I\'m sure you can do better...']
                end
    end
    { score:, message: }
  end
end

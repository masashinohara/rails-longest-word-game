require 'json'
require 'open-uri'

class GamesController < ApplicationController
  LETTERS = []
  POINT = 0

  def new
    LETTERS.clear
    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
    LETTERS << @letters
    @point = POINT
  end

  def score
    @answer = params[:score]

    @answer_hash = @answer.upcase.split('').group_by(&:itself)
    @answer_hash_num = @answer_hash.each { |k, v| @answer_hash[k] = v.size }

    @letters_hash = LETTERS[0].group_by(&:itself)
    @letters_hash_num = @letters_hash.each { |k, v| @letters_hash[k] = v.size }

    @duplicate_letters = @answer_hash_num.keys.find do |k|
      @answer_hash_num[k].to_i > @letters_hash_num[k].to_i
    end

    if @duplicate_letters.nil?
      @url = "https://wagon-dictionary.herokuapp.com/#{@answer}"
      @json = open(@url).read
      @result = JSON.parse(@json)

      if @result['found']
        @message = "Congratulations! #{@answer.upcase} is a valid English word!"
        @point = POINT
        @point += @answer.size
        POINT << @point
      else
        @message = "Sorry but #{@answer.upcase} does not seem to be a valid English word..."
        @point = POINT
      end
    else
      @message = "Sorry but #{@answer.upcase} can't be built out of #{LETTERS[0].join}"
      @point = POINT
    end
  end
end

module Api
  class BoosterbotController < ApplicationController
    include ActionView::Helpers::TextHelper

  @@auth_token = ENV['SLASH_COMMAND_TOKEN']

  before_action :token_authenticate!

    def slash_bot
      puts params

      if params[:command] == '/bot'
        text = params[:text]
        puts 'Full text: ' + text

        command = first(text)
        text = strip_first(text)

        puts 'Parsed command: ' + command

        case command
          when 'help' then
            answer("Commands for /bot: help hello stats sponsors")

          when 'hello' then
            command_hello

          when 'stats' then
            command_stats(text)

          when 'sponsors' then
            command_sponsors(text)

          when 'say' then
            answer(text.empty? ? 'Say what?' : text)

          else
            answer("I'm sorry. I don't understand what you mean.")
          end

      else
        head :bad_request
      end
    end

    def command_hello
      answer("Hello, #{params[:user_name]}. How are you?")
    end

    def command_sponsors(text)
      if text.empty?
        count_accepted = Sponsor.where(status: 'accepted').count
        count_dialogue = Sponsor.where(status: 'dialogue').count
        message = "Right now we have #{pluralize(count_accepted, ' accepted partner')}."
        if count_dialogue > 0
          message = message + " There are #{count_dialogue} in dialogue though, so maybe we'll get more soon!"
        end
        answer(message)
      else
       answer( text + " is not a valid sub command for 'sponsors'")
      end
    end

    def answer(message)
      SlackNotifier.post_reply(params, message)
      render :nothing => true, :status => 204
    end

    def strip_first(text)
      text.split(' ').drop(1).join(' ')
    end

    def first(text)
      if not text
        nil
      else
        text.include?(' ') ? text.split(' ')[0].to_s : text
      end
    end


    def token_authenticate!
      render :nothing => true, :status => 401 unless params[:token] == @@auth_token
    end

  end
end

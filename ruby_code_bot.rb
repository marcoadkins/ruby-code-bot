require 'json'
require 'sinatra/base'
require 'safe_ruby'
require 'ostruct'


class RubyCodeBot < Sinatra::Base
  SLACK_TOKENS = ENV['SLACK_TOKENS']&.split || []
  SHARE_ACTION = 'share'.freeze

  before do
    halt 401 unless SLACK_TOKENS.include?(params[:token])
  end

  post '/execute' do
    content_type :json
    response = { attachments: [{ title: 'Code:', text: params['text'] }] }
    result = SafeRuby.eval(params['text'])
    response[:attachments] << { color: 'good', title: 'Result:', text: result.to_s }
    response[:attachments] << { attachment_type: 'default', text: '', callback_id: 'execute', actions: [{ text: 'Share', name: SHARE_ACTION, value: SHARE_ACTION, type: 'button' }] }
    response.to_json
  rescue SyntaxError, StandardError => e
    response[:attachments] << { color: 'danger', title: 'Exception:', text: e.message }
    response[:attachments] << { attachment_type: 'default', text: '', callback_id: 'execute', actions: [{ text: 'Share', name: SHARE_ACTION, value: SHARE_ACTION, type: 'button' }] }
    response.to_json
  end

  post '/message_action' do
    payload=JSON.parse(params[:payload], object_class: OpenStruct)
    puts payload.inspect

    case payload&.actions&.first&.name
    when 'share'
      puts 'share message'
    else
      puts 'Unhandled action'
    end
  end
end
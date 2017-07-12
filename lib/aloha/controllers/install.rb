module Aloha
  class Web < Sinatra::Base
    get '/install' do
      if params[:code].nil?
        redirect '/'
      end

      client = Slack::Web::Client.new

      raise 'Missing SLACK_CLIENT_ID or SLACK_CLIENT_SECRET.' unless ENV.key?('SLACK_CLIENT_ID') && ENV.key?('SLACK_CLIENT_SECRET')

      rc = client.oauth_access(
        client_id: ENV['SLACK_CLIENT_ID'],
        client_secret: ENV['SLACK_CLIENT_SECRET'],
        redirect_uri: "#{URI.escape(ENV['BASE_URL'])}/install",
        code: params[:code]
      )

      token = rc['bot']['bot_access_token']
      team = Team.where(token: token).first
      team ||= Team.where(team_id: rc['team_id']).first
      if team && !team.active?
        team.activate!(token)
      elsif !team
        team = Team.create!(
          token: token,
          team_id: rc['team_id'],
          name: rc['team_name']
        )
      end

      user_token = rc['access_token']
      user = create_and_store_logged_in_user(user_token, rc['user_id'], rc['team_id'])

      rt_client = Slack::RealTime::Client.new(token: team.token)
      rt_client.web_client.chat_postMessage(channel: "@#{user.username}", 
                                            as_user: true, 
                                            text: "Welcome to paradise! Aloha is up and running. Type *help* for a list of commands.", 
                                            attachments: [Aloha::Commands::Help::ALOHA_ATTACHMENT], 
                                            link_names: true)


      SlackRubyBotServer::Service.instance.create!(team)
      session[:slack_team_token] = token
      redirect '/welcome'
    end
  end
end
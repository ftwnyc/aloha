module Aloha
  class Web < Sinatra::Base
    get '/' do
      redirect '/app/messages' if logged_in?
      erb :index
    end
  end
end
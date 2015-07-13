require 'sinatra/base'
require 'data_mapper'
require 'sinatra/flash'
require_relative 'data_mapper_setup'
require_relative './models/peep'
require_relative './models/user'

class ChitterFeatures < Sinatra::Base
  set :views, proc { File.join(root, '..', 'views') }
  register Sinatra::Flash
  enable :sessions
  set :session_secret, 'super secret'

  get '/peeps' do
    @peeps = Peep.all
    erb :'peeps/peeps'
  end

  get '/peeps/new' do
    erb :'peeps/new'
  end

  post '/peeps' do
    peep = Peep.new(message: params[:message])
    tags = params[:tag].split(" ")

    tags.each do |tag|
      peep.tags <<  Tag.create(name: tag)
    end

    peep.save
    redirect to('/peeps')
  end

  get '/tags/:name' do
    tag = Tag.first(name: params[:name])
    @peeps = tag ? tag.peeps : []
    erb :'peeps/peeps'
  end

  get '/users/new' do
    erb :'users/new'
  end

  post '/users' do
    user = User.create(email: params[:email],
                     password: params[:password])
    if user.save
      session[:user_id] = user.id
      redirect to('/peeps')
    else 
      flash.now[:error] = "Email address already in use"
      erb :'users/new'
    end
  end


  helpers do
    def current_user
      return false unless session[:user_id]
      current_user ||= User.first(id: session[:user_id])
    end
  end



  # start the server if ruby file executed directly
  run! if app_file == $0
end

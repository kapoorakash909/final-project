# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
require "geocoder"                                                                    #
                                                                  #  
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

places_table = DB.from(:places)
activities_table = DB.from(:activities)
users_table = DB.from(:users)
votes_table = DB.from(:votes)

# put your API credentials here (found on your Twilio dashboard)
account_sid = ENV["TWILIO_ACCOUNT_SID"]
auth_token = ENV["TWILIO_AUTH_TOKEN"]
#stored in environment!
# set up a client to talk to the Twilio REST API
client = Twilio::REST::Client.new(account_sid, auth_token)


get "/" do
    puts "params: #{params}"

    @places = places_table.all.to_a
    view "places"
end

get "/places/:id" do
    
    @places = places_table.where(id: params[:id]).to_a[0]
    @activities = activities_table.where(places_id: @places[:id]).to_a
    
    @votes = votes_table.where(places_id: @places[:id]).to_a[0]
    @location = @places[:city]
    @results = Geocoder.search(@location)
    @lat_long = @results.first.coordinates
    view "places_location"
end

get "/places/:id/upvote" do
    
    @places = places_table.where(id: params[:id]).to_a[0]
    @activities = activities_table.where(places_id: @places[:id]).to_a
    
    votes_table.insert(places_id: @places[:id],
        user_id: session["user_id"],
        activities_id: params["activities_id"],
        votes: params["votesincrement"]
        )
    
    @location = @places[:city]
    @results = Geocoder.search(@location)
    @lat_long = @results.first.coordinates
    view "places_location"
end

get "/places/:id/activities/new" do
    
    @user_table = DB.from(:users)
    @places = places_table.where(id: params[:id]).to_a[0]
    view "create_activities"
end

get "/places/:id/activities/create" do
   
    @places = places_table.where(id: params[:id]).to_a[0]
    
    activities_table.insert(places_id: @places[:id],
        user_id: session["user_id"],
        title: params["title"],
        description: params["description"],
        type: params["type"]
        )

    view "create_activities_success"
end




get "/users/create_user" do
    view "create_user"
end

post "/users/create" do
    

    @users = users_table.where(email: params["email"]).to_a[0]

    if @users
            view "create_user_failed"
    else
        user_name = params["name"]
        users_table.insert(        
            name: params["name"],
            password: BCrypt::Password.create(params["password"]),
            email: params["email"]
            )
  
        client.messages.create(
            from: "+17203864837", 
            to: "+18722358982",
            body: "New account created for #{user_name}!"
            )
        
        view "create_user_success"  

    end
    
    
end

get "/logins/create_login" do
    view "create_login"
end

post "/logins/create" do
    
    @users = users_table.where(email: params["email"]).to_a[0]

    if @users && BCrypt::Password.new(@users[:password]) == params["password"]
            session["user_id"] = @users[:id]
            session["username"] = @users[:name]
            view "create_login_success"
    else
            view "create_login_failed"
    end
    
end

get "/logout" do
    session["user_id"] = nil
    view "logout"
end
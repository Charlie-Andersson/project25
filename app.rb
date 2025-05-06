require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
enable :sessions

get('/') do
slim(:start)
end

before('/protected/*') do
    if session[:user_id] ==  nil
        redirect('/')
    end
end
 

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new("db/pokemon.db")
    db.results_as_hash = true 
    result = db.execute("SELECT * FROM user WHERE username = ?", username).first
p "putsen är här #{result}"
p result['userId']
    if result && password == result["password"] 
        session[:user_id] = result['userId'] 
        p "session puts här #{session[:user_id]}"
        redirect('/protected/party')
    else
        redirect('/')
    end
end
    

    

get('/protected/party') do
    db = SQLite3::Database.new("db/pokemon.db")
    db.results_as_hash = true 
    @party = db.execute("SELECT * FROM party")
    @partyPokemon = db.execute("SELECT * FROM party_pokemon")
    @data2 = db.execute(
        "SELECT party_pokemon.pokemonId, pokemon.pokemonName
        FROM party_pokemon
        JOIN pokemon ON party_pokemon.pokemonId = pokemon.PokemonId")
    @user_info = db.execute("SELECT * FROM user")
slim(:party)
end

get('/pokemon') do
    db = SQLite3::Database.new("db/pokemon.db")
    db.results_as_hash = true 
    @data = db.execute("SELECT * FROM pokemon")
slim(:pokemon)
end

post('/users') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if username.nil? || username.strip.length < 3
      halt 400, "användarnamn måste vara minst 3 bokstäver långt"
    elsif password.nil? || password.strip.length < 3
      halt 400, "lösen måste vara minst 3 bokstäver långt"
    elsif password != password_confirm
      halt 400, "lösen matchar inte"
    else
      db = SQLite3::Database.new('db/pokemon.db')
      db.execute("INSERT INTO user (username, password) VALUES (?, ?)", [username, password])
      redirect('/')
    end
end

post('/party/:id/add') do
    id = session[:user_id]
    pokemon_id = params[:pokemon_id] 
    user_id = session[:user_id] 
  
    if user_id.nil?
      redirect('/') 
    elsif user_id == session[:user_id]
      db = SQLite3::Database.new("db/pokemon.db")
      db.execute("INSERT INTO party_pokemon (partyId, pokemonId) VALUES (?, ?)", [user_id, pokemon_id])
      redirect('/protected/party') 
    end
end

post('/protected/party/:id/remove') do
    id = session[:user_id]
    pokemon_id = params[:pokemon_id]
    user_id = session[:user_id] 
  
    if user_id.nil?
      redirect('/') 
    elsif user_id == session[:user_id]
      db = SQLite3::Database.new("db/pokemon.db")
      db.execute("DELETE FROM party_pokemon WHERE partyId = ? AND pokemonId = ?", [user_id, pokemon_id])
      redirect('/protected/party') 
    end
end

post('/protected/party/:id/create') do
    id = session[:user_id]
    party_name = params[:party_name]
    user_id = session[:user_id] 
    if user_id.nil?
      redirect('/') 
    elsif user_id == session[:user_id]
      db = SQLite3::Database.new("db/pokemon.db")
      db.execute("INSERT INTO party (partyName, partyId) VALUES (?, ?)", [party_name, user_id])
      redirect('/protected/party') 
    end
end

get('/logout') do
    session.clear
    redirect('/')
end
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
enable :sessions

get('/') do
slim(:start)
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
        redirect('/party')
    else
        redirect('/')
    end
end
    

    

get('/party') do
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

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm)
      db = SQLite3::Database.new('db/pokemon.db')
      db.execute("INSERT INTO user (username, password) VALUES (?,?)", [username, password])
      redirect('/')
    else

    end
end

post('/add') do
    pokemon_id = params[:pokemon_id] 
    user_id = session[:user_id] 
  
    if user_id.nil?
      redirect('/') 
    else
      db = SQLite3::Database.new("db/pokemon.db")
      db.execute("INSERT INTO party_pokemon (partyId, pokemonId) VALUES (?, ?)", [user_id, pokemon_id])
      redirect('/party') 
    end
end

post('/remove') do
    pokemon_id = params[:pokemon_id]
    user_id = session[:user_id] 
  
    if user_id.nil?
      redirect('/') 
    else
      db = SQLite3::Database.new("db/pokemon.db")
      db.execute("DELETE FROM party_pokemon WHERE partyId = ? AND pokemonId = ?", [user_id, pokemon_id])
      redirect('/party') 
    end
end

post('/create') do
    party_name = params[:party_name]
    user_id = session[:user_id] 
    if user_id.nil?
      redirect('/') 
    else
      db = SQLite3::Database.new("db/pokemon.db")
      db.execute("INSERT INTO party (partyName, partyId) VALUES (?, ?)", [party_name, user_id])
      redirect('/party') 
    end
end

get('/logout') do
    session.clear
    redirect('/')
end
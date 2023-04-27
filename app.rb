require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions

include Model

  get('/')  do
    slim(:start)
  end 

  get('/review') do
    result = getReviews()
    slim(:"review/index",locals:{review:result})
  end

  get('/review/new') do
    if session[:loggedId] != nil
      slim(:"review/new")
    else
      redirect('/login')
    end
  end
  
  post('/review/new') do
    userId = session[:loggedId]
    title = params[:title]
    rating = params[:rating]
    director = params[:director]
    db = SQLite3::Database.new("db/db.db")
    db.execute("INSERT INTO review (userId, title, rating, director) VALUES (?,?,?,?)",userId, title, rating, director)
    redirect('/review')
  end

  post('/review/:id/update') do
    id = params[:id].to_i
    title = params[:title]
    userId = session[:loggedId].to_i
    rating = params[:rating]
    director = params[:director]
    db = SQLite3::Database.new("db/db.db")
    db.execute("UPDATE review SET title=?,userId=?,rating=?,director=? WHERE reviewId =?",title,userId,rating,director,id)
    redirect('/review')
  end
  
  get('/review/:id/edit') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM review WHERE reviewId = ?",id).first
    slim(:"/review/edit",locals:{result:result})
  end

  post('/review/:id/delete') do

    id = params[:id].to_i
    db = SQLite3::Database.new("db/db.db")
    tempId = db.execute("SELECT userId FROM review WHERE reviewId = ?",id)[0][0]

    if session[:loggedId] == tempId || session[:loggedId] == 1
      slim(:"review/new")
      id = params[:id].to_i
      db = SQLite3::Database.new("db/db.db")
      db.execute("DELETE FROM review WHERE reviewId = ?", id)
      redirect('/review')

    else
      redirect("/review")
    end
  end

  get('/login') do
    slim(:"/login")
  end

  post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true 
    result = db.execute("SELECT * FROM user WHERE username =?",username).first
    pwdigest = result["pwdigest"]
    id = result["userId"]
  
    if BCrypt::Password.new(pwdigest) == password
      session[:loggedId] = id
      redirect('/')
  
    else
      "Wrong password"
    end

  end

  get('/user/new') do
    slim(:"user/new")
  end

  post('/user/new') do
    username = params[:username]
    password = params[:password]
    passwordConfirm = params[:passwordConfirm]
  
    if password == passwordConfirm

      passwordDigest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/db.db')
      db.execute("INSERT INTO user (username,pwdigest) VALUES (?,?)",username,passwordDigest)
      redirect('/')
  
    else
      "Password does not match"
      slim(:"user/new") 
    end

  end

  get('/logout') do
      session.clear
      redirect('/')
  end

get '/movie/new' do
  if session[:loggedId]
    slim(:'movie/new')
  else
    redirect('/login')
  end
end

post('/movie/new') do
  userId = session[:loggedId]
  title = params[:title]
  
  db = SQLite3::Database.new("db/db.db")
  movieId = db.execute("SELECT movieId FROM movie WHERE title = ?", title).first
  
  if movieId.nil?
    db.execute("INSERT INTO movie (title) VALUES (?)", title)
    movieId = db.last_insert_row_id
  else
    movieId = db.execute("SELECT movieId FROM movie WHERE title = ?", title)

  end
  
  db.execute("INSERT INTO user_movie (userId, movieId) VALUES (?, ?)", userId, movieId)
  
  redirect('/movie')
end

get '/movie' do
  if session[:loggedId]
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM movie INNER JOIN user_movie ON movie.movieId=user_movie.movieId WHERE user_movie.userId=?", session[:loggedId])
    slim(:'movie/index', locals: {movies: result})
  else
    redirect('/login')
  end
end

post '/movie/:id/delete/' do
  if session[:loggedId]
    movie_id = params[:id].to_i
    user_id = session[:loggedId]
    
    db = SQLite3::Database.new('db/db.db')
    db.execute("DELETE FROM user_movie WHERE userId=? AND movieId=?", user_id, movie_id)
    
    redirect '/movie'
  else
    redirect '/login'
  end
end

get '/review/:id' do
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  review = db.execute("SELECT * FROM review WHERE reviewId = ?", params[:id]).first
  slim(:'review/show', locals: { review: review })
end

  
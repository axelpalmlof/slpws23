require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

  get('/')  do
    slim(:start)
  end 

  get('/review') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM review")
    p result
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
    userId = session[:loggedId]
    rating = params[:rating]
    director = params[:director]
    db = SQLite3::Database.new("db/db.db")
    db.execute("UPDATE review SET title=?,userId=?,rating=?,director=? WHERE reviewId =?",title,userId,rating,id)
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


require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'

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
    slim(:"review/new")
  end
  
  post('/review/new') do
    userId = params[:userId].to_i
    title = params[:title]
    rating = params[:rating]
    db = SQLite3::Database.new("db/db.db")
    db.execute("INSERT INTO review (userId, title, rating) VALUES (?,?,?)",userId, title, rating)
    redirect('/review')
  end
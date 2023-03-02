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
    userId = params[:userId]
    title = params[:title]
    rating = params[:rating]
    director = params[:director]
    db = SQLite3::Database.new("db/db.db")
    db.execute("INSERT INTO review (userId, title, rating, director) VALUES (?,?,?,?)",userId, title, rating, director)
    db.execute("INSERT INTO director (name) VALUES (?)",director)
    tempId = db.execute("SELECT directorId FROM director WHERE name = ?", director)
    db.execute("INSERT INTO movie (name, directorId) VALUES (?,?)",title, tempId)
    redirect('/review')
  end

  post('/review/:id/update') do
    id = params[:id].to_i
    title = params[:title]
    userId = params[:userId]
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
    db.execute("DELETE FROM review WHERE reviewId = ?",id)
    redirect('/review')
  end
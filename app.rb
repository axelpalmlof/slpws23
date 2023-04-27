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
    result = getReview()
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
    newReview()
    redirect('/review')
  end

  post('/review/:id/update') do
    updateReview()
    redirect('/review')
  end
  
  get('/review/:id/edit') do
    #editAuth()
    result = editReview()
    slim(:"/review/edit",locals:{result:result})
  end

  post('/review/:id/delete') do
    deleteAuth()
  end

  get('/login') do
    slim(:"/login")
  end

  post('/login') do
    loginUser()
  end

  get('/user/new') do
    slim(:"user/new")
  end

  post('/user/new') do
    newUser()
  end

  get('/logout') do
      session.clear
      redirect('/')
  end

  get('/movie/new') do
    if session[:loggedId]
      slim(:'movie/new')
    else
      redirect('/login')
    end
  end

  post('/movie/new') do
    newMovie()
    redirect('/movie')
  end

  get('/movie') do
    if session[:loggedId]
      result = getMovie()
      slim(:'movie/index', locals: {movies: result})
    else
      redirect('/login')
    end
  end

  post('/movie/:id/delete/') do
    if session[:loggedId]
      deleteMovie()      
      redirect('/movie')
    else
      redirect('/login')
    end
  end

  get('/review/:id') do
    result = showReview()
    slim(:'review/show', locals: { review: result })
  end
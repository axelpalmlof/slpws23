require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions

include Model

  # Displays the homepage
  #
  get('/')  do
    slim(:start)
  end 

  # Displays a list of all reviews
  #
  # @see Model#getReview
  get('/review') do
    result = getReview()
    slim(:"review/index",locals:{review:result})
  end

  # Displays a form for adding a new review, but only if the user is logged in
  #
  get('/review/new') do
    if session[:loggedId] != nil
      slim(:"review/new")
    else
      redirect('/login')
    end
  end
  
  # Adds a new review to the database, then redirects to the reviews index page
  #
  # @param [Integer] userId, the author of the review
  # @param [String] title, the movies title
  # @param [Sting] rating, thoughts of the movie
  # @param [String] director, the movies director
  #
  # @see Model#newReview
  post('/review/new') do
    newReview()
    redirect('/review')
  end

  # Updates an existing review in the database, then redirects to the reviews index page
  #
  # @param [Integer] id, the reviews id
  # @param [Integer] userId, the author of the review
  # @param [String] title, the movies title
  # @param [Sting] rating, thoughts of the movie
  # @param [String] director, the movies director
  #
  # @see Model#updateReview
  post('/review/:id/update') do
    updateReview()
    redirect('/review')
  end
  
  # Displays a form for editing an existing review, but only if the user is logged in and is the author of the review
  #
  # @param [Integer] id, the reviews id
  #
  # @see Model#editAuth
  # @see Model#editReview
  get('/review/:id/edit') do
    auth = editAuth()
    if auth == true
      result = editReview()
      slim(:"/review/edit",locals:{result:result})
    else
      redirect('/review')
    end
  end

  # Deletes an existing review from the database, but only if the user is logged in and is the author of the review
  #
  # @param [Integer] id, the reviews id
  #
  # @see Model#deleteAuth
  post('/review/:id/delete') do
    deleteAuth()
  end

  # Displays the login form
  #
  get('/login') do
    slim(:"/login")
  end

  # Authenticates the user and logs them in
  #
  # @param [String] username, The username
  # @param [String] password, The password
  #
  # @see Model#loginUser
  post('/login') do
    loginUser()
  end

  # Displays a form for creating a new user account
  # 
  get('/user/new') do
    slim(:"user/new")
  end

  # Creates a new user account in the database, then logs the user in and redirects to the homepage
  #
  # @see Model#newUser
  post('/user/new') do
    newUser()
  end

  # Logs the user out by clearing the session data, then redirects to the login page
  #
  get('/logout') do
      session.clear
      redirect('/login')
  end

  # Displays form to add a movie you want to watch
  #
  get('/movie/new') do
    if session[:loggedId]
      slim(:'movie/new')
    else
      redirect('/login')
    end
  end

  # Creates a movie in the database that a user wants to see
  #
  # @param [Integer] userId, the author of the review
  # @param [String] title, the movies title
  #
  # @see Model#newMovie
  post('/movie/new') do
    newMovie()
    redirect('/movie')
  end

  # Shows movies that the logged in user wants to se
  #
  # @see Model#getMovie
  get('/movie') do
    if session[:loggedId]
      result = getMovie()
      slim(:'movie/index', locals: {movies: result})
    else
      redirect('/login')
    end
  end

  # Deletes a movie from the watch list
  #
  # @param [Integer] movie_id, the movie that is gettig deleted
  # @param [Integer] user_id, the user that had that movie in watchlist
  #
  # @see Model#deleteMovie
  post('/movie/:id/delete/') do
    if session[:loggedId]
      deleteMovie()      
      redirect('/movie')
    else
      redirect('/login')
    end
  end

  # Shows a review someone has wrote
  #
  # @param [Integer] id, the reviews id
  #
  # @see Model#showReview
  get('/review/:id') do
    result = showReview()
    slim(:'review/show', locals: { review: result })
  end
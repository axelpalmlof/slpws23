module Model

    # Connect to database with read and write access
    #
    # @return [Database] for reading and writing to database
    def dbConnect()
        db = SQLite3::Database.new("db/db.db")
        db.results_as_hash = true
        return db
    end

    # Connect to database with write access only
    #
    # @return [Database] for writing to database
    def dbConnectWh()
        return SQLite3::Database.new("db/db.db")
    end
    
    # Retrieve all reviews from database
    #
    # @return [Hash]
    #   * :userId [Integer] The ID of the author
    #   * :title [String] The title of the movie
    #   * :rating [String] thoughts of the movie
    #   * :director [String] the movies director
    def getReview()
        db = dbConnect()
        return db.execute("SELECT * FROM review")
    end

    # Add a new review to database
    #
    # @param [Integer] userId, the author of the review
    # @option params [String] title, the movies title
    # @option params [Sting] rating, thoughts of the movie
    # @option params [String] director, the movies director
    def newReview()
        userId = session[:loggedId]
        title = params[:title]
        rating = params[:rating]
        director = params[:director]
        db = dbConnectWh()
        db.execute("INSERT INTO review (userId, title, rating, director) VALUES (?,?,?,?)",userId, title, rating, director)
    end

    # Update an existing review in database
    #
    # @param [Integer] id, the reviews id
    # @param [Integer] userId, the author of the review
    # @param [String] title, the movies title
    # @option params [Sting] rating, thoughts of the movie
    # @param [String] director, the movies director
    def updateReview()
        id = params[:id].to_i
        title = params[:title]
        userId = session[:loggedId].to_i
        rating = params[:rating]
        director = params[:director]
        db = dbConnectWh()
        db.execute("UPDATE review SET title=?,userId=?,rating=?,director=? WHERE reviewId =?",title,userId,rating,director,id)
    end

    # Retrieve a specific review from database
    #
    # @param [Integer] reviewId, the reviews id
    #
    # @return [Hash]
    #   * :userId [Integer] The ID of the author
    #   * :title [String] The title of the movie
    #   * :rating [String] thoughts of the movie
    #   * :director [String] the movies director
    def showReview()
        db = dbConnect()
        return db.execute("SELECT * FROM review WHERE reviewId = ?", params[:id]).first
    end

    # Retrieve a specific review for editing from database
    #
    # @param [Integer] reviewId, the reviews id
    #
    # @return [Hash]
    #   * :userId [Integer] The ID of the author
    #   * :title [String] The title of the movie
    #   * :rating [String] thoughts of the movie
    #   * :director [String] the movies director
    def editReview()
        id = params[:id].to_i
        db = dbConnect()
        return db.execute("SELECT * FROM review WHERE reviewId = ?",id).first
    end

    # Delete a specific review from database
    #
    # @param [Integer] reviewId, the reviews id
    def deleteReview()
        slim(:"review/new")
        id = params[:id].to_i
        db = dbConnectWh()
        db.execute("DELETE FROM review WHERE reviewId = ?", id)
        redirect('/review')
    end

    # Check if the user is authorized to delete a specific review
    #
    # @param [Integer] reviewId, the reviews id
    def deleteAuth()
        id = params[:id].to_i
        db = dbConnectWh()
        tempId = db.execute("SELECT userId FROM review WHERE reviewId = ?",id)[0][0]

        if session[:loggedId] == tempId || session[:loggedId] == 1
            deleteReview()
        else
            redirect("/review")
        end
    end

    # Check if the user is authorized to edit a specific review
    #
    # @param [Integer] reviewId, the reviews id
    #
    # @return [True]
    # @return [False]
    def editAuth()
        id = params[:id].to_i
        db = dbConnectWh()
        tempId = db.execute("SELECT userId FROM review WHERE reviewId = ?",id)[0][0]

        if session[:loggedId] == tempId || session[:loggedId] == 1
            return true
        else
            return false
        end
    end

    # Logs in a user with username and password
    #
    # @option params [String] username, The username
    # @option params [String] password, The password
    def loginUser()
        username = params[:username]
        password = params[:password]
        db = dbConnect()
        result = db.execute("SELECT * FROM user WHERE username =?",username).first

        if result != nil
            pwdigest = result["pwdigest"]
            id = result["userId"]
            if BCrypt::Password.new(pwdigest) == password
                session[:loggedId] = id
                redirect('/')
            else
                "Wrong password"
            end
        else
            "No such user exist"
        end
    end

    # Adds a new user to the database with a username and a password
    #
    # @option params [String] username, The username
    # @option params [String] password, The password
    def newUser()
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

    # Adds a movie into a users watchlist
    #
    # @param [Integer] userId, the watchlists user
    # @option params [String] title, the movies title
    def newMovie()
        userId = session[:loggedId]
        title = params[:title]
        db = dbConnectWh()
        movieId = db.execute("SELECT movieId FROM movie WHERE title = ?", title).first
        
        if movieId.nil?
            db.execute("INSERT INTO movie (title) VALUES (?)", title)
            movieId = db.last_insert_row_id
        else
            movieId = db.execute("SELECT movieId FROM movie WHERE title = ?", title)
        end   
        db.execute("INSERT INTO user_movie (userId, movieId) VALUES (?, ?)", userId, movieId)
    end

    # Shows all movies on a users watchlist
    #
    # @return [Hash]
    #   * :userId [Integer] The ID of the author
    #   * :title [String] The title of the movie
    #   * :movieId [Integer] the movies id
    def getMovie()
        db = dbConnect()
        return db.execute("SELECT * FROM movie INNER JOIN user_movie ON movie.movieId=user_movie.movieId WHERE user_movie.userId=?", session[:loggedId])
    end

    # Deletes a movie into a users watchlist
    #
    # @param [Integer] movie_id, the movie that is gettig deleted
    # @param [Integer] user_id, the user that had that movie in watchlist
    def deleteMovie()
        movie_id = params[:id].to_i
        user_id = session[:loggedId] 
        db = dbConnectWh()
        db.execute("DELETE FROM user_movie WHERE userId=? AND movieId=?", user_id, movie_id)
    end


end
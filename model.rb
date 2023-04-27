module Model

    def dbConnect()
        db = SQLite3::Database.new("db/db.db")
        db.results_as_hash = true
        return db
    end

    def dbConnectWh()
        return SQLite3::Database.new("db/db.db")
    end
    
    def getReview()
        db = dbConnect()
        return db.execute("SELECT * FROM review")
    end

    def newReview()
        userId = session[:loggedId]
        title = params[:title]
        rating = params[:rating]
        director = params[:director]
        db = dbConnectWh()
        db.execute("INSERT INTO review (userId, title, rating, director) VALUES (?,?,?,?)",userId, title, rating, director)
    end

    def updateReview()
        id = params[:id].to_i
        title = params[:title]
        userId = session[:loggedId].to_i
        rating = params[:rating]
        director = params[:director]
        db = dbConnectWh()
        db.execute("UPDATE review SET title=?,userId=?,rating=?,director=? WHERE reviewId =?",title,userId,rating,director,id)
    end

    def showReview()
        db = dbConnect()
        return db.execute("SELECT * FROM review WHERE reviewId = ?", params[:id]).first
    end

    def editReview()
        id = params[:id].to_i
        db = dbConnect()
        return db.execute("SELECT * FROM review WHERE reviewId = ?",id).first
    end

    def deleteReview()
        slim(:"review/new")
        id = params[:id].to_i
        db = dbConnectWh()
        db.execute("DELETE FROM review WHERE reviewId = ?", id)
        redirect('/review')
    end

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

    # def editAuth()
    #     id = params[:id].to_i
    #     db = dbConnectWh()
    #     tempId = db.execute("SELECT userId FROM review WHERE reviewId = ?",id)[0][0]

    #     if session[:loggedId] == tempId || session[:loggedId] == 1
    #         newReview()
    #     else
    #         redirect("/review")
    #     end
    # end

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

    def getMovie()
        db = dbConnect()
        return db.execute("SELECT * FROM movie INNER JOIN user_movie ON movie.movieId=user_movie.movieId WHERE user_movie.userId=?", session[:loggedId])
    end

    def deleteMovie()
        movie_id = params[:id].to_i
        user_id = session[:loggedId] 
        db = dbConnectWh()
        db.execute("DELETE FROM user_movie WHERE userId=? AND movieId=?", user_id, movie_id)
    end
end
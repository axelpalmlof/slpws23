module Model
    
    def getReviews()
        db = SQLite3::Database.new("db/db.db")
        db.results_as_hash = true
        return = db.execute("SELECT * FROM review")
    end


end
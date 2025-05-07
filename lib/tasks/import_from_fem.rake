# setup: first grab backup from fem[dot]nz and run backup restore script from ./femnzbackup/ (so femnzbackup/storage is populated)
# db has to be configured there called femnz in config/storage.yml
# then run this
desc 'Import posts from fem[dot]nz'
task :import_from_fem => [ :environment ] do
    # Store old posts in a `posts` array
    ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => "fem-storage/development.sqlite3")
    fem_articles = []
    Article.all.each { |article| fem_articles << article }
    fem_articles = fem_articles.map { |article| 
        article.title = "fem/" + article.title
        article.visibility = false
        article.id = nil
        article
    }
    print(fem_articles)

    # Recreate missing posts from missing ids
    ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => "storage/development.sqlite3")
    fem_articles.each { |article| print("Failed with article"+article.title) if !Article.create!(title: article.title, body: article.body) }
end
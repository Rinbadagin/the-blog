# setup: first grab backup from fem[dot]nz and run backup restore script from ./femnzbackup/ (so femnzbackup/storage is populated)
# db has to be configured there called femnz in config/storage.yml
# then run this
desc 'Import uploads from fem[dot]nz'
task :import_uploads_from_fem => [ :environment ] do
    # Store old posts in a `posts` array
    ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => "fem-storage/development.sqlite3")
    fem_uploads = []
    Upload.all.each { |upload| fem_uploads << upload }
    fem_uploads = fem_uploads.map { |upload| 
        newFilePath = ActiveStorage::Blob.service.path_for(upload.content.key)
        index = newFilePath.to_s.index("storage")
        {
            :title => "fem" + upload.title,
            :downloaded => Dir.pwd + "/fem-" + newFilePath.to_s()[index..],
            :filename => upload.content.blob.filename
        }
    }

    print(fem_uploads)

    # Recreate missing posts from missing ids
    ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => "storage/production.sqlite3")

    fem_uploads.each { |upload|
        print("Title: #{upload[:title]}\n")
        print("Content? #{upload[:downloaded][..70]}\n")
        print("Filename? #{upload[:filename]}\n")
        print("id? #{upload[:id]}\n")
    }

    fem_uploads.each { |upload| 
        up = Upload.new(title: upload[:title])
        up.content.attach(io: File.open(upload[:downloaded]), filename: upload[:filename])
        print("id #{up.id} title #{upload[:title]} download #{upload[:downloaded][0..25]}")
        up = up.save!
        print("Failed with upload " + upload.title) if !up 
    }
end
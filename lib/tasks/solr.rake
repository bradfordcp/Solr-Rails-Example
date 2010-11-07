namespace :solr do
  desc "Reindexes all content nodes"
  task :reindex => :environment do
    STDOUT.sync = true
    
    SOLR_SERVER = 'http://127.0.0.1:8983/solr'
    
    puts "Connecting to Solr Server: #{SOLR_SERVER}"
    require 'solr'
    conn = Solr::Connection.new(SOLR_SERVER)
    
    puts "Deleting Index"
    conn.delete_by_query('*:*')
    conn.commit
    
    puts "Syncing Content Nodes"
    Post.all.each do |post|
      begin
        conn.add(post.to_solr)
        print '+' 
      rescue
        print 'X' 
        puts "\n#{$!}"
      end
    end
    conn.commit
    
    puts "\nReindex Complete"
  end
end
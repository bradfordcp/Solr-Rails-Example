require 'open-uri'

desc 'populate posts ex. COUNT=100 rake make_posts'
task :make_posts => :environment do
  count = ENV['COUNT'] || 10
  sources = [["Hitchhicker's Guide", 'en-galaxy-word-2gram'],
    ["Finnegan's Wake", 'en-finnegan-word-2gram'],
    ["Great Expectations", 'en-dickens-word-2gram']
  ]
  tags = %w(up down right left highorder loworder current pastdue)

  count.to_i.times do 
    title = ''
    body = ''
    source = sources[rand(sources.size)]

    # automagic article generator
    doc = Nokogiri::HTML(open("http://johno.jsmf.net/knowhow/ngrams/index.php?table=#{source[1]}&paragraphs=3&length=100") )
    doc.css('#text p').each_with_index do |p, i|
      if i == 0
        title = p.inner_html.split('.')[0].capitalize
      else
        body += "<p>%s</p>" % p.inner_html
      end
    end

    # lets get some tags! maybe all, maybe not...
    post_tags = tags.map{|t| tags[rand(tags.size)]}.uniq

    cat = Category.find_or_create_by_name(source[0])
    post = Post.new :title => title, :body => body, :category => cat
    
    # assign our tags, and create them if needed
    post_tags.each do |t|
      post.tags << Tag.find_or_create_by_name(t)
    end

    post.save

    # give the server guy a break
    sleep 0.1
  end
end


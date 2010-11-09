#!//bin/bash

export JAVA_OPTIONS="-Dsolr.home=/Users/bradfordcp/src/ruby/solr/solr/solr -Dsolr.data=/Users/bradfordcp/src/ruby/solr/solr/solr/data"
export JETTY_HOME="/Users/bradfordcp/src/ruby/solr/solr"

./bin/jetty.sh start
iDoctor

config
in solr/example: java -jar start.jar

crawl: bin/nutch crawl urls -solr http://localhost:8983/solr/ -depth 3 -topN 5

index: bin/nutch solrindex http://127.0.0.1:8983/solr/ crawl-20131219174323/crawldb -linkdb crawl-20131219174323/linkdb crawl-20131219174323/segments/*

=======

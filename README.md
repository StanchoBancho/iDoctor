iDoctor

config
in solr/example: java -jar start.jar

crawl: bin/nutch crawl urls -solr http://localhost:8983/solr/ -depth 3 -topN 5

index: bin/nutch solrindex http://127.0.0.1:8983/solr/ crawl-20131219174323/crawldb -linkdb crawl-20131219174323/linkdb crawl-20131219174323/segments/*

=======


bin/nutch crawl urls -solr http://localhost:8983/solr/

bin/nutch readseg -dump crawl-20131220170613/segments/* outputdir2 -nocontent -nofetch - nogenerate -noparse -noparsetex

http://stackoverflow.com/questions/10772031/nutch-data-read-and-adding-metadata



1000 = 2013-12-30 15:07:41.878 - 2013-12-30 14:55:57.235  = ~12m => 10184 ~ 120m = 2h



GH001: Large files detected.        
Trace: cfd60cc7ce2c04811b7259cb7e2cf0d5        
See http://git.io/iEPt8g for more information.        
File WebCrawler2/apache-nutch-1-7/crawl-20131222143036/segments/20131222151007/content/part-00000/data is 121.25 MB; this exceeds GitHub's file size limit of 100 MB        
File WebCrawler2/apache-nutch-1-7/crawl-20131222143036/segments/20131223162029/content/part-00000/data is 121.24 MB; this exceeds GitHub's file size limit of 100 MB        

WebCrawler2/apache-nutch-1-7/crawl-20131222143036/segments/20131222151007/content/part-00000/data

git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch WebCrawler2/apache-nutch-1-7/crawl-20131222143036/segments/20131222151007/content/part-00000/data'  --prune-empty --tag-name-filter cat -- --all

git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch WebCrawler2/apache-nutch-1-7/crawl-20131222143036/segments/20131223162029/content/part-00000/data'  --prune-empty --tag-name-filter cat -- --all



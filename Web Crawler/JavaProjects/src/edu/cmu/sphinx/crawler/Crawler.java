
package edu.cmu.sphinx.crawler;

import java.io.IOException;
import java.util.StringTokenizer;

import javax.xml.parsers.ParserConfigurationException;

import org.apache.hadoop.util.ToolRunner;
import org.apache.nutch.crawl.Crawl;
import org.apache.nutch.indexer.solr.SolrIndexer;
import org.apache.nutch.segment.SegmentReader;
import org.apache.nutch.util.NutchConfiguration;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.embedded.EmbeddedSolrServer;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.common.params.SolrParams;
import org.apache.solr.core.CoreContainer;
import org.apache.solr.servlet.SolrRequestParsers;
import org.xml.sax.SAXException;

public class Crawler {

        public static void main(String[] args) {

                /*
                 * Arguments for crawling.
                 *
                 * -dir dir names the directory to put the crawl in.
                 *
                 * -threads threads determines the number of threads that will fetch in
                 * parallel.
                 *
                 * -depth depth indicates the link depth from the root page that should
                 * be crawled.
                 *
                 * -topN N determines the maximum number of pages that will be retrieved
                 * at each level up to the depth.
                 */

                String crawlArg = "urls -dir crawl -threads 5 -depth 3 -topN 20";

                // Run Crawl tool

                try {
                        ToolRunner.run(NutchConfiguration.create(), new Crawl(),
                                        tokenize(crawlArg));
                } catch (Exception e) {
                        e.printStackTrace();
                        return;
                }

                // Let's dump the segments we have to see what we have obtained. You
                // need to refresh your workspace to see the new folders. You can see
                // plaintext by going into dump folder and examining "dump".
                String dumpArg = "-dump crawl/segments/* dump -nocontent -nofetch -nogenerate -noparse -noparsedata";

                // Run dump
                try {
                        SegmentReader.main(tokenize(dumpArg));
                } catch (Exception e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                        return;
                }

                System.setProperty("solr.solr.home", "/home/emre/solr");
                CoreContainer.Initializer initializer = new CoreContainer.Initializer();
                CoreContainer coreContainer;

                try {
                        coreContainer = initializer.initialize();

                } catch (IOException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                        return;
                } catch (ParserConfigurationException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                        return;
                } catch (SAXException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                        return;
                }
                
                
                EmbeddedSolrServer server = new EmbeddedSolrServer(coreContainer, "");

                // Arguments for indexing
                String indexArg = "local crawl/crawldb -linkdb crawl/linkdb crawl/segments/*";

                // Run indexing tool
                try {
                        ToolRunner.run(NutchConfiguration.create(),
                                        new SolrIndexer(server), tokenize(indexArg));
                } catch (Exception e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                        return;
                }

                // Let's query for something!
                
                System.out.println("= = = = = = = = = = = = = = = = = First way to execute a query = = = = = = = = = = = = = = = = =");
		        
		        
                SolrQuery query = new SolrQuery();
                query.setQuery("*:* "); // Searching queen in query
                //query.addSortField("title", SolrQuery.ORDER.asc);
                QueryResponse rsp;
                try {
                	//to test that    
                	print(doFirstQuery(server));

                        rsp = server.query(query);
                } catch (SolrServerException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                        return;
                }

                // Display the results in the console
                SolrDocumentList docs = rsp.getResults();
                for (int i = 0; i < docs.size(); i++) {
                        System.out.println(docs.get(i).get("title").toString() + " Link: "
                                        + docs.get(i).get("url").toString());
                }

                // Shut down the container so JVM ends.
                coreContainer.shutdown();

        }

        /**
         * Helper function to convert a string into an array of strings by
         * separating them using whitespace.
         *
         * @param str
         *            string to be tokenized
         * @return an array of strings that contain a each word each
         */
        public static String[] tokenize(String str) {
                StringTokenizer tok = new StringTokenizer(str);
                String tokens[] = new String[tok.countTokens()];
                int i = 0;
                while (tok.hasMoreTokens()) {
                        tokens[i] = tok.nextToken();
                        i++;
                }

                return tokens;

        }
        
        public static QueryResponse doFirstQuery(EmbeddedSolrServer server)
    			throws SolrServerException {
    		StringBuffer request = new StringBuffer();
 
    		SolrParams solrParams = SolrRequestParsers.parseQueryString(request
    				.toString());

    		return server.query(solrParams);
    	}
        
        /**
    	 * Print documents and facets
    	 * 
    	 * @param response
    	 */
    	@SuppressWarnings("unchecked")
    	public static void print(QueryResponse response) {
//    		SolrDocumentList docs = response.getResults();
//    		if (docs != null) {
//    			System.out.println(docs.getNumFound() + " documents found, "
//    					+ docs.size() + " returned : ");
//    			for (int i = 0; i < docs.size(); i++) {
//    				SolrDocument doc = docs.get(i);
//    				System.out.println("\t" + doc.toString());
//    			}
//    		}
//
//    		List<FacetField> fieldFacets = response.getFacetFields();
//    		if (fieldFacets != null && fieldFacets.isEmpty()) {
//    			System.out.println("\nField Facets : ");
//    			for (FacetField fieldFacet : fieldFacets) {
//    				System.out.print("\t" + fieldFacet.getName() + " :\t");
//    				if (fieldFacet.getValueCount() > 0) {
//    					for (Count count : fieldFacet.getValues()) {
//    						System.out.print(count.getName() + "["
//    								+ count.getCount() + "]\t");
//    					}
//    				}
//    				System.out.println("");
//    			}
//    		}
//
//    		Map<String, Integer> queryFacets = response.getFacetQuery();
//    		if (queryFacets != null && !queryFacets.isEmpty()) {
//    			System.out.println("\nQuery facets : ");
//    			for (String queryFacet : queryFacets.keySet()) {
//    				System.out.println("\t" + queryFacet + "\t["
//    						+ queryFacets.get(queryFacet) + "]");
//    			}
//    			System.out.println("");
//    		}
//
//    		NamedList<NamedList<Object>> spellCheckResponse = (NamedList<NamedList<Object>>) response
//    				.getResponse().get("spellcheck");
//
//    		if (spellCheckResponse != null) {
//    			Iterator<Entry<String, NamedList<Object>>> wordsIterator = spellCheckResponse
//    					.iterator();
//
//    			while (wordsIterator.hasNext()) {
//    				Entry<String, NamedList<Object>> entry = wordsIterator.next();
//    				String word = entry.getKey();
//    				NamedList<Object> spellCheckWordResponse = entry.getValue();
//    				boolean correct = spellCheckWordResponse.get("frequency")
//    						.equals(1);
//    				System.out.println("Word: " + word + ",\tCorrect?: " + correct);
//    				NamedList<Integer> suggestions = (NamedList<Integer>) spellCheckWordResponse
//    						.get("suggestions");
//    				if (suggestions != null && suggestions.size() > 0) {
//    					System.out.println("Suggestions : ");
//    					Iterator<Entry<String, Integer>> suggestionsIterator = suggestions
//    							.iterator();
//    					while (suggestionsIterator.hasNext()) {
//    						System.out.println("\t"
//    								+ suggestionsIterator.next().getKey());
//    					}
//
//    				}
//    				System.out.println("");
//    			}

    		}

        
}
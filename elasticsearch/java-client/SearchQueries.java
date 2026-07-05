import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.json.JsonData;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;

import java.util.List;

public class SearchQueries {
    public static void main(String[] args) throws Exception {
        ElasticsearchClient client = new ElasticsearchClient(
                new RestClientTransport(
                        RestClient.builder(HttpHost.create("http://localhost:9200")).build(),
                        new JacksonJsonpMapper()
                )
        );

        // 简单 match 查询
        SearchResponse<IndexCRUD.Product> response = client.search(s -> s
                        .index("products")
                        .query(q -> q.match(m -> m.field("name").query("laptop"))),
                IndexCRUD.Product.class
        );
        for (Hit<IndexCRUD.Product> hit : response.hits().hits()) {
            IndexCRUD.Product p = hit.source();
            System.out.println(p.getName() + " - $" + p.getPrice());
        }

        // Bool 查询
        SearchResponse<IndexCRUD.Product> boolResponse = client.search(s -> s
                        .index("products")
                        .query(q -> q.bool(b -> b
                                .must(m -> m.match(t -> t.field("name").query("phone")))
                                .filter(f -> f.range(r -> r
                                        .field("price")
                                        .gte(JsonData.of(300))
                                        .lte(JsonData.of(1500))
                                ))
                        )),
                IndexCRUD.Product.class
        );
        System.out.println("Bool query hits: " + boolResponse.hits().total().value());
    }
}
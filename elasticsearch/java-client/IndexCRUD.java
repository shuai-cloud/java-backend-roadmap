import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._helpers.bulk.BulkIngester;
import co.elastic.clients.elasticsearch.core.*;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;

import java.util.List;

public class IndexCRUD {
    public static class Product {
        private String id;
        private String name;
        private double price;
        private List<String> tags;

        public Product() {}
        public Product(String id, String name, double price, List<String> tags) {
            this.id = id;
            this.name = name;
            this.price = price;
            this.tags = tags;
        }
        // getters and setters...
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public double getPrice() { return price; }
        public void setPrice(double price) { this.price = price; }
        public List<String> getTags() { return tags; }
        public void setTags(List<String> tags) { this.tags = tags; }
    }

    public static void main(String[] args) throws Exception {
        ElasticsearchClient client = new ElasticsearchClient(
                new RestClientTransport(
                        RestClient.builder(HttpHost.create("http://localhost:9200")).build(),
                        new JacksonJsonpMapper()
                )
        );

        // 创建索引
        client.indices().create(req -> req
                .index("products")
                .mappings(m -> m
                        .properties("name", p -> p.text(t -> t))
                        .properties("price", p -> p.double_(d -> d))
                        .properties("tags", p -> p.keyword(k -> k))
                )
        );

        // 索引文档
        Product product = new Product("p001", "Laptop", 1299.99, List.of("electronics", "computers"));
        IndexResponse response = client.index(req -> req
                .index("products")
                .id(product.getId())
                .document(product)
        );
        System.out.println("Indexed: " + response.result());

        // 获取文档
        GetResponse<Product> getResponse = client.get(g -> g.index("products").id("p001"), Product.class);
        if (getResponse.found()) {
            Product p = getResponse.source();
            System.out.println("Found: " + p.getName() + " - $" + p.getPrice());
        }

        // 更新文档
        Product updated = new Product("p001", "Gaming Laptop", 1599.99, List.of("electronics", "gaming"));
        UpdateResponse<Product> updateResponse = client.update(u -> u
                        .index("products")
                        .id("p001")
                        .doc(updated),
                Product.class
        );
        System.out.println("Updated: " + updateResponse.result());

        // 删除文档
        DeleteResponse deleteResponse = client.delete(d -> d.index("products").id("p001"));
        System.out.println("Deleted: " + deleteResponse.result());

        // 删除索引
        client.indices().delete(d -> d.index("products"));
    }
}
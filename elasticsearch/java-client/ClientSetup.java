import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;

public class ClientSetup {
    public static void main(String[] args) {
        // 单节点
        ElasticsearchClient client = new ElasticsearchClient(
                new RestClientTransport(
                        RestClient.builder(HttpHost.create("http://localhost:9200")).build(),
                        new JacksonJsonpMapper()
                )
        );

        // 多节点 + 超时配置
        RestClient restClient = RestClient.builder(
                        HttpHost.create("http://node1:9200"),
                        HttpHost.create("http://node2:9200")
                )
                .setRequestConfigCallback(builder -> builder
                        .setConnectTimeout(5000)
                        .setSocketTimeout(60000))
                .build();

        ElasticsearchClient multiNodeClient = new ElasticsearchClient(
                new RestClientTransport(restClient, new JacksonJsonpMapper())
        );

        System.out.println("Clients created successfully");
    }
}
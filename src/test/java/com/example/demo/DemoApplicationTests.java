package com.example.demo;

import com.example.demo.controller.HelloController;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class DemoApplicationTests {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private HelloController helloController;

    @Test
    void contextLoads() {
        assertThat(helloController).isNotNull();
    }

    @Test
    void homeEndpointReturnsMessage() {
        ResponseEntity<Map> response = restTemplate.getForEntity(
            "http://localhost:" + port + "/",
            Map.class
        );
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).containsKey("message");
    }

    @Test
    void healthEndpointReturnsUp() {
        ResponseEntity<Map> response = restTemplate.getForEntity(
            "http://localhost:" + port + "/health",
            Map.class
        );
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().get("status")).isEqualTo("UP");
    }

    @Test
    void helloApiEndpointReturnsMessage() {
        ResponseEntity<Map> response = restTemplate.getForEntity(
            "http://localhost:" + port + "/api/hello",
            Map.class
        );
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().get("message")).isEqualTo("Hello from the Demo API!");
    }
}

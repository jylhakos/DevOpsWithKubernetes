// https://docs.spring.io/spring-boot/

// $ curl --header "Content-Type: application/json" --data '{"name":"John Doe","email":"john.doe@example.com"}' -X POST http://localhost:8080/api/users

// $ curl --header "Content-Type: application/json" --data '{"name":"Jane Doe","email":"jane.doe@example.com"}' -X POST http://localhost:8080/api/users

// $ curl --header "Content-Type: application/json" -X GET http://localhost:8080/api/users

// $ curl --header "Content-Type: application/json" -X GET http://localhost:8080/api/users/1

package com.example.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ServerApplication {

	// https://spring.io/guides/tutorials/rest

	public static void main(String[] args) {
		SpringApplication.run(ServerApplication.class, args);
	}

}

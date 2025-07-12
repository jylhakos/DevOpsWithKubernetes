package com.example.server;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long>{

    // Method to find users by name
    java.util.List<User> findByName(String name);

    // Method to find a user by email
    User findByEmail(String email);

    //@Query("SELECT u FROM User u WHERE u.email = :email")
    //Optional<User> findByEmail(@Param("email") String email);

}

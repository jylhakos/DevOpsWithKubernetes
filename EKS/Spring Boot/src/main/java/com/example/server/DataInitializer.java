package com.example.server;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) throws Exception {
        // Check if users already exist
        if (userRepository.findByEmail("admin@example.com") == null) {
            // Create admin user
            User admin = new User();
            admin.setName("Admin User");
            admin.setEmail("admin@example.com");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole(User.Role.ADMIN);
            userRepository.save(admin);
        }

        if (userRepository.findByEmail("user@example.com") == null) {
            // Create regular user
            User user = new User();
            user.setName("Regular User");
            user.setEmail("user@example.com");
            user.setPassword(passwordEncoder.encode("user123"));
            user.setRole(User.Role.USER);
            userRepository.save(user);
        }

        System.out.println("Test users created:");
        System.out.println("Admin - Email: admin@example.com, Password: admin123");
        System.out.println("User - Email: user@example.com, Password: user123");
    }
}

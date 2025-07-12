package com.example.server;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class TestController {

    @GetMapping("/user/profile")
    public ResponseEntity<String> getUserProfile() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        return ResponseEntity.ok("User profile for: " + email);
    }

    @GetMapping("/admin/dashboard")
    public ResponseEntity<String> getAdminDashboard() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        return ResponseEntity.ok("Admin dashboard for: " + email);
    }

    @GetMapping("/user/data")
    public ResponseEntity<String> getUserData() {
        return ResponseEntity.ok("User data - accessible by USER and ADMIN roles");
    }

    @GetMapping("/admin/users")
    public ResponseEntity<String> getAllUsers() {
        return ResponseEntity.ok("All users data - accessible only by ADMIN role");
    }
}

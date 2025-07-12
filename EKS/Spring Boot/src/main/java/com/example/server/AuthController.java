package com.example.server;

import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UserService userService;

    public AuthController(AuthenticationManager authenticationManager, 
                         JwtService jwtService, 
                         UserService userService) {
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.userService = userService;
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest authRequest) {
        try {
            // Authenticate the user
            authenticate(authRequest.getEmail(), authRequest.getPassword());
            
            // Load user details
            User user = userService.findByEmail(authRequest.getEmail());
            
            // Generate JWT token
            String token = jwtService.generateToken(user);
            
            // Create and return response
            AuthResponse authResponse = new AuthResponse(
                token, 
                user.getEmail(), 
                user.getRole().name()
            );
            
            return ResponseEntity.ok(authResponse);
            
        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).build();
        }
    }

    private void authenticate(String email, String password) {
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(email, password)
        );
    }
}

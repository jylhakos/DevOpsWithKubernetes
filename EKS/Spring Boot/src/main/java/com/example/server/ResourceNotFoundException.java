package com.example.server;

public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String message, long id) {
        super(message);
    }
}
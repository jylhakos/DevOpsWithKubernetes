package com.example.server;

import java.time.LocalDateTime;
import java.util.Map;

public class ErrorResponse {

    private String statusCode;
    private LocalDateTime timestamp;
    private String message;
    private String path;
    private Map<String, String> details;

    public ErrorResponse(String statusCode, String message, String path) {
        this.statusCode = statusCode;
        this.timestamp = LocalDateTime.now();
        this.message = message;
        this.path = path;
    }
    
    public ErrorResponse(String statusCode, String message) {
        this.statusCode = statusCode;
        this.timestamp = LocalDateTime.now();
        this.message = message;
    }

    public ErrorResponse(String statusCode, String message, String path, Map<String, String> details) {
        this(statusCode, message, path);
        this.details = details;
    }

    // Getters and setters for all fields
    public String getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(String statusCode) {
        this.statusCode = statusCode;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }
    
    public Map<String, String> getDetails() {
        return details;
    }

    public void setDetails(Map<String, String> details) {
        this.details = details;
    }
}

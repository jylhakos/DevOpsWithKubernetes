package main

import (
	"net/http"
	"server/cache"
	"server/pgconnection"

	"github.com/gin-gonic/gin"
)

// HealthCheck provides a health check endpoint
func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "healthy",
		"service": "go-app",
	})
}

// ReadinessCheck provides a readiness check endpoint
func ReadinessCheck(c *gin.Context) {
	// Check database connectivity
	dbHealthy, _ := pgconnection.TryPostgres()

	// Check Redis connectivity
	redisHealthy, _ := cache.TryRedis()

	if dbHealthy && redisHealthy {
		c.JSON(http.StatusOK, gin.H{
			"status":   "ready",
			"database": "connected",
			"redis":    "connected",
		})
	} else {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status":   "not ready",
			"database": map[string]bool{"connected": dbHealthy},
			"redis":    map[string]bool{"connected": redisHealthy},
		})
	}
}

#!/bin/bash

# JWT API Test Script
# This script tests the Spring Boot JWT authentication API

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL=${1:-"http://localhost:8080"}
ADMIN_EMAIL="admin@example.com"
ADMIN_PASSWORD="admin123"
USER_EMAIL="user@example.com"
USER_PASSWORD="user123"

echo -e "${BLUE}Testing Spring Boot JWT API at: $BASE_URL${NC}"
echo

# 1. Test login with admin credentials
echo "1. Testing Admin Login..."
ADMIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }')

ADMIN_TOKEN=$(echo $ADMIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
echo "Admin Response: $ADMIN_RESPONSE"
echo "Admin Token: $ADMIN_TOKEN"
echo

# 2. Test login with user credentials
echo "2. Testing user login..."
USER_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "user123"
  }')

USER_TOKEN=$(echo $USER_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
echo "User Response: $USER_RESPONSE"
echo "User Token: $USER_TOKEN"
echo

# 3. Test access to user profile with user token
echo "3. Testing User Profile Access (User Token)..."
curl -s -X GET $BASE_URL/user/profile \
  -H "Authorization: Bearer $USER_TOKEN"
echo
echo

# 4. Test access to user profile with admin token
echo "4. Testing User Profile Access (Admin Token)..."
curl -s -X GET $BASE_URL/user/profile \
  -H "Authorization: Bearer $ADMIN_TOKEN"
echo
echo

# 5. Test access to admin endpoint with user token (should fail)
echo "5. Testing Admin Endpoint Access (User Token - Should Fail)..."
curl -s -X GET $BASE_URL/admin/users \
  -H "Authorization: Bearer $USER_TOKEN"
echo
echo

# 6. Test access to admin endpoint with admin token (should succeed)
echo "6. Testing Admin Endpoint Access (Admin Token - Should Succeed)..."
curl -s -X GET $BASE_URL/admin/users \
  -H "Authorization: Bearer $ADMIN_TOKEN"
echo
echo

# 7. Test access without token (should fail)
echo "7. Testing Access Without Token (Should Fail)..."
curl -s -X GET $BASE_URL/user/profile
echo
echo

# 8. Test create user with admin token
echo "8. Testing Create User (Admin Token)..."
curl -s -X POST $BASE_URL/admin/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "testuser@example.com",
    "password": "test123",
    "role": "USER"
  }'
echo
echo

echo "=== Test Complete ==="

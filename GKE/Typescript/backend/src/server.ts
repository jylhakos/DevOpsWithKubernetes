// src/server.ts
import express from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS for all routes
app.use(cors());

// Parse JSON bodies
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// API routes
app.get('/api', (req, res) => {
    res.json({ message: 'TypeScript Backend API', version: '1.0.0' });
});

app.get('/api/status', (req, res) => {
    res.json({ 
        status: 'running', 
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        timestamp: new Date().toISOString()
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({ message: 'TypeScript Backend Server', health: '/health', api: '/api' });
});

app.listen(PORT, () => {
    console.log(`The server is running on port ${PORT}`);
});

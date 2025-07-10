// src/server.ts
import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 5000;

// Enable CORS for all routes
app.use(cors());

app.get('/', (req, res) => {
    res.send('REST API');
});

app.listen(PORT, () => {
    console.log(`The server is running on http://localhost:${PORT}`);
});

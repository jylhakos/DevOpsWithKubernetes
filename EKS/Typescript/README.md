# Full-stack TypeScript application

This project contains a full-stack TypeScript application with Express backend and React frontend.

## Project

```
├── backend/          # Express TypeScript backend
│   ├── src/
│   │   └── server.ts # Main server file
│   ├── package.json
│   └── tsconfig.json
└── frontend/         # React TypeScript frontend
    ├── src/
    │   ├── App.tsx   # Main React component
    │   └── index.tsx # React entry point
    ├── package.json
    └── tsconfig.json
```

### Prerequisites

- Node.js (v14 or higher)
- npm

### Installation

1. Install backend dependencies:
```bash
cd backend
npm install
```

2. Install frontend dependencies:
```bash
cd frontend
npm install
```

### Running the applications

1. Start the backend server:
```bash
cd backend
npm start
```
The backend will run on `http://localhost:5000`

2. In a new terminal, start the frontend server:
```bash
cd frontend
npm start
```
The frontend will run on `http://localhost:3000`

### Features

- **Backend**: Express server with TypeScript, CORS enabled
- **Frontend**: React application with TypeScript that fetches data from the backend
- Both servers can be started with `npm start`
- Full TypeScript support with proper type checking

### Development

- Backend uses `ts-node` for development
- Frontend uses `react-scripts` for development server
- Both projects have proper TypeScript configuration

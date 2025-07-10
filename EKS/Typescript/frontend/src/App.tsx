import React, { useEffect, useState }  from 'react';
import logo from './logo.svg';
import './App.css';

function App() {
  const [message, setMessage] = useState('');

      useEffect(() => {
        const backendUrl = process.env.REACT_APP_BACKEND_URL || 'http://localhost:5000';
        fetch(`${backendUrl}/`)
          .then(response => response.text())
          .then(data => setMessage(data))
          .catch(error => console.error('Error fetching data:', error));
      }, []);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.tsx</code> and save to reload this page.
        </p>
        <p>{message}</p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
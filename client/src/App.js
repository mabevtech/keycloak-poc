import logo from './logo.svg';
import { useState, useEffect } from 'react';
import { Routes, Route, Link } from "react-router-dom";
import { useKeycloak } from '@react-keycloak/web';
import axios from 'axios';

import './App.css';

function Home() {
  const { keycloak } = useKeycloak();
  const { authenticated: isAuthenticated } = keycloak

  console.log("keycloak", keycloak);
  return (
    <div className="App-header">
      <img src={logo} className="App-logo" alt="logo" />
      <p>
        This is a react client.
      </p>
      <div className="App-link">
        {!isAuthenticated && (
          <button type="button" onClick={() => keycloak.login()}>
            Login
          </button>
        )}
        {isAuthenticated && (
          <div>
            <p>Welcome {keycloak.tokenParsed.preferred_username}!</p>
            <button type="button" onClick={() => keycloak.logout()}>
              Logout
            </button>
          </div>
        )}
      </div>
      <Link to="/contacts">Contacts page</Link>
    </div>
  );
}

function Contacts() {
  const { keycloak } = useKeycloak();
  const { authenticated: isAuthenticated, token } = keycloak
  const userName = isAuthenticated && keycloak.tokenParsed.preferred_username;
  const [contacts, setContacts] = useState(null);
  const [fetchError, setFetchError] = useState(null);

  useEffect(() => {
    let isMounted = true;
    if (isAuthenticated) {
      const fetchContacts = async () => {
        axios.get(
          "http://localhost:8060/contacts",
          { headers: { Authorization: `Bearer ${token}` } }
        ).then(response => {
          if (isMounted) {
            setContacts(response.data);
          }
        }).catch(error => {
          console.log(error);
          if (isMounted) {
            setFetchError(error.message);
          }
        });
      }
      fetchContacts();
    }
    return () => isMounted = false;
  }, [isAuthenticated, token]);

  return (
    <header className="App-header">
      <img src={logo} className="App-logo" alt="logo" />
      <p>
        This is the /contacts page.
      </p>
      <Link to="/">Back to home</Link>
      {!isAuthenticated && (
        <p>User is not authenticated. No contacts to show.</p>
      )}
      {isAuthenticated && fetchError && (
        <p>Error fetching contacts: {fetchError}</p>
      )}
      {isAuthenticated && !fetchError && !contacts && (
        <p>Fetching contacts...</p>
      )}
      {isAuthenticated && !fetchError && contacts && (
        <div>
          <p>Contacts of {userName}:</p>
          <ul>
            {contacts.map(contact => <li key={contact}>{contact}</li>)}
          </ul>
        </div>
      )}
    </header>
  );
}

function App() {
  return (
    <div className="App">
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/contacts" element={<Contacts />} />
      </Routes>
    </div>
  );
}

export default App;

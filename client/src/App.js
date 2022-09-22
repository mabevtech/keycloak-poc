import logo from './logo.svg';
import { useState, useEffect } from 'react';
import { Routes, Route, Link } from "react-router-dom";
import { useKeycloak } from '@react-keycloak/web';
import { useApiAuth } from './useApiAuth.js';
import api from './api.js';

import './App.css';

function Home() {
  const { keycloak } = useKeycloak();
  const apiAuth = useApiAuth();

  const isAuthenticated = apiAuth.isAuthenticated || keycloak.authenticated;
  const userName = keycloak.tokenParsed?.preferred_username || "user";

  const logout = async () => {
    if (keycloak.authenticated) {
      await keycloak.logout();
    }
    if (apiAuth.isAuthenticated) {
      await apiAuth.logout();
    }
  }

  return (
    <div className="App-header">
      <img src={logo} className="App-logo" alt="logo" />
      <p>
        This is a react client.
      </p>
      <div className="App-link">
        {!isAuthenticated && (
          <div>
            <button type="button" onClick={keycloak.login}>
              User login
            </button>
            <button type="button" onClick={apiAuth.login}>
              Api login
            </button>
          </div>
        )}
        {isAuthenticated && (
          <div>
            <p>Welcome {userName}!</p>
            <button type="button" onClick={logout}>
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
  const apiAuth = useApiAuth();
  const token = keycloak.token || apiAuth.token;
  const isAuthenticated = keycloak.authenticated || apiAuth.isAuthenticated;
  const userName = keycloak.tokenParsed?.preferred_username || "user";

  console.log({ keycloak, apiAuth, isAuthenticated });
  const [contacts, setContacts] = useState(null);
  const [fetchError, setFetchError] = useState(null);

  useEffect(() => {
    if (isAuthenticated) {
      const fetchContacts = async () => {
          await api.getContacts(token).then(setContacts).catch(error => {
              setFetchError(error.message);
              console.log(error.message);
          });
      }
      fetchContacts();
    }
  }, [isAuthenticated, token]);

  return (
    <header className="App-header">
      <img src={logo} className="App-logo" alt="logo" />
      <p>
        This is the /contacts page.
      </p>
      <Link to="/">Back to home</Link>
      {!isAuthenticated && (
        <p>User/Api is not authenticated. No contacts to show.</p>
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

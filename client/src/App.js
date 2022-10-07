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

  const token = apiAuth.token || keycloak.token;
  const isAuthenticated = apiAuth.isAuthenticated || keycloak.authenticated;
  const userName = keycloak.tokenParsed?.preferred_username || "user";

  const viewToken = token => {
    const buildJWTioUrl = token => {
      const publicKey = JSON.stringify({
        "e": "AQAB",
        "kty": "RSA",
        "n": "y9JHH-RtP56zUnZ_VSJxVRJTXeClPFLiudVQyKdTgrhOuinS5LvOJsuu_JgRw2WJ8--vF9TRt4Fys9VEN_k6DDrjzET_uBAEJb3fQ8jvWCzDS6BUu7q9Yl2q36Te7n_g9YWvGn41aDVHVlDuHGgpEcGSmylLL25B44Gcb2YMsYPJnIzd60IU5UqKs3VXbnXw7DKigPH7CQQtWKCDs4McJ96bqgnOALNTekBRpFswBwQ3nEIprkY1ZsuKGifVO56RzuW_PvcDTAc12P1zocQakaSpOyTTl5utVWtBnFZXWqoRJXtZTX147An5MVP3FIdUjJQkU-WrotjQni4zuxWYgw"
      });
      const baseUrl = "https://jwt.io/#debugger-io";
      return `${baseUrl}?token=${token}&publicKey=${publicKey}`;
    }
    const url = encodeURI(buildJWTioUrl(token));
    window.open(url, "_blank");
  }

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
            <button type="button" onClick={() => viewToken(token)}>
              View Token
            </button>
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

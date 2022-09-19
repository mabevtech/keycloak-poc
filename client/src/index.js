import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import { BrowserRouter } from "react-router-dom";
import { ReactKeycloakProvider } from '@react-keycloak/web'
import Keycloak from 'keycloak-js'
import { ApiAuthProvider } from './useApiAuth.js';

const eventLogger = (event, error) => {
    console.log('onKeycloakEvent', event, error)
}

const tokenLogger = (tokens) => {
    console.log('onKeycloakTokens', tokens)
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <ReactKeycloakProvider
    authClient={new Keycloak({
        url: "http://localhost:8000/",
        realm: "myrealm",
        clientId: "client_id",
        checkLoginIframe: false
    })}
    onEvent={eventLogger}
    onTokens={tokenLogger}
  >
    <ApiAuthProvider>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </ApiAuthProvider>
  </ReactKeycloakProvider>
);

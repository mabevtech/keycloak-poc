import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import { BrowserRouter } from "react-router-dom";
import { ReactKeycloakProvider } from '@react-keycloak/web'
import Keycloak from 'keycloak-js'
import { ApiAuthProvider } from './useApiAuth.js';
import config from './config.json';

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
        url: config.keycloak.url,
        realm: config.keycloak.realm,
        clientId: config.keycloak.clientId,
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

import React, { useState, useContext, createContext } from 'react';
import api from './api.js'

const apiAuthContext = createContext();

export function ApiAuthProvider({ children }) {
  const auth = useApiAuthProvider();
  return <apiAuthContext.Provider value={auth}>{children}</apiAuthContext.Provider>;
}

export const useApiAuth = () => useContext(apiAuthContext);

function useApiAuthProvider() {
  const [token, setToken] = useState('');
  const isAuthenticated = !!token;

  const login = async () => api.getTokens().then(setToken).catch(console.log);
  const logout = async () => api.getTokens().then(setToken).catch(console.log);

  return {
    login,
    logout,
    token,
    isAuthenticated,
  };
}

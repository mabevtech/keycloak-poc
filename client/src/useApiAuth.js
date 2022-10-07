import React, { useState, useContext, createContext } from 'react';
import { useCookies } from 'react-cookie';
import api from './api.js';

const apiAuthContext = createContext();

export function ApiAuthProvider({ children }) {
  const auth = useApiAuthProvider();
  return <apiAuthContext.Provider value={auth}>{children}</apiAuthContext.Provider>;
}

export const useApiAuth = () => useContext(apiAuthContext);

function useApiAuthProvider() {
  const TOKEN_KEY = 'token';
  const [cookies, setCookie, removeCookie] = useCookies([TOKEN_KEY]);

  const setToken = token => {
    const fiveMinutesFromNow = new Date(new Date().getTime() + (5 * 60 * 1000));
    setCookie(
      TOKEN_KEY, token, { expires: fiveMinutesFromNow, domain: 'localhost' }
    );
  }
  const removeToken = () => removeCookie(TOKEN_KEY);
  const token = cookies[TOKEN_KEY];
  const isAuthenticated = !!token;

  const login = async () => api.getTokens().then(setToken).catch(console.log);
  const logout = async () => api.logout().then(removeToken).catch(console.log);

  return {
    login,
    logout,
    token,
    setToken,
    removeToken,
    isAuthenticated,
  };
}

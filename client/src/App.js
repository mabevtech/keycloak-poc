import logo from './logo.svg';
import { Routes, Route } from "react-router-dom";
import { useKeycloak } from '@react-keycloak/web'
import './App.css';

function Home() {
  const { keycloak } = useKeycloak();

  console.log("keycloak", keycloak);
  return (
    <div className="App-header">
      <img src={logo} className="App-logo" alt="logo" />
      <p>
        This is a react client.
      </p>
      <div className="App-link">
        {!keycloak.authenticated && (
          <button type="button" onClick={() => keycloak.login()}>
            Login
          </button>
        )}
        {keycloak.authenticated && (
          <div>
            <p>Welcome {keycloak.tokenParsed.preferred_username}!</p>
            <button type="button" onClick={() => keycloak.logout()}>
              Logout
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

function App() {
  return (
    <div className="App">
      <Routes>
        <Route path="/" element={<Home />} />
      </Routes>
    </div>
  );
}

export default App;

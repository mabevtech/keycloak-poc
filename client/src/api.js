import axios from 'axios';
import config from './config.json';

const apiBaseUrl = config.url.api;
const resourceServerBaseUrl = config.url.resourceServer;

export default {
  getContacts: async token => {
    const config = { headers: { Authorization: `Bearer ${token}` } };
    const result = await axios.get(`${resourceServerBaseUrl}/contacts`, config)
    return result.data;
  },
  getTokens: async () => (await axios.get(`${apiBaseUrl}/token`)).data,
  logout: async () => axios.post(`${apiBaseUrl}/logout`)
}

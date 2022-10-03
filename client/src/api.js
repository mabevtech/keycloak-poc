import axios from 'axios';

export default {
  getContacts: async token => {
    const config = { headers: { Authorization: `Bearer ${token}` } };
    const result = await axios.get('http://localhost:8060/contacts', config)
    return result.data;
  },
  getTokens: async () => (await axios.get('http://localhost:8070/token')).data,
  logout: async () => axios.post('http://localhost:8070/logout')
}

import axios from 'axios';

export default {
  getContacts: async () => (await axios.get('http://localhost:8060/contacts')).data,
  getTokens: async () => (await axios.get('http://localhost:8070/token')).data,
  logout: async () => axios.get('http://localhost:8070/logout')
}

// lib/api.ts
import axios from 'axios';

// Chave para buscar o token no localStorage
const AUTH_TOKEN_KEY = 'camaar-auth-token';

export const api = axios.create({
  baseURL: 'http://localhost:3000/api/v1',
  // ===============================================================
  // ▼▼▼ ADICIONE ESTE BLOCO DE HEADERS PADRÃO ▼▼▼
  // ===============================================================
  headers: {
    // Garante que todas as requisições feitas por esta instância
    // informem ao Rails que esperam uma resposta JSON.
    'Accept': 'application/json'
  }
  // ===============================================================
});

// O interceptor adiciona o token de autenticação a cada requisição.
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem(AUTH_TOKEN_KEY);

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

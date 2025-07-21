// lib/api.ts
import axios from 'axios';

// Cria uma instância do Axios com a URL base da sua API Rails.
export const api = axios.create({
  baseURL: 'http://localhost:3000/api/v1',
});

// Isso é um "interceptor": um código que é executado ANTES de cada
// requisição ser enviada. Ele é perfeito para adicionar o token.
api.interceptors.request.use(
  (config) => {
    // Tenta pegar o token de autenticação do localStorage.
    // ATENÇÃO: Troque 'seu_app_auth_token' pela chave real que você usa!
    const token = localStorage.getItem('seu_app_auth_token');

    // Se o token existir, ele é adicionado ao cabeçalho 'Authorization'.
    // O backend (Devise) usará este cabeçalho para autenticar o usuário.
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
  },
  (error) => {
    // Se houver um erro na configuração, ele é rejeitado.
    return Promise.reject(error);
  }
);
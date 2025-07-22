// Caminho: src/contexts/AuthContext.tsx
'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api'; // Nossa instância do Axios para rotas da API
import axios from 'axios'; // Importamos o Axios diretamente para a chamada de login

interface User {
  id: number;
  email: string;
  admin: boolean;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (credentials: { email: string; password: string }) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const AUTH_TOKEN_KEY = 'camaar-auth-token';

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const loadUserFromToken = async () => {
      const token = localStorage.getItem(AUTH_TOKEN_KEY);
      console.log('>>> AuthContext: Verificando token no localStorage:', token ? 'Encontrado' : 'Não encontrado');

      if (token) {
        try {
          const response = await api.get('/sessions/current_user');
          console.log('>>> AuthContext: Usuário validado com sucesso:', response.data.user);
          setUser(response.data.user);
        } catch (error) {
          console.error('>>> AuthContext: Token inválido ou expirado. Limpando.', error);
          localStorage.removeItem(AUTH_TOKEN_KEY);
          setUser(null);
        }
      }
      setIsLoading(false);
    };

    loadUserFromToken();
  }, []);

  const login = async (credentials: { email: string; password: string }) => {
    try {
      const response = await axios.post(
        'http://localhost:3000/usuarios/sign_in',
        {
          usuario: {
            login: credentials.email,
            password: credentials.password,
          },
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        }
      );

      // DEBUG: Vamos ver exatamente o que o servidor respondeu
      console.log('>>> AuthContext: Resposta completa do login:', response);

      const token = response.headers.authorization?.split(' ')[1];
      
      // ===============================================================
      // ▼▼▼ CORREÇÃO PRINCIPAL AQUI ▼▼▼
      // ===============================================================
      // Verificamos se `response.data.data` existe antes de usá-lo.
      const userData = response.data?.data;

      if (token && userData) {
        console.log('>>> AuthContext: Login bem-sucedido. Token e dados do usuário encontrados.');
        localStorage.setItem(AUTH_TOKEN_KEY, token);
        setUser(userData);

        if (userData.admin) {
          router.push('/admin');
        } else {
          router.push('/aluno');
        }
      } else {
        // Se o token ou os dados do usuário não vieram na resposta, algo está errado.
        console.error('>>> AuthContext: Resposta 200 OK, mas token ou dados do usuário ausentes.', { token, userData });
        throw new Error('Resposta de login inválida do servidor.');
      }
    } catch (error) {
      console.error('>>> AuthContext: Falha no login:', error);
      throw error;
    }
  };

  const logout = async () => {
    try {
      console.log('>>> AuthContext: Iniciando logout...');
      await axios.delete('http://localhost:3000/usuarios/sign_out', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem(AUTH_TOKEN_KEY)}`,
          Accept: 'application/json',
        },
      });
    } catch (error) {
      console.error('>>> AuthContext: Erro ao fazer logout no servidor (ignorado no frontend):', error);
    } finally {
      console.log('>>> AuthContext: Limpando dados do frontend.');
      setUser(null);
      localStorage.removeItem(AUTH_TOKEN_KEY);
      router.replace('/login');
    }
  };

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, isLoading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth deve ser usado dentro de um AuthProvider');
  }
  return context;
};

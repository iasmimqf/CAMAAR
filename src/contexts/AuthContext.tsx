// Caminho: src/contexts/AuthContext.tsx
'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useRouter, usePathname } from 'next/navigation';

interface User {
  id: number;
  email: string;
  admin: boolean;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean; // Valor calculado que precisamos no useEffect
  isLoading: boolean;
  login: (userData: User) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();
  const pathname = usePathname();

  // >>> AQUI ESTÁ A CORREÇÃO PRINCIPAL: Calcular isAuthenticated no escopo do componente <<<
  const isAuthenticated = !!user; // Calcula o valor de isAuthenticated aqui

  const API_URL = 'http://localhost:3000';

  useEffect(() => {
    const checkUserSession = async () => {
      console.log('>>> AuthProvider: Iniciando verificação de sessão (pathname: ' + pathname + ')');
      try {
        const response = await fetch(`${API_URL}/api/v1/sessions/current_user`, {
          credentials: 'include',
        });
        console.log('>>> AuthProvider: Resposta do current_user. Status:', response.status);

        if (response.ok) {
          const data = await response.json();
          console.log('>>> AuthProvider: Usuário retornado pelo backend:', data.user);
          setUser(data.user);
        } else {
          console.log('>>> AuthProvider: Backend informou que NÃO há usuário logado (status não OK).');
          setUser(null);
          if (pathname !== '/login') {
            console.log('>>> AuthProvider: Forçando redirecionamento para /login.');
            router.replace('/login');
          }
        }
      } catch (error) {
        console.error('>>> AuthProvider: ERRO na requisição current_user (rede, CORS):', error);
        setUser(null);
        if (pathname !== '/login') {
          console.log('>>> AuthProvider: Forçando redirecionamento para /login (erro na requisição).');
          router.replace('/login');
        }
      } finally {
        setIsLoading(false);
        setTimeout(() => {
          console.log('>>> AuthProvider: Verificação finalizada. Estado FINAL: user=', user, 'isAuthenticated=', !!user, 'isLoading=', isLoading);
        }, 50);
      }
    };

    // Só executa a verificação se o app ainda estiver carregando OU se o usuário ainda não foi definido.
    if (isLoading || (user === null && !isAuthenticated)) {
        checkUserSession();
    }
  }, [isLoading, user, isAuthenticated, pathname, router]); // Agora 'isAuthenticated' está definido no escopo

  const login = (userData: User) => {
    setUser(userData);
    if (userData.admin) {
      router.push('/admin');
    } else {
      router.push('/aluno');
    }
  };

  const logout = async () => {
    try {
      console.log('>>> AuthContext: Iniciando requisição de logout...');
      const response = await fetch(`${API_URL}/usuarios/sign_out`, {
        method: 'DELETE',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      });

      console.log('>>> AuthContext: Resposta do logout. Status:', response.status, 'StatusText:', response.statusText);

      if (response.ok || response.status === 401) {
        console.log('>>> AuthContext: Logout no servidor processado (OK ou 401). Limpando frontend e redirecionando.');
        setUser(null);
        router.replace('/login');
      } else {
        const errorBody = await response.text();
        console.error('>>> AuthContext: Falha INESPERADA ao fazer logout no servidor. Status:', response.status, 'Body:', errorBody);
        setUser(null);
        router.replace('/login');
      }
    } catch (error) {
      console.error('>>> AuthContext: Erro de rede ou CORS durante o logout:', error);
      setUser(null);
      router.replace('/login');
    }
  };

  return (
    <AuthContext.Provider value={{ user, isAuthenticated, isLoading, login, logout }}>
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
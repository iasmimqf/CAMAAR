// Caminho: src/app/login/page.tsx
'use client';

import React, { useState } from 'react';
import { useRouter } from "next/navigation";
import { useAuth } from '@/contexts/AuthContext'; // ADICIONADO: Importe o hook de autenticação

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export default function LoginPage() {
  const { login: authContextLogin } = useAuth(); // RENOMEADO para evitar conflito com o estado 'login'
  const [email, setEmail] = useState(''); // Usando 'email' para o campo de login, mais comum com Devise
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  const API_URL = 'http://localhost:3000'; // URL do seu backend Rails

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      const response = await fetch(`${API_URL}/usuarios/sign_in`, { // Removido '.json' se não for estritamente necessário
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          usuario: {
            login: email, // Use 'email' aqui, pois 'login' é o campo que você usa no Devise
            password: password,
          },
        }),
        credentials: 'include', // <<< ADICIONADO: ESSENCIAL para cookies de sessão
      });

      const data = await response.json();

      if (response.ok) {
        // Login bem-sucedido
        console.log('Login bem-sucedido no servidor:', data);
        // Chame a função 'login' do AuthContext para atualizar o estado global
        // e fazer o redirecionamento correto.
        authContextLogin({
          id: data.data.id,
          email: data.data.email,
          admin: data.data.admin, // Adapte para o campo correto que indica se é admin
        });
        // O redirecionamento será feito pelo AuthContext, então não precisamos de router.push aqui.
      } else {
        // Login falhou
        const errorMessage = data.error || 'Login ou senha inválidos.';
        console.error('Erro no login:', errorMessage);
        setError(errorMessage);
      }
    } catch (err) {
      // Erro de rede ou servidor
      console.error('Erro de rede durante o login:', err);
      setError('Não foi possível conectar ao servidor. Tente novamente mais tarde.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-300 flex items-center justify-center p-4">
      <div className="w-full max-w-4xl bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="flex min-h-[500px]">

          {/* Lado Esquerdo - Formulário de Login */}
          <div className="flex-1 p-8 flex flex-col justify-center">
            <div className="w-full max-w-sm mx-auto">
              <h1 className="text-2xl font-bold text-gray-900 mb-8 text-center">
                LOGIN
              </h1>

              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="space-y-2">
                  <Label htmlFor="email" className="text-sm font-medium text-gray-700">
                    Email ou Matrícula
                  </Label>
                  <Input
                    id="email" // Alterado para 'email' para consistência
                    name="email"
                    type="text"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="aluno@aluno.unb.br ou sua matrícula"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    required
                    disabled={isLoading}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="password" className="text-sm font-medium text-gray-700">
                    Senha
                  </Label>
                  <Input
                    id="password"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="Digite sua senha"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    required
                    disabled={isLoading}
                  />
                </div>

                {/* Mensagem de Erro */}
                {error && (
                  <p className="text-sm text-red-600 text-center">{error}</p>
                )}

                <Button
                  type="submit"
                  className="w-full bg-green-500 hover:bg-green-600 text-white font-medium py-2 px-4 rounded-md transition-colors duration-200"
                  disabled={isLoading}
                >
                  {isLoading ? 'Entrando...' : 'Entrar'}
                </Button>

                <div className="text-center mt-4">
                  <button
                    type="button"
                    onClick={() => router.push('/login/recuperar-senha')}
                    className="text-sm text-purple-600 hover:text-purple-800 underline transition-colors duration-200"
                  >
                    Esqueceu sua senha?
                  </button>
                </div>
              </form>
            </div>
          </div>

          {/* Lado Direito - Mensagem de Boas-Vindas */}
          <div className="flex-1 bg-purple-700 flex-col items-center justify-center p-8 hidden md:flex">
            <div className="text-center">
              <h2 className="text-4xl font-bold text-white leading-tight">
                Bem-vindo
                <br />
                ao
                <br />
                CAMAAR
              </h2>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
'use client';

import type React from 'react';
import { useState } from 'react';
import { useRouter } from "next/navigation";

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export default function LoginPage() {
  const [login, setLogin] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      // ATENÇÃO: Verifique se a porta do seu servidor Rails é 3000
      const response = await fetch('http://localhost:3000/usuarios/sign_in.json', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          usuario: {
            login: login,
            password: password,
          },
        }),
      });

      const data = await response.json();

      if (response.ok) {
        // Login bem-sucedido
        if (data.data.admin) {
          router.push('/admin');
        } else {
          router.push('/aluno');
        }
      } else {
        // Login falhou
        setError(data.error || 'Login ou senha inválidos.');
      }
    } catch (err) {
      // Erro de rede ou servidor
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
                  <Label htmlFor="login" className="text-sm font-medium text-gray-700">
                    Email ou Matrícula
                  </Label>
                  <Input
                    id="login"
                    name="login"
                    type="text"
                    value={login}
                    placeholder="aluno@aluno.unb.br ou sua matrícula"
                    onChange={(e) => setLogin(e.target.value)}
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
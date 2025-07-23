'use client';

import React, { useState } from 'react';
import { useRouter } from "next/navigation";
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner'; // <<< 1. Importe o toast
import { Loader2 } from 'lucide-react';

export default function LoginPage() {
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  // ===============================================================
  // ▼▼▼ FUNÇÃO ATUALIZADA PARA USAR 'toast' ▼▼▼
  // ===============================================================
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      // A função 'login' do AuthContext já faz todo o trabalho
      await login({ email, password });
    } catch (err) {
      // Se a função 'login' do contexto der erro, nós o capturamos aqui
      // e mostramos um toast elegante em vez de um texto vermelho.
      console.error('Erro de login na página:', err);
      toast.error('Login ou senha inválidos. Verifique as suas credenciais.');
    } finally {
      setIsLoading(false);
    }
  };
  // ===============================================================

  return (
    <div className="min-h-screen bg-gray-300 flex items-center justify-center p-4">
      <div className="w-full max-w-4xl bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="flex min-h-[500px]">
          {/* Lado Esquerdo - Formulário de Login */}
          <div className="flex-1 p-8 flex flex-col justify-center">
            <div className="w-full max-w-sm mx-auto">
              <h1 className="text-2xl font-bold text-gray-900 mb-8 text-center">LOGIN</h1>
              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="space-y-2">
                  <Label htmlFor="email" className="text-sm font-medium text-gray-700">
                    Email ou Matrícula
                  </Label>
                  <Input
                    id="email"
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

                {/* O elemento de mensagem de erro foi removido daqui */}

                <Button
                  type="submit"
                  className="w-full bg-green-500 hover:bg-green-600 text-white font-medium py-2 px-4 rounded-md transition-colors duration-200"
                  disabled={isLoading}
                >
                  {isLoading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                  {isLoading ? 'A entrar...' : 'Entrar'}
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
                Bem-vindo<br />ao<br />CAMAAR
              </h2>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
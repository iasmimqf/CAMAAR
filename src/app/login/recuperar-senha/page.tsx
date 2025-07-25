'use client';

import type React from 'react';
import { useState } from 'react';
import { useRouter } from "next/navigation";
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner'; // <<< 1. Importe o toast
import { Loader2 } from 'lucide-react';

export default function RecoverPasswordPage() {
  const [login, setLogin] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false); // Estado para desabilitar o form após sucesso
  const router = useRouter();

  // ===============================================================
  // ▼▼▼ FUNÇÃO ATUALIZADA PARA USAR 'toast' ▼▼▼
  // ===============================================================
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      // A chamada à API continua a mesma
      const response = await fetch('http://localhost:3000/api/v1/password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          login: login,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        toast.success(data.message);
        setIsSuccess(true); // Desabilita o formulário após o sucesso
      } else {
        toast.error(data.error || 'Ocorreu um erro. Tente novamente.');
      }
    } catch (err) {
      toast.error('Não foi possível conectar ao servidor. Tente novamente mais tarde.');
    } finally {
      setIsLoading(false);
    }
  };
  // ===============================================================

  return (
    <div className="min-h-screen bg-gray-300 flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-white rounded-lg shadow-lg p-8">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            Recuperar Senha
          </h1>
          <p className="text-sm text-gray-600 mb-8">
            Digite seu e-mail ou matrícula e enviaremos um link para você redefinir sua senha.
          </p>
        </div>

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
              placeholder="Digite seu e-mail ou matrícula"
              onChange={(e) => setLogin(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              required
              disabled={isLoading || isSuccess}
            />
          </div>

          {/* Os elementos de mensagem e erro foram removidos daqui */}

          <Button
            type="submit"
            className="w-full bg-purple-600 hover:bg-purple-700 text-white font-medium py-2 px-4 rounded-md transition-colors duration-200"
            disabled={isLoading || isSuccess}
          >
            {isLoading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
            {isSuccess ? 'Link Enviado!' : (isLoading ? 'Enviando...' : 'Enviar Link de Recuperação')}
          </Button>

          <div className="text-center mt-4">
            <button
              type="button"
              onClick={() => router.push('/login')}
              className="text-sm text-gray-600 hover:text-gray-800 underline transition-colors duration-200"
            >
              Voltar para o Login
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
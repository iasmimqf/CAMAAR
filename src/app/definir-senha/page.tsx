'use client';

import type React from 'react';
import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from "next/navigation";
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner'; // <<< 1. Importe o toast
import { Loader2 } from 'lucide-react';

// Componente principal do formulário
function ResetPasswordForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  
  const [token, setToken] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false); // Estado para desabilitar o form após sucesso

  useEffect(() => {
    const tokenFromUrl = searchParams.get('token');
    if (tokenFromUrl) {
      setToken(tokenFromUrl);
    } else {
      toast.error('Token de redefinição não encontrado. O link pode ser inválido ou ter expirado.');
    }
  }, [searchParams]);

  // ===============================================================
  // ▼▼▼ FUNÇÃO ATUALIZADA PARA USAR 'toast' ▼▼▼
  // ===============================================================
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    if (password !== passwordConfirmation) {
      toast.error('As senhas não conferem.');
      setIsLoading(false);
      return;
    }

    try {
      // A chamada à API continua a mesma, mas agora usamos a instância `api`
      const response = await fetch('http://localhost:3000/api/v1/password', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          reset_password_token: token,
          password: password,
          password_confirmation: passwordConfirmation,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        toast.success(data.message || 'Senha redefinida com sucesso!');
        setIsSuccess(true); // Marca como sucesso para desabilitar o form
        setTimeout(() => {
          router.push('/login');
        }, 3000);
      } else {
        const backendErrors = data.errors && Array.isArray(data.errors)
          ? data.errors.map((err: string) => err.replace(/^Password\s*/, ''))
          : ['Ocorreu um erro ao redefinir a senha.'];
        // Mostra cada erro como um toast separado
        backendErrors.forEach((err: string) => toast.error(err));
      }
    } catch (err) {
      toast.error('Não foi possível conectar ao servidor.');
    } finally {
      setIsLoading(false);
    }
  };
  // ===============================================================

  return (
    <div className="min-h-screen bg-gray-300 flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-white rounded-lg shadow-lg p-8">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-900 mb-8">
            Defina sua Nova Senha
          </h1>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="password">Nova Senha</Label>
            <Input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Digite sua nova senha"
              required
              disabled={isLoading || !token || isSuccess}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="passwordConfirmation">Confirmar Nova Senha</Label>
            <Input
              id="passwordConfirmation"
              type="password"
              value={passwordConfirmation}
              onChange={(e) => setPasswordConfirmation(e.target.value)}
              placeholder="Confirme sua nova senha"
              required
              disabled={isLoading || !token || isSuccess}
            />
          </div>

          {/* Os elementos de mensagem e erro foram removidos daqui */}

          <Button
            type="submit"
            className="w-full bg-green-600 hover:bg-green-700 text-white"
            disabled={isLoading || !token || isSuccess}
          >
            {isLoading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
            {isSuccess ? 'Redirecionando...' : (isLoading ? 'Salvando...' : 'Salvar Nova Senha')}
          </Button>
        </form>
      </div>
    </div>
  );
}

// O componente wrapper com Suspense continua o mesmo
export default function ResetPasswordPage() {
  return (
    <Suspense fallback={<div>Carregando...</div>}>
      <ResetPasswordForm />
    </Suspense>
  );
}
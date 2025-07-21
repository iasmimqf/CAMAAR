'use client';

import type React from 'react';
import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from "next/navigation";

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

// Componente principal do formulário
function ResetPasswordForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  
  // Estados para os campos do formulário e controle de UI
  const [token, setToken] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  
  const [message, setMessage] = useState('');
  // 'errors' é um array de strings para exibir múltiplas mensagens de erro
  const [errors, setErrors] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  // Efeito que roda uma vez quando a página carrega para pegar o token da URL
  useEffect(() => {
    const tokenFromUrl = searchParams.get('token');
    if (tokenFromUrl) {
      setToken(tokenFromUrl);
    } else {
      // Se não houver token, adiciona uma mensagem de erro ao array
      setErrors(['Token de redefinição não encontrado. O link pode ser inválido ou ter expirado.']);
    }
  }, [searchParams]);

  // Função chamada ao submeter o formulário
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // Limpa as mensagens de erro e sucesso antes de uma nova tentativa
    setErrors([]);
    setMessage('');
    setIsLoading(true);

    // Validação simples no frontend para senhas que não conferem
    if (password !== passwordConfirmation) {
      setErrors(['As senhas não conferem.']); // Adiciona ao array de erros
      setIsLoading(false);
      return;
    }

    try {
      // Chama a API que criamos no Rails para redefinir a senha
      const response = await fetch('http://localhost:3000/api/v1/password', {
        method: 'PUT', // Usando PUT conforme nossa rota
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          reset_password_token: token,
          password: password,
          password_confirmation: passwordConfirmation,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        setMessage(data.message || 'Senha redefinida com sucesso!');
        // Redireciona para o login após 3 segundos
        setTimeout(() => {
          router.push('/login');
        }, 3000);
      } else {
        // Extrai os erros do array que o Rails envia e remove o prefixo "Password "
        const backendErrors = data.errors && Array.isArray(data.errors)
          ? data.errors.map((err: string) => err.replace(/^Password\s*/, ''))
          : ['Ocorreu um erro ao redefinir a senha.'];
        setErrors(backendErrors);
      }
    } catch (err) {
      setErrors(['Não foi possível conectar ao servidor.']); // Adiciona ao array de erros
    } finally {
      setIsLoading(false);
    }
  };

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
              disabled={isLoading || !token}
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
              disabled={isLoading || !token}
            />
          </div>

          {message && (
            <p className="text-sm text-green-600 text-center bg-green-50 p-3 rounded-md">{message}</p>
          )}
          {/* Renderiza uma lista de erros se houver algum */}
          {errors.length > 0 && (
            <ul className="text-sm text-red-600 bg-red-50 p-3 rounded-md list-disc list-inside">
              {errors.map((err, index) => (
                <li key={index}>{err}</li>
              ))}
            </ul>
          )}

          <Button
            type="submit"
            className="w-full bg-green-600 hover:bg-green-700 text-white"
            disabled={isLoading || !token || !!message}
          >
            {isLoading ? 'Salvando...' : 'Salvar Nova Senha'}
          </Button>
        </form>
      </div>
    </div>
  );
}

// O Next.js recomenda usar um "Suspense Boundary" ao usar useSearchParams.
// Este componente wrapper garante que tudo funcione corretamente.
export default function ResetPasswordPage() {
  return (
    <Suspense fallback={<div>Carregando...</div>}>
      <ResetPasswordForm />
    </Suspense>
  );
}
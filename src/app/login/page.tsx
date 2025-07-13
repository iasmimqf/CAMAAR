'use client';

import type React from 'react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { useState } from 'react';
import { useRouter } from "next/navigation"


export default function LoginPage() {
  const [login, setLogin] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(''); // State to hold the error message
  const [isLoading, setIsLoading] = useState(false); // State to disable button during login
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(''); // Clear previous errors
    setIsLoading(true); // Disable the button

    try {
      const response = await fetch('http://localhost:3001/usuarios/sign_in.json', {
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
        // SUCCESSFUL LOGIN
        // The backend should return user data, including an 'admin' flag.
        if (data.data.admin) {
          // If admin, redirect to admin page
          router.push('/admin'); // This is your AdminPage()
        } else {
          // If not admin, redirect to user page
          router.push('/aluno'); // This is your AlunoPage()
        }
      } else {
        // FAILED LOGIN
        // Set the error message from the server's JSON response
        setError(data.error || 'Login ou senha inválidos.');
      }
    } catch (err) {
      // Network or server error
      setError('Não foi possível conectar ao servidor. Tente novamente mais tarde.');
    } finally {
      setIsLoading(false); // Re-enable the button
    }
  };


  return (
    <div className="min-h-screen bg-gray-300 flex items-center justify-center p-4">
      <div className="w-full max-w-4xl bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="flex min-h-[500px]">
          {/* lado esquerdo - login */}
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
                      id="login"  // Mudamos para um nome genérico
                      name="login" // Adicionamos name para formulários
                      type="text"  // Tipo genérico para ambos
                      value={login} // Estado renomeado para algo mais genérico
                      placeholder="aluno@aluno.unb.br ou sua matrícula"
                      onChange={(e) => setLogin(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      required
                  />
                </div>

                <div className="space-y-2">
                  <Label
                    htmlFor="password"
                    className="text-sm font-medium text-gray-700"
                  >
                    Senha
                  </Label>
                  <Input
                    id="password"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="Password"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    required
                  />
                </div>

                <Button
                  type="submit"
                  className="w-full bg-green-500 hover:bg-green-600 text-white font-medium py-2 px-4 rounded-md transition-colors duration-200"
                >
                  Entrar
                </Button>
                <div className="text-center mt-4">
                  <button
                    type="button"
                    onClick={() => router.push('/login/recuperar-senha')}
                    className="text-sm text-purple-600 hover:text-purple-800 underline transition-colors duration-200"
                  >
                    Esqueci senha
                  </button>
                </div>
              </form>
            </div>
          </div>

          {/* lado direito - mensagem */}
          <div className="flex-1 bg-purple-700 flex items-center justify-center p-8">
            <div className="text-center">
              <h2 className="text-4xl font-bold text-white leading-tight">
                Bem vindo
                <br />
                ao
                <br />
                Camaar
              </h2>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

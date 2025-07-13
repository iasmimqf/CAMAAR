'use client';

import type React from 'react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { useState } from 'react';
import { useRouter } from "next/navigation"


export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // logica do login aqui
    console.log('Login attempt:', { email, password });
  };

  const router = useRouter()

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
                  <Label
                    htmlFor="email"
                    className="text-sm font-medium text-gray-700"
                  >
                    Email
                  </Label>
                  <Input
                    id="email"
                    type="email"
                    value={email}
                    placeholder="aluno@aluno.unb.br"
                    onChange={(e) => setEmail(e.target.value)}
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

// Caminho: src/app/acesso-negado/page.tsx
'use client';

import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { ShieldAlert } from 'lucide-react';

export default function AcessoNegadoPage() {
  const router = useRouter();

  return (
    <div className="min-h-screen bg-gray-100 flex flex-col items-center justify-center p-4">
      <div className="w-full max-w-md bg-white rounded-lg shadow-md p-8 text-center">
        <div className="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-red-100">
          <ShieldAlert className="h-8 w-8 text-red-600" aria-hidden="true" />
        </div>
        
        <h1 className="mt-6 text-2xl font-bold text-gray-900">
          Acesso Negado
        </h1>
        
        <p className="mt-2 text-gray-600">
          Você não tem permissão para acessar esta página.
        </p>
        
        <p className="mt-4 text-sm text-gray-500">
          Este recurso é restrito a administradores. Se você acredita que isso é um erro, por favor, entre em contato com o suporte.
        </p>
        
        <Button
          onClick={() => router.push('/')} // Redireciona para a página inicial
          className="mt-8 w-full bg-purple-700 hover:bg-purple-800 text-white"
        >
          Voltar para a Página Inicial
        </Button>
      </div>
    </div>
  );
}

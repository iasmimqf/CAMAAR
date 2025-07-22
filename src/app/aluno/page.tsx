'use client';

import { useAuth } from '@/contexts/AuthContext';
import { Search, Menu, X, LogOut, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api'; // Importamos nosso cliente de API

// Tipagem para os dados que esperamos da API
interface FormularioPendente {
  id: number;
  nome: string;
  prazo: string;
  disciplina: string;
  turma: string;
}

export default function AlunoPage() {
  const { user, isAuthenticated, isLoading, logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const router = useRouter();

  // Novo estado para armazenar os formulários vindos da API
  const [formularios, setFormularios] = useState<FormularioPendente[]>([]);
  // Novo estado para o carregamento da lista de formulários
  const [isListLoading, setIsListLoading] = useState(true);

  // Efeito para buscar os formulários pendentes quando a página carrega
  useEffect(() => {
    const fetchFormularios = async () => {
      try {
        // Chama o endpoint GET /api/v1/formularios
        // O backend já sabe que, se não for admin, deve retornar apenas os pendentes.
        const response = await api.get('/formularios');
        setFormularios(response.data);
      } catch (error) {
        console.error("Falha ao buscar formulários pendentes:", error);
        // Você pode adicionar um estado de erro aqui se desejar
      } finally {
        setIsListLoading(false);
      }
    };

    // Só busca os formulários se o usuário estiver autenticado e não for admin
    if (isAuthenticated && !user?.admin) {
      fetchFormularios();
    }
  }, [isAuthenticated, user]); // Depende do estado de autenticação

  // Lógica de proteção de rota (mantida do seu código)
  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <div className="text-center">
          <Loader2 className="h-8 w-8 animate-spin text-purple-700 mx-auto mb-4" />
          <p className="text-lg font-semibold text-gray-700">A carregar...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated || user?.admin) {
    // O AuthContext ou um layout superior já deve ter redirecionado
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <p className="text-lg font-semibold text-gray-700">A redirecionar...</p>
      </div>
    );
  }

  const renderContent = () => {
    if (isListLoading) {
      return (
        <div className="flex justify-center items-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-purple-700" />
          <p className="ml-4 text-gray-600">A procurar avaliações pendentes...</p>
        </div>
      );
    }

    if (formularios.length === 0) {
      return (
        <div className="text-center py-16">
          <h3 className="text-xl font-semibold text-gray-700">Nenhuma avaliação pendente.</h3>
          <p className="text-gray-500 mt-2">Você está em dia com todas as suas avaliações!</p>
        </div>
      );
    }

    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {formularios.map((form) => (
          <div
            key={form.id}
            className="bg-white rounded-lg shadow-sm border p-6 hover:shadow-md transition-shadow cursor-pointer"
            // Ao clicar, redireciona para a página de resposta dinâmica
            onClick={() => router.push(`/aluno/formularios/${form.id}`)}
          >
            <div className="space-y-2">
              <h3 className="font-semibold text-gray-900 text-lg">{form.nome}</h3>
              <p className="text-sm text-gray-500">
                {form.disciplina} - {form.turma}
              </p>
              <p className="font-medium text-gray-700 mt-4">
                Prazo: {form.prazo}
              </p>
            </div>
          </div>
        ))}
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gray-200">
      {/* Header */}
      <header className="bg-white shadow-sm border-b relative z-[60]">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => setSidebarOpen(!sidebarOpen)}>
              {sidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </Button>
            <h1 className="text-lg font-medium">Avaliações Pendentes</h1>
          </div>
          <div className="flex items-center gap-4">
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="w-8 h-8 bg-purple-700 rounded-full flex items-center justify-center text-white font-medium text-sm hover:bg-purple-800 transition-colors">U</Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-40 z-[70]">
                <DropdownMenuItem onClick={logout} className="cursor-pointer text-red-600 focus:text-red-600">
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>Sair</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </header>

      <div className="flex relative">
        {/* Sidebar */}
        <aside className={`fixed top-[73px] bottom-0 left-0 z-50 w-48 bg-white shadow-lg transform transition-transform duration-300 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
          <nav className="bg-white flex-1 py-2">
            <div className="space-y-1">
              <button onClick={() => router.push('/aluno')} className="w-full text-left px-4 py-3 text-sm font-medium bg-purple-700 text-white">
                Avaliações
              </button>
            </div>
          </nav>
        </aside>

        {/* Main Content */}
        <main className="flex-1 p-6 w-full md:pl-56">
          {renderContent()}
        </main>
      </div>
    </div>
  );
}
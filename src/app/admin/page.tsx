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
interface Formulario {
  id: number;
  nome: string;
  prazo: string;
  disciplina: string;
  turma: string;
}

export default function AdminPage() {
  const { user, isAuthenticated, isLoading, logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const router = useRouter();

  // Novos estados para a lista de formulários
  const [formularios, setFormularios] = useState<Formulario[]>([]);
  const [isListLoading, setIsListLoading] = useState(true);

  // Efeito para buscar os formulários da API
  useEffect(() => {
    const fetchFormularios = async () => {
      try {
        // A chamada é a mesma da página do aluno.
        // O backend diferencia a resposta com base no `current_user`.
        const response = await api.get('/formularios');
        setFormularios(response.data);
      } catch (error) {
        console.error("Falha ao buscar formulários para o admin:", error);
      } finally {
        setIsListLoading(false);
      }
    };

    // Só busca os formulários se o usuário for um admin autenticado.
    if (isAuthenticated && user?.admin) {
      fetchFormularios();
    }
  }, [isAuthenticated, user]);

  // Lógica de proteção de rota (o AdminLayout já faz isso, mas é uma boa prática)
  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <Loader2 className="h-8 w-8 animate-spin text-purple-700" />
      </div>
    );
  }

  // Função para renderizar o conteúdo principal da página
  const renderContent = () => {
    if (isListLoading) {
      return (
        <div className="flex justify-center items-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-purple-700" />
          <p className="ml-4 text-gray-600">A carregar formulários...</p>
        </div>
      );
    }

    if (formularios.length === 0) {
      return (
        <div className="text-center py-16">
          <h3 className="text-xl font-semibold text-gray-700">Nenhum formulário encontrado.</h3>
          <p className="text-gray-500 mt-2">Quando formulários forem criados, eles aparecerão aqui.</p>
        </div>
      );
    }

    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {formularios.map((form) => (
          <div
            key={form.id}
            className="bg-white rounded-lg shadow-sm border p-6 hover:shadow-md transition-shadow cursor-pointer"
            // IMPORTANTE: O admin usa a MESMA página de resposta que o aluno.
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
            <h1 className="text-lg font-medium">Avaliações (Admin)</h1>
          </div>
          <div className="flex items-center gap-4">
            {/* ... seu código do dropdown de usuário ... */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="w-8 h-8 bg-purple-700 rounded-full flex items-center justify-center text-white font-medium text-sm hover:bg-purple-800 transition-colors">
                  A {/* de Admin */}
                </Button>
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
              <button onClick={() => router.push('/admin')} className="w-full text-left px-4 py-3 text-sm font-medium bg-purple-700 text-white">
                Avaliações
              </button>
              <button onClick={() => router.push('/admin/gerenciamento')} className="w-full text-left px-4 py-3 text-sm font-medium text-gray-700 hover:bg-gray-100">
                Gerenciamento
              </button>
              {/* Botão de Resultados foi removido daqui */}
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
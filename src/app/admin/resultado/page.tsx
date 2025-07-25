'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { Search, Menu, X, LogOut, Download, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Checkbox } from '@/components/ui/checkbox';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api';
import { toast } from 'sonner'; // <<< 1. Importe o toast

// Tipagem para os dados que esperamos da API
interface ResultadoTurma {
  id: number;
  nome_turma: string;
  nome_disciplina: string;
  semestre: string;
  tem_respostas: boolean;
  respondidos: number;
  enviados: number;
}

export default function ResultadoPage() {
  const { logout } = useAuth();
  const router = useRouter();

  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeSection, setActiveSection] = useState('gerenciamento');
  const [turmas, setTurmas] = useState<ResultadoTurma[]>([]);
  const [selectedTurmas, setSelectedTurmas] = useState(new Set<number>());
  const [isLoading, setIsLoading] = useState(true);
  const [isGeneratingCsv, setIsGeneratingCsv] = useState(false);

  useEffect(() => {
    const fetchResultados = async () => {
      try {
        const response = await api.get('/resultados');
        setTurmas(response.data);
      } catch (error) {
        console.error('Falha ao carregar resultados:', error);
        toast.error("Falha ao carregar os dados dos resultados.");
      } finally {
        setIsLoading(false);
      }
    };

    fetchResultados();
  }, []);

  const handleLogout = () => {
    logout();
  };

  const handleSelectTurma = (turmaId: number, isChecked: boolean) => {
    setSelectedTurmas((prev) => {
      const newSelection = new Set(prev);
      if (isChecked) {
        newSelection.add(turmaId);
      } else {
        newSelection.delete(turmaId);
      }
      return newSelection;
    });
  };

  // ===============================================================
  // ▼▼▼ FUNÇÃO ATUALIZADA PARA USAR 'toast' ▼▼▼
  // ===============================================================
  const handleGenerateCsv = async () => {
    if (selectedTurmas.size === 0) return;

    setIsGeneratingCsv(true);
    try {
      const params = new URLSearchParams();
      selectedTurmas.forEach((id) => params.append('turma_ids[]', String(id)));
      
      const response = await api.get(`/resultados/exportar?${params.toString()}`, {
        responseType: 'blob',
      });

      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      
      const contentDisposition = response.headers['content-disposition'];
      let filename = 'resultados.csv';
      if (contentDisposition) {
        const filenameMatch = contentDisposition.match(/filename="(.+)"/);
        if (filenameMatch && filenameMatch.length === 2) {
          filename = filenameMatch[1];
        }
      }

      link.setAttribute('download', filename);
      document.body.appendChild(link);
      link.click();
      
      link.remove();
      window.URL.revokeObjectURL(url);

    } catch (error: any) {
      console.error('Falha ao gerar CSV:', error);
      const errorMessage = error.response?.data?.erro || "Ocorreu um erro ao gerar o arquivo CSV.";
      toast.error(errorMessage);
    } finally {
      setIsGeneratingCsv(false);
    }
  };
  // ===============================================================

  const MainContent = () => {
    if (isLoading) {
      return (
        <div className="flex justify-center items-center h-64">
          <Loader2 className="h-8 w-8 text-purple-700 animate-spin" />
          <p className="ml-4 text-gray-600">Carregando resultados...</p>
        </div>
      );
    }

    if (turmas.length === 0) {
      return (
        <div className="text-center py-16">
          <h3 className="text-xl font-semibold text-gray-700">Nenhuma turma com resultados encontrada.</h3>
          <p className="text-gray-500 mt-2">Quando formulários forem enviados e respondidos, os resultados aparecerão aqui.</p>
        </div>
      );
    }

    return (
      <div className="bg-white rounded-lg shadow-sm border">
        <ul className="divide-y divide-gray-200">
          {turmas.map((turma) => (
            <li key={turma.id} className="flex items-center p-4 transition-colors hover:bg-gray-50">
              <Checkbox
                id={`turma-${turma.id}`}
                checked={selectedTurmas.has(turma.id)}
                onCheckedChange={(checked) => handleSelectTurma(turma.id, Boolean(checked))}
                disabled={!turma.tem_respostas}
              />
              <label
                htmlFor={`turma-${turma.id}`}
                className={`flex-1 ml-4 ${!turma.tem_respostas ? 'text-gray-400 cursor-not-allowed' : 'cursor-pointer'}`}
              >
                <div className="font-semibold text-gray-900">{turma.nome_turma} ({turma.nome_disciplina})</div>
                <div className="text-sm text-gray-500">
                  {turma.semestre} | Respostas: {turma.respondidos}/{turma.enviados}
                </div>
              </label>
            </li>
          ))}
        </ul>
      </div>
    );
  };


  return (
    <div className="min-h-screen bg-gray-200">
      <header className="bg-white shadow-sm border-b relative z-[60]">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => setSidebarOpen(!sidebarOpen)}>
              {sidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </Button>
            <h1 className="text-lg font-medium">Gerenciamento - Resultados</h1>
          </div>
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input placeholder="Buscar..." className="pl-10 w-64 rounded-full border-gray-300" />
            </div>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="w-8 h-8 bg-purple-700 rounded-full flex items-center justify-center text-white font-medium text-sm hover:bg-purple-800 transition-colors">U</Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-40 z-[70]">
                <DropdownMenuItem onClick={handleLogout} className="cursor-pointer text-red-600 focus:text-red-600">
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>Sair</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </header>

      <div className="flex relative">
        {sidebarOpen && <div className="fixed inset-0 bg-black bg-opacity-50 z-40" onClick={() => setSidebarOpen(false)} />}
        <aside className={`fixed top-[73px] bottom-0 left-0 z-50 w-48 bg-white shadow-lg transform transition-transform duration-300 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
          <nav className="bg-white flex-1 py-2">
            <div className="space-y-1">
              <button onClick={() => router.push('/admin')} className={`w-full text-left px-4 py-3 text-sm font-medium transition-colors ${activeSection === 'avaliacoes' ? 'bg-purple-700 text-white' : 'text-gray-700 hover:bg-gray-100'}`}>
                Avaliações
              </button>
              <button onClick={() => router.push('/admin/gerenciamento')} className={`w-full text-left px-4 py-3 text-sm font-medium transition-colors ${activeSection === 'gerenciamento' ? 'bg-purple-700 text-white' : 'text-gray-700 hover:bg-gray-100'}`}>
                Gerenciamento
              </button>
            </div>
          </nav>
        </aside>
        
        <main className="flex-1 p-6 w-full md:pl-56">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-bold text-gray-800">Resultados por Turma</h2>
            <Button onClick={handleGenerateCsv} disabled={selectedTurmas.size === 0 || isGeneratingCsv}>
              {isGeneratingCsv ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : (
                <Download className="mr-2 h-4 w-4" />
              )}
              Gerar CSV
            </Button>
          </div>
          
          <MainContent />
        </main>
      </div>
    </div>
  );
}
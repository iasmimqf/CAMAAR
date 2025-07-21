'use client';

import { useAuth } from '@/contexts/AuthContext';
import { Search, Menu, X, LogOut } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Checkbox } from '@/components/ui/checkbox';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

// Interfaces para os dados que virão da API
interface Template {
  id: number;
  titulo: string;
}

interface Turma {
  id: number;
  nome: string;
  semestre: string;
  codigo: string;
  selected: boolean; // Adicionamos para o controle do checkbox
}

const API_BASE_URL = 'http://localhost:3000';

export default function EnviarFormularioPage() {
  const { logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const router = useRouter();

  // Estados para os dados da API
  const [templates, setTemplates] = useState<Template[]>([]);
  const [turmas, setTurmas] = useState<Turma[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Estados para o formulário
  const [selectedTemplate, setSelectedTemplate] = useState<string>(''); // Guarda o ID do template

  // Efeito para buscar os dados iniciais (templates e turmas)
  useEffect(() => {
    const fetchData = async () => {
      try {
        // Busca os templates e as turmas em paralelo
        const [templatesResponse, turmasResponse] = await Promise.all([
          fetch(`${API_BASE_URL}/api/v1/templates`, { credentials: 'include' }),
          fetch(`${API_BASE_URL}/api/v1/turmas`, { credentials: 'include' }),
        ]);

        if (!templatesResponse.ok || !turmasResponse.ok) {
          throw new Error('Falha ao carregar os dados necessários. Verifique se está autenticado como administrador.');
        }

        const templatesData = await templatesResponse.json();
        const turmasData = await turmasResponse.json();

        setTemplates(templatesData);
        // Adiciona a propriedade 'selected: false' a cada turma
        setTurmas(turmasData.map((turma: any) => ({ ...turma, selected: false })));

      } catch (err: any) {
        setError(err.message);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleLogout = () => {
    logout();
  };

  const handleTurmaSelect = (id: number, checked: boolean) => {
    setTurmas(
      turmas.map((turma) =>
        turma.id === id ? { ...turma, selected: checked } : turma
      )
    );
  };

  const handleSendForms = async () => {
    const selectedTurmaIds = turmas.filter((turma) => turma.selected).map((t) => t.id);

    try {
      const response = await fetch(`${API_BASE_URL}/admin/formularios`, {
        method: 'POST',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          template_id: selectedTemplate,
          turma_ids: selectedTurmaIds,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        // Mostra a mensagem de erro vinda do backend
        throw new Error(data.erro || 'Ocorreu um erro desconhecido.');
      }

      // Mostra a mensagem de sucesso
      alert(data.mensagem);
      router.push('/admin'); // Redireciona para a página principal do admin
    } catch (err: any) {
      alert(`Erro: ${err.message}`);
    }
  };
  
  // Verifica se o botão de criar deve estar desabilitado
  const isSubmitDisabled = templates.length === 0 || turmas.length === 0;

  return (
    <div className="min-h-screen bg-gray-200">
      {/* Header */}
      <header className="bg-white shadow-sm border-b relative z-[60]">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => setSidebarOpen(!sidebarOpen)}>
              {sidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </Button>
            <h1 className="text-lg font-medium">Enviar Formulário</h1>
          </div>
          <div className="flex items-center gap-4">
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
        {/* Sidebar */}
        <aside className={`fixed top-[73px] bottom-0 left-0 z-50 w-48 bg-white shadow-lg transform transition-transform duration-300 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
          <nav className="bg-white flex-1 py-2">
            <div className="space-y-1">
              <button onClick={() => router.push('/admin')} className="w-full text-left px-4 py-3 text-sm font-medium text-gray-700 hover:bg-gray-100">Avaliações</button>
              <button onClick={() => router.push('/admin/gerenciamento')} className="w-full text-left px-4 py-3 text-sm font-medium bg-purple-700 text-white">Gerenciamento</button>
            </div>
          </nav>
        </aside>

        {/* Main Content */}
        <main className="flex-1 p-6">
          <div className="flex items-center justify-center min-h-[calc(100vh-200px)]">
            <div className="bg-white rounded-lg shadow-sm p-8 w-full max-w-2xl">
              {isLoading && <p>A carregar dados...</p>}
              {error && <p className="text-red-500">{error}</p>}
              
              {!isLoading && !error && (
                <div className="space-y-6">
                  {isSubmitDisabled ? (
                    <p className="text-center text-red-600">Não é possível criar um formulário sem templates e turmas cadastrados.</p>
                  ) : (
                    <>
                      {/* Template Selection */}
                      <div className="flex items-center gap-4">
                        <label htmlFor="template-select" className="text-sm font-medium text-gray-700">Template:</label>
                        <Select value={selectedTemplate} onValueChange={setSelectedTemplate}>
                          <SelectTrigger id="template-select" className="w-[200px]">
                            <SelectValue placeholder="Selecione um template" />
                          </SelectTrigger>
                          <SelectContent>
                            {templates.map((template) => (
                              <SelectItem key={template.id} value={template.id.toString()}>
                                {template.titulo}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>

                      {/* Course List */}
                      <div className="border rounded-md overflow-hidden">
                        <div className="grid grid-cols-[auto_1fr_auto_auto] gap-4 p-4 bg-gray-50 text-sm font-medium text-gray-700">
                          <div></div>
                          <div>Nome</div>
                          <div>Semestre</div>
                          <div>Código</div>
                        </div>
                        {turmas.map((turma) => (
                          <div key={turma.id} className="grid grid-cols-[auto_1fr_auto_auto] gap-4 items-center p-4 border-t">
                            <Checkbox id={`turma-${turma.id}`} checked={turma.selected} onCheckedChange={(checked) => handleTurmaSelect(turma.id, checked as boolean)} />
                            <label htmlFor={`turma-${turma.id}`} className="text-sm font-normal text-gray-800">{turma.nome}</label>
                            <div className="text-sm text-gray-600">{turma.semestre}</div>
                            <div className="text-sm text-gray-600">{turma.codigo}</div>
                          </div>
                        ))}
                      </div>

                      {/* Send Button */}
                      <div className="flex justify-end">
                        <Button onClick={handleSendForms} disabled={isSubmitDisabled} className="bg-green-500 hover:bg-green-600 text-white font-medium py-2 px-6 rounded-md transition-colors duration-200">
                          Criar Formulário
                        </Button>
                      </div>
                    </>
                  )}
                </div>
              )}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
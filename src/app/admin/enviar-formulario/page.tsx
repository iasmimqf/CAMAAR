'use client';

import { useAuth } from '@/contexts/AuthContext';
import { Menu, X, LogOut, CalendarIcon, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
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
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Calendar } from "@/components/ui/calendar"
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { format } from "date-fns"
import { api } from '@/lib/api';
import { toast } from 'sonner'; // <<< 1. Importe o toast

// Interfaces para a tipagem dos dados
interface Template {
  id: number;
  titulo: string;
}
interface Turma {
  id: number;
  nome: string;
  semestre: string;
  codigo: string;
}

export default function EnviarFormularioPage() {
  const { logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const router = useRouter();

  const [templates, setTemplates] = useState<Template[]>([]);
  const [turmas, setTurmas] = useState<Turma[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false); // Estado para o envio
  const [error, setError] = useState<string | null>(null);

  // Estados para os dados do formulário
  const [selectedTemplate, setSelectedTemplate] = useState<string>('');
  const [selectedTurmaIds, setSelectedTurmaIds] = useState<Set<number>>(new Set());
  const [prazo, setPrazo] = useState<Date | undefined>();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [templatesResponse, turmasResponse] = await Promise.all([
          api.get('/templates'),
          api.get('/turmas'),
        ]);
        setTemplates(templatesResponse.data);
        setTurmas(turmasResponse.data);
      } catch (err: any) {
        setError('Falha ao carregar os dados. Verifique se está autenticado como administrador.');
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, []);

  const handleTurmaSelect = (id: number, checked: boolean) => {
    setSelectedTurmaIds(prev => {
      const newSelection = new Set(prev);
      if (checked) newSelection.add(id);
      else newSelection.delete(id);
      return newSelection;
    });
  };

  // ===============================================================
  // ▼▼▼ FUNÇÃO ATUALIZADA PARA USAR 'toast' ▼▼▼
  // ===============================================================
  const handleSendForms = async () => {
    if (!selectedTemplate || selectedTurmaIds.size === 0) {
      toast.error("Por favor, selecione um template e pelo menos uma turma.");
      return;
    }

    setIsSubmitting(true);
    try {
      const response = await api.post('/formularios', {
        formulario: {
          template_id: selectedTemplate,
          turma_ids: Array.from(selectedTurmaIds),
          prazo: prazo,
        }
      });

      toast.success(response.data.mensagem);
      router.push('/admin');
    } catch (err: any) {
      const errorMessage = err.response?.data?.erro || 'Ocorreu um erro desconhecido.';
      toast.error(`Erro: ${errorMessage}`);
    } finally {
      setIsSubmitting(false);
    }
  };
  // ===============================================================
  
  const isSubmitDisabled = !selectedTemplate || selectedTurmaIds.size === 0 || isSubmitting;

  return (
    <div className="min-h-screen bg-gray-200">
      {/* Header e Sidebar */}
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
        <aside className={`fixed top-[73px] bottom-0 left-0 z-50 w-48 bg-white shadow-lg transform transition-transform duration-300 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'} md:translate-x-0`}>
          <nav className="bg-white flex-1 py-2">
            <div className="space-y-1">
              <button onClick={() => router.push('/admin')} className="w-full text-left px-4 py-3 text-sm font-medium text-gray-700 hover:bg-gray-100">Avaliações</button>
              <button onClick={() => router.push('/admin/gerenciamento')} className="w-full text-left px-4 py-3 text-sm font-medium bg-purple-700 text-white">Gerenciamento</button>
            </div>
          </nav>
        </aside>

        {/* Conteúdo Principal */}
        <main className="flex-1 p-6 w-full md:pl-48">
          <div className="flex items-center justify-center min-h-[calc(100vh-200px)]">
            <div className="bg-white rounded-lg shadow-sm p-8 w-full max-w-2xl">
              {isLoading && <p>A carregar dados...</p>}
              {error && <p className="text-red-500">{error}</p>}
              
              {!isLoading && !error && (
                <div className="space-y-6">
                  {/* Seletor de Template */}
                  <div className="flex items-center gap-4">
                    <label className="text-sm font-medium text-gray-700">Template:</label>
                    <Select value={selectedTemplate} onValueChange={setSelectedTemplate}>
                      <SelectTrigger className="w-[250px]"><SelectValue placeholder="Selecione um template" /></SelectTrigger>
                      <SelectContent>
                        {templates.map((template) => (
                          <SelectItem key={template.id} value={template.id.toString()}>{template.titulo}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  {/* Seletor de Data de Prazo */}
                  <div className="flex items-center gap-4">
                    <label className="text-sm font-medium text-gray-700">Prazo (Opcional):</label>
                    <Popover>
                      <PopoverTrigger asChild>
                        <Button variant={"outline"} className="w-[250px] justify-start text-left font-normal">
                          <CalendarIcon className="mr-2 h-4 w-4" />
                          {prazo ? format(prazo, "dd/MM/yyyy") : <span>Escolha uma data</span>}
                        </Button>
                      </PopoverTrigger>
                      <PopoverContent className="w-auto p-0">
                        <Calendar mode="single" selected={prazo} onSelect={setPrazo} initialFocus />
                      </PopoverContent>
                    </Popover>
                  </div>

                  {/* Lista de Turmas */}
                  <div className="border rounded-md max-h-60 overflow-y-auto">
                    {turmas.map((turma) => (
                      <div key={turma.id} className="grid grid-cols-[auto_1fr_auto_auto] gap-4 items-center p-4 border-t first:border-t-0">
                        <Checkbox id={`turma-${turma.id}`} checked={selectedTurmaIds.has(turma.id)} onCheckedChange={(checked) => handleTurmaSelect(turma.id, Boolean(checked))} />
                        <label htmlFor={`turma-${turma.id}`} className="text-sm font-normal text-gray-800 cursor-pointer">{turma.nome}</label>
                        <div className="text-sm text-gray-600">{turma.semestre}</div>
                        <div className="text-sm text-gray-600">{turma.codigo}</div>
                      </div>
                    ))}
                  </div>

                  {/* Botão de Envio */}
                  <div className="flex justify-end">
                    <Button onClick={handleSendForms} disabled={isSubmitDisabled} className="bg-green-500 hover:bg-green-600 text-white">
                      {isSubmitting ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                      {isSubmitting ? 'A criar...' : 'Criar Formulário'}
                    </Button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
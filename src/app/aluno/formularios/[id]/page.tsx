// Caminho: src/app/aluno/formularios/[id]/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';
import { api } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Checkbox } from '@/components/ui/checkbox';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Loader2, Menu, X, LogOut, ArrowRight } from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { toast } from 'sonner';

// Interfaces para a tipagem dos dados
interface Opcao {
  id: number;
  texto: string;
}
interface Questao {
  id: number;
  texto: string;
  tipo: string;
  opcoes: Opcao[];
}
interface FormularioData {
  id: number;
  nome_template: string;
  questoes: Questao[];
}
// Tipagem corrigida para aceitar um array de números para checkboxes
interface RespostasState {
  [questaoId: string]: string | number[];
}

export default function ResponderFormularioPage() {
  const { user, isAuthenticated, isLoading, logout } = useAuth();
  const params = useParams();
  const router = useRouter();
  const id = params.id as string;

  const [formulario, setFormulario] = useState<FormularioData | null>(null);
  const [respostas, setRespostas] = useState<RespostasState>({});
  const [isPageLoading, setIsPageLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    if (id) {
      const fetchFormulario = async () => {
        try {
          const response = await api.get(`/formularios/${id}`);
          setFormulario(response.data);
        } catch (err: any) {
          toast.error(err.response?.data?.error || "Não foi possível carregar o formulário.");
          router.replace(user?.admin ? '/admin' : '/aluno');
        } finally {
          setIsPageLoading(false);
        }
      };
      fetchFormulario();
    }
  }, [id, user, router]);

  const handleRespostaChange = (questaoId: number, valor: string) => {
    setRespostas((prev) => ({ ...prev, [questaoId]: valor }));
  };

  // Função específica para lidar com checkboxes
  const handleCheckboxChange = (questaoId: number, opcaoId: number, checked: boolean) => {
    setRespostas(prev => {
      const currentSelection = (prev[questaoId] as number[] | undefined) || [];
      const newSelection = new Set(currentSelection);
      if (checked) {
        newSelection.add(opcaoId);
      } else {
        newSelection.delete(opcaoId);
      }
      return { ...prev, [questaoId]: Array.from(newSelection) };
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // Adicione aqui uma validação mais robusta se necessário
    setIsSubmitting(true);
    try {
      await api.post(`/formularios/${id}/responder`, { respostas });
      toast.success("Avaliação enviada com sucesso!");
      router.push(user?.admin ? '/admin' : '/aluno');
    } catch (err: any) {
      toast.error(err.response?.data?.erro || "Ocorreu um erro ao enviar a sua avaliação.");
    } finally {
      setIsSubmitting(false);
    }
  };

  // ===============================================================
  // ▼▼▼ FUNÇÃO DE RENDERIZAÇÃO CORRIGIDA ▼▼▼
  // ===============================================================
  const renderizarQuestao = (questao: Questao) => {
    switch (questao.tipo) {
      case 'Escala':
        return (
          <RadioGroup
            value={respostas[questao.id] as string}
            onValueChange={(valor) => handleRespostaChange(questao.id, valor)}
            className="space-y-3"
          >
            {questao.opcoes.map((opcao) => (
              <div key={opcao.id} className="flex items-center space-x-2">
                <RadioGroupItem value={String(opcao.id)} id={`q${questao.id}-o${opcao.id}`} />
                <Label htmlFor={`q${questao.id}-o${opcao.id}`} className="text-sm font-normal cursor-pointer">
                  {opcao.texto}
                </Label>
              </div>
            ))}
          </RadioGroup>
        );
      case 'Texto':
        return (
          <Textarea
            placeholder="Digite sua resposta aqui..."
            value={(respostas[questao.id] as string) || ''}
            onChange={(e) => handleRespostaChange(questao.id, e.target.value)}
            className="w-full min-h-[120px]"
          />
        );
      case 'Checkbox':
        return (
          <div className="space-y-3">
            {questao.opcoes.map((opcao) => (
              <div key={opcao.id} className="flex items-center space-x-2">
                <Checkbox
                  id={`q${questao.id}-o${opcao.id}`}
                  checked={(respostas[questao.id] as number[] | undefined)?.includes(opcao.id)}
                  onCheckedChange={(checked) => handleCheckboxChange(questao.id, opcao.id, Boolean(checked))}
                />
                <Label htmlFor={`q${questao.id}-o${opcao.id}`} className="text-sm font-normal cursor-pointer">
                  {opcao.texto}
                </Label>
              </div>
            ))}
          </div>
        );
      default:
        return <p className="text-red-500">Tipo de questão não suportado: {questao.tipo}</p>;
    }
  };
  // ===============================================================

  if (isLoading || isPageLoading) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <Loader2 className="h-8 w-8 animate-spin text-purple-700" />
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <p>A redirecionar...</p>
      </div>
    );
  }

  if (!formulario) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <p className="text-lg font-semibold text-red-600">Formulário não encontrado.</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-200">
      {/* Header e Sidebar */}
      <header className="bg-white shadow-sm border-b relative z-[60]">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => setSidebarOpen(!sidebarOpen)}>
              {sidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </Button>
            <h1 className="text-lg font-medium">
              Avaliação - {formulario.nome_template}
            </h1>
          </div>
          <div className="flex items-center gap-4">
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="w-8 h-8 bg-purple-700 rounded-full flex items-center justify-center text-white font-medium text-sm hover:bg-purple-800 transition-colors">
                  {user?.email?.charAt(0).toUpperCase()}
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
        <aside className={`fixed top-[73px] bottom-0 left-0 z-50 w-48 bg-white shadow-lg transform transition-transform duration-300 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
          <nav className="bg-white flex-1 py-2">
            <div className="space-y-1">
              <button onClick={() => user?.admin ? router.push('/admin') : router.push('/aluno')} className="w-full text-left px-4 py-3 text-sm font-medium bg-purple-700 text-white">
                Avaliações
              </button>
            </div>
          </nav>
        </aside>
        <main className="flex-1 p-6 w-full md:pl-56">
          <div className="max-w-4xl mx-auto">
            <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow-sm p-8 space-y-8">
              {formulario.questoes.map((questao, index) => (
                <div key={questao.id} className="bg-gray-100 p-6 rounded-lg">
                  <Label className="font-semibold text-gray-900 mb-4 block text-base">
                    {index + 1}. {questao.texto}
                  </Label>
                  {renderizarQuestao(questao)}
                </div>
              ))}
              <div className="flex justify-end pt-6 border-t mt-8">
                <Button type="submit" className="bg-green-600 hover:bg-green-700 text-white px-6 py-2" disabled={isSubmitting}>
                  {isSubmitting ? <Loader2 className="h-5 w-5 mr-2 animate-spin" /> : <ArrowRight className="h-5 w-5 mr-2" />}
                  {isSubmitting ? 'A enviar...' : 'Enviar Avaliação'}
                </Button>
              </div>
            </form>
          </div>
        </main>
      </div>
    </div>
  );
}
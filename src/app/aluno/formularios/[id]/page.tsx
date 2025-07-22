// Caminho: src/app/aluno/formularios/[id]/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';
import { api } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Loader2, Menu, X, LogOut, ArrowRight } from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

// Tipagem para os dados que esperamos da API
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

// Tipagem para o estado que armazena as respostas do aluno
interface RespostasState {
  [questaoId: number]: string;
}

export default function ResponderFormularioPage() {
  const { user, isAuthenticated, isLoading, logout } = useAuth();
  const params = useParams();
  const router = useRouter();
  const id = params.id as string;

  const [formulario, setFormulario] = useState<FormularioData | null>(null);
  const [respostas, setRespostas] = useState<RespostasState>({});
  const [isPageLoading, setIsPageLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false); // Novo estado para o envio
  const [error, setError] = useState<string | null>(null);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    if (id) {
      const fetchFormulario = async () => {
        try {
          const response = await api.get(`/formularios/${id}`);
          setFormulario(response.data);
        } catch (err) {
          console.error("Falha ao buscar formulário:", err);
          setError("Não foi possível carregar o formulário.");
        } finally {
          setIsPageLoading(false);
        }
      };
      fetchFormulario();
    }
  }, [id]);

  const handleRespostaChange = (questaoId: number, valor: string) => {
    setRespostas((prev) => ({
      ...prev,
      [questaoId]: valor,
    }));
  };

  // ===============================================================
  // ▼▼▼ LÓGICA DE ENVIO ATUALIZADA ▼▼▼
  // ===============================================================
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validação simples para garantir que todas as perguntas foram respondidas
    if (Object.keys(respostas).length !== formulario?.questoes.length) {
      alert("Por favor, responda a todas as perguntas antes de enviar.");
      return;
    }

    setIsSubmitting(true);
    try {
      // Faz a requisição POST para o nosso novo endpoint no Rails
      await api.post(`/formularios/${id}/responder`, {
        respostas: respostas, // Envia o objeto de respostas no corpo da requisição
      });

      alert("Avaliação enviada com sucesso!");
      router.push('/aluno'); // Redireciona de volta para a lista de formulários
    } catch (err) {
      console.error("Falha ao enviar respostas:", err);
      alert("Ocorreu um erro ao enviar sua avaliação. Tente novamente.");
    } finally {
      setIsSubmitting(false);
    }
  };
  // ===============================================================

  if (isLoading || isPageLoading) {
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
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <p className="text-lg font-semibold text-gray-700">A redirecionar...</p>
      </div>
    );
  }

  if (error || !formulario) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <p className="text-lg font-semibold text-red-600">{error || "Formulário não encontrado."}</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-200">
      {/* Header */}
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

        {/* Conteúdo Principal */}
        <main className="flex-1 p-6 w-full md:pl-56">
          <div className="max-w-4xl mx-auto">
            <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow-sm p-8 space-y-8">
              {formulario.questoes.map((questao, index) => (
                <div key={questao.id} className="bg-gray-100 p-6 rounded-lg">
                  <Label className="font-semibold text-gray-900 mb-4 block text-base">
                    {index + 1}. {questao.texto}
                  </Label>
                  {questao.tipo === 'multipla_escolha' && (
                    <RadioGroup
                      value={respostas[questao.id]}
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
                  )}
                  {questao.tipo === 'texto_longo' && (
                    <Textarea
                      placeholder="Digite sua resposta aqui..."
                      value={respostas[questao.id] || ''}
                      onChange={(e) => handleRespostaChange(questao.id, e.target.value)}
                      className="w-full min-h-[120px]"
                    />
                  )}
                </div>
              ))}
              <div className="flex justify-end pt-6 border-t mt-8">
                <Button type="submit" className="bg-green-600 hover:bg-green-700 text-white px-6 py-2" disabled={isSubmitting}>
                  {isSubmitting ? (
                    <Loader2 className="h-5 w-5 mr-2 animate-spin" />
                  ) : (
                    <ArrowRight className="h-5 w-5 mr-2" />
                  )}
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
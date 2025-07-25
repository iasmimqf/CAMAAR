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
import { Loader2, Menu, X, LogOut, ArrowRight, Ban } from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { toast } from 'sonner';

interface Opcao {
  id: number;
  texto: string;
}
interface Questao {
  id: number;
  texto: string;
  tipo: string;
  opcoes: Opcao[];
  obrigatoria?: boolean;
}
interface FormularioData {
  id: number;
  nome_template: string;
  questoes: Questao[];
}
interface RespostasState {
  [questaoId: string]: string | number | number[];
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
  const [isFormularioExpirado, setIsFormularioExpirado] = useState(false);
  const [mensagemErroExpirado, setMensagemErroExpirado] = useState<string | null>(null);

  useEffect(() => {
    if (id) {
      const fetchFormulario = async () => {
        try {
          const response = await api.get(`/formularios/${id}`);
          setFormulario(response.data);
        } catch (err: any) {
          if (err.response && err.response.status === 403) {
            setIsFormularioExpirado(true);
            setMensagemErroExpirado(err.response.data?.error || "Este formulário não pode mais ser respondido.");
            toast.error(err.response.data?.error || "Formulário expirado ou não disponível.");
          } else {
            toast.error(err.response?.data?.error || "Não foi possível carregar o formulário.");
          }
        } finally {
          setIsPageLoading(false);
        }
      };
      fetchFormulario();
    }
  }, [id, user, router]);

  useEffect(() => {
    if (formulario) {
      setRespostas(prev => {
        const inicializadas: RespostasState = {};
        formulario.questoes.forEach((q) => {
          if (q.tipo === 'Checkbox' && !(q.id in prev)) {
            inicializadas[q.id] = [];
          }
        });
        return { ...inicializadas, ...prev };
      });
    }
  }, [formulario]);

  const handleRespostaChange = (questaoId: number, valor: string | number) => {
    setRespostas((prev) => ({ ...prev, [questaoId]: valor }));
  };

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

    if (formulario) {
      for (const questao of formulario.questoes) {
        if (questao.obrigatoria) {
          const resposta = respostas[questao.id];
          let isRespostaValida = true;

          switch (questao.tipo) {
            case 'Texto':
              isRespostaValida = typeof resposta === 'string' && resposta.trim() !== '';
              break;
            case 'Escala':
              isRespostaValida = typeof resposta === 'number' && !isNaN(resposta);
              break;
            case 'Checkbox':
              isRespostaValida = Array.isArray(resposta) && resposta.length > 0;
              break;
            default:
              isRespostaValida = resposta !== undefined && resposta !== null &&
                (typeof resposta === 'string' ? resposta.trim() !== '' : true);
              break;
          }

          if (!isRespostaValida) {
            toast.error(`Por favor, responda a questão obrigatória: "${questao.texto}"`);
            return;
          }
        }
      }
    }

    setIsSubmitting(true);
    try {
      // ==================================================================
      // ALTERAÇÃO APLICADA AQUI
      // Enviando o objeto 'respostas' diretamente, sem formatação extra.
      // ==================================================================
      console.log('Respostas enviadas:', respostas);
      await api.post(`/formularios/${id}/responder`, { respostas });

      toast.success("Avaliação enviada com sucesso!");
      router.push(user?.admin ? '/admin' : '/aluno');
    } catch (err: any) {
      console.error("Erro ao enviar avaliação:", err);
      const errorMessage = err.response?.data?.error || err.response?.data?.erro || "Ocorreu um erro ao enviar a sua avaliação.";
      toast.error(errorMessage);
    } finally {
      setIsSubmitting(false);
    }
  };

  const renderizarQuestao = (questao: Questao) => {
    switch (questao.tipo) {
      case 'Escala':
        return (
          <RadioGroup
            value={respostas[questao.id]?.toString() || ''}
            onValueChange={(valor) => handleRespostaChange(questao.id, Number(valor))}
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
                  onCheckedChange={(checked) =>
                    handleCheckboxChange(questao.id, opcao.id, checked === true)
                  }
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

  if (isLoading || isPageLoading) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <Loader2 className="h-8 w-8 animate-spin text-purple-700" />
      </div>
    );
  }

  if (!isAuthenticated) {
    router.replace('/login');
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <p>A redirecionar para o login...</p>
      </div>
    );
  }

  if (isFormularioExpirado) {
    return (
      <div className="min-h-screen bg-gray-200 flex items-center justify-center p-4">
        <div className="bg-white rounded-lg shadow-lg p-8 text-center max-w-md w-full space-y-4">
          <Ban className="h-16 w-16 text-red-500 mx-auto" />
          <h2 className="text-2xl font-bold text-gray-800">Formulário Indisponível</h2>
          <p className="text-gray-600">
            {mensagemErroExpirado || "Este formulário não pode ser respondido pois já passou do prazo ou não está ativo."}
          </p>
          <Button onClick={() => router.push(user?.admin ? '/admin' : '/aluno')} className="bg-purple-700 hover:bg-purple-800 text-white px-6 py-2">
            Voltar para Avaliações
          </Button>
        </div>
      </div>
    );
  }

  if (!formulario) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-200">
        <p className="text-lg font-semibold text-red-600">Formulário não encontrado ou erro inesperado.</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-200">
      {/* ...header e sidebar mantidos iguais... */}
      <main className="flex-1 p-6 w-full md:pl-56">
        <div className="max-w-4xl mx-auto">
          <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow-sm p-8 space-y-8">
            {formulario.questoes.map((questao, index) => (
              <div key={questao.id} className="bg-gray-100 p-6 rounded-lg">
                <Label className="font-semibold text-gray-900 mb-4 block text-base">
                  {index + 1}. {questao.texto}
                  {questao.obrigatoria && <span className="text-red-500 ml-1">*</span>}
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
  );
}
'use client';

import { useAuth } from '@/contexts/AuthContext'; // <<< 1. Importe o nosso hook
import { Search, Menu, X, LogOut, Edit, Trash2, Plus } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { useState, useEffect } from 'react';

import { useRouter } from 'next/navigation';

// MODIFICADO: Interface Template para incluir 'questoes' com todas as propriedades
interface Template {
  id: number;
  titulo: string;
  created_at: string;
  questoes: Array<{
    id?: number; // Questões existentes terão ID, novas no frontend podem não ter (ainda)
    tipo: string;
    enunciado: string;
    obrigatoria: boolean;
    opcoes?: string; // Mantém como string para o Input
    _destroy?: boolean; // Para lidar com a remoção de questões aninhadas no Rails
  }>;
}

// MODIFICADO: Interface Question para incluir 'obrigatoria' e '_destroy'
interface Question {
  id: number | string; // MODIFICADO: ID pode ser number (do DB) ou string (temporário de Date.now())
  type: string;
  text: string;
  options?: string;
  obrigatoria: boolean;
  _destroy?: boolean; // Propriedade para marcar questão para remoção no Rails
}

const API_BASE_URL = 'http://localhost:3000/api/v1';

export default function GerenciamentoTemplatesPage() {
  const { logout } = useAuth(); // <<< 2. Obtenha a função de logout do contexto
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeSection, setActiveSection] = useState('gerenciamento');
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [templateName, setTemplateName] = useState('');

  // ESTADO CRÍTICO PARA A EDIÇÃO: Armazena o ID do template que está sendo editado. 'null' indica modo de criação.
  const [editingTemplateId, setEditingTemplateId] = useState<number | null>(null);

  // Questões iniciais com obrigatoriedade padrão e ID temporário
  const [questions, setQuestions] = useState<Question[]>([
    { id: 'new-temp-1', type: 'texto', text: '', obrigatoria: false, options: '' }, // MODIFICADO: Usando string para ID temporário
  ]);

  const [templates, setTemplates] = useState<Template[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const fetchTemplates = async () => {
    setIsLoading(true);
    setError(null);
    try {
      console.log("DEBUG: Tentando buscar templates de:", `${API_BASE_URL}/templates`);
      const response = await fetch(`${API_BASE_URL}/templates`, {
        credentials: 'include', 
      });
      if (!response.ok) {
        const errorBody = await response.text();
        throw new Error(`Erro HTTP! Status: ${response.status} - ${errorBody}`);
      }
      const data: Template[] = await response.json();
      setTemplates(data);
    } catch (err: any) {
      console.error("Erro ao buscar templates:", err);
      if (err.message.includes("Failed to fetch")) {
        setError("Não foi possível conectar ao servidor da API. Verifique se o Rails está rodando na porta 3000 e se o CORS está configurado.");
      } else {
        setError(`Erro ao carregar templates: ${err.message}`);
      }
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchTemplates();
  }, []);

  // NOVO: useEffect para depurar o editingTemplateId
  useEffect(() => {
    console.log("DEBUG: editingTemplateId mudou para:", editingTemplateId);
  }, [editingTemplateId]);

  const loadTemplateForEdit = async (id: number) => {
    setIsLoading(true);
    setError(null);
    try {
      console.log(`DEBUG: Carregando detalhes do template ID: ${id}`);
      const response = await fetch(`${API_BASE_URL}/templates/${id}`, {
        credentials: 'include', 
      });
      if (!response.ok) {
        const errorBody = await response.text();
        throw new Error(`Erro ao carregar template: Status ${response.status} - ${errorBody}`);
      }
      const data: Template = await response.json();

      setTemplateName(data.titulo);
      // MODIFICADO: Mapeia as questões do backend para o formato do estado 'questions' do frontend
      setQuestions(
        data.questoes.map(q => ({
          id: q.id as number, // Confia que o ID do backend é um número
          type: q.tipo,
          text: q.enunciado,
          obrigatoria: q.obrigatoria,
          options: q.opcoes || ''
        }))
      );
    } catch (err: any) {
      console.error("Erro ao carregar template para edição:", err);
      setError(`Não foi possível carregar os detalhes do template: ${err.message}`);
      setEditModalOpen(false);
    } finally {
      setIsLoading(false);
    }
  };


  const handleLogout = () => {
    logout(); // <<< 3. Chame a função de logout
  };

  const handleSectionChange = (section: string) => {
    setActiveSection(section);
    console.log('Navigating to:', section);
  };

  const handleEditTemplate = (templateId: number) => {
    console.log('DEBUG: Clicou em Editar Template ID:', templateId);
    setEditingTemplateId(templateId);
    loadTemplateForEdit(templateId);
    setEditModalOpen(true);
  };

  const handleDeleteTemplate = async (templateId: number) => {
    console.log('DEBUG: handleDeleteTemplate foi chamado para o ID:', templateId);
    if (!window.confirm('Tem certeza que deseja excluir este template? Esta ação é irreversível.')) {
      console.log('DEBUG: Exclusão de template cancelada pelo usuário.');
      return;
    }

    try {
      console.log(`DEBUG: Enviando requisição DELETE para: ${API_BASE_URL}/templates/${templateId}`);
      const response = await fetch(`${API_BASE_URL}/templates/${templateId}`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
      });

      if (response.ok) {
        alert('Template excluído com sucesso!');
        console.log('DEBUG: Template excluído com sucesso. Recarregando lista...');
        fetchTemplates();
      } else {
        const errorBody = await response.text();
        let errorMessage = "Erro desconhecido ao excluir template.";
        try {
          const errorData = JSON.parse(errorBody);
          if (errorData.erro) {
            errorMessage = errorData.erro;
          } else if (errorData.message) {
            errorMessage = errorData.message;
          }
        } catch (e) {
          errorMessage = errorBody || "Mensagem de erro não disponível.";
        }
        console.error('DEBUG: Erro ao excluir template:', response.status, errorMessage);
        alert(`Erro ao excluir template:\nStatus: ${response.status}\nDetalhes: ${errorMessage}`);
      }
    } catch (error: any) {
      console.error('DEBUG: Falha na comunicação com o servidor ao excluir:', error);
      alert('Não foi possível conectar ao servidor para excluir o template.');
    }
  };

  const handleAddTemplate = () => {
    console.log('DEBUG: Clicou em Adicionar Novo Template');
    setEditingTemplateId(null); // Define como null para indicar que é um novo template (criação)
    setTemplateName(''); // Limpa o nome para um novo template
    setQuestions([{ id: 'new-temp-1', type: 'texto', text: '', obrigatoria: false, options: '' }]); // MODIFICADO: Limpa questões com ID temporário de string
    setEditModalOpen(true);
  };

  const handleAddQuestion = () => {
    const newQuestion: Question = {
      id: `new-temp-${Date.now()}`, // MODIFICADO: ID único para novas questões no frontend (string)
      type: 'texto',
      text: '',
      obrigatoria: false,
      options: '',
    };
    setQuestions([...questions, newQuestion]);
  };

  const handleQuestionChange = (
    questionId: number | string, // MODIFICADO: questionId pode ser number ou string
    field: string,
    value: string | boolean
  ) => {
    setQuestions(
      questions.map((q) => (q.id === questionId ? { ...q, [field]: value } : q))
    );
  };

  const handleRemoveQuestion = (idToRemove: number | string) => { // MODIFICADO: idToRemove pode ser number ou string
    setQuestions(prevQuestions => {
      return prevQuestions
        .map(q => {
          if (q.id === idToRemove) {
            // Se a questão já tem ID do banco (é um número e maior que 0), marque para _destroy
            if (typeof q.id === 'number' && q.id > 0) {
              console.log(`DEBUG: Marcando questão ID ${q.id} para _destroy.`);
              return { ...q, _destroy: true };
            } else {
              // Se é uma questão nova (ID temporário string) e está sendo removida,
              // simplesmente a removemos do estado (não precisa enviar para Rails).
              console.log(`DEBUG: Removendo nova questão ID ${q.id} do frontend.`);
              return null; // Marcar para remoção na filtragem
            }
          }
          return q;
        })
        .filter(q => q !== null) as Question[]; // Filtra as questões marcadas como null (as novas removidas)
    });
  };

  const handleSaveTemplate = async () => {
    if (!templateName.trim()) {
      alert('O título do template é obrigatório.');
      return;
    }

    // Mapeia e filtra as questões que realmente serão enviadas para o Rails
    const questionsToSend = questions.filter(q => {
      if (q === null) return false;

      if (q._destroy) {
        return typeof q.id === 'number' && q.id > 0;
      }
      
      // AQUI ESTÁ A CORREÇÃO: Usando 'q.text' para validar o estado do frontend
      return q.text !== undefined && q.text !== null && q.text.trim() !== '';
    }).map(q => {
      if (q._destroy) {
        // Se marcada para destruição, envia só o ID e a flag
        return { id: q.id as number, _destroy: true };
      }
      // Para questões a serem salvas ou atualizadas, mapeia para o formato do backend
      return {
        id: (editingTemplateId !== null && typeof q.id === 'number' && q.id > 0) ? q.id as number : undefined,
        tipo: q.type,
        enunciado: q.text, // Mapeamento correto para 'enunciado' que o backend espera
        obrigatoria: q.obrigatoria,
        opcoes: q.options ? q.options.split(',').map(item => item.trim()) : [],
      };
    });

    const activeQuestionsAfterFilter = questionsToSend.filter(q => !q._destroy);

    if (activeQuestionsAfterFilter.length === 0) {
      alert('Adicione pelo menos uma questão válida ao template.');
      return;
    }

    const method = editingTemplateId ? 'PUT' : 'POST';
    const url = editingTemplateId ? `${API_BASE_URL}/templates/${editingTemplateId}` : `${API_BASE_URL}/templates`;

    const payload = {
      template: {
        titulo: templateName,
        questoes_attributes: questionsToSend
      }
    };

    // O resto da sua função de fetch continua igual...
    try {
      const response = await fetch(url, {
        method: method,
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(payload)
      });

      if (response.ok) {
        const result = await response.json();
        alert(result.mensagem);
        setEditModalOpen(false);
        fetchTemplates();
      } else {
        const errorBody = await response.json();
        alert(`Erro ao salvar: ${errorBody.erro}`);
      }
    } catch (error) {
      alert('Não foi possível conectar ao servidor. Tente novamente.');
    }
  };

  return (
    <div className="min-h-screen bg-gray-200">
      {/* Header */}
      <header className="bg-white shadow-sm border-b relative z-[60]">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center gap-4">
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setSidebarOpen(!sidebarOpen)}
            >
              {sidebarOpen ? (
                <X className="h-5 w-5" />
              ) : (
                <Menu className="h-5 w-5" />
              )}
            </Button>
            <h1 className="text-lg font-medium">Gerenciamento - Templates</h1>
          </div>

          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input
                placeholder="Search..."
                className="pl-10 w-64 rounded-full border-gray-300"
              />
            </div>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  className="w-8 h-8 bg-purple-700 rounded-full flex items-center justify-center text-white font-medium text-sm hover:bg-purple-800 transition-colors"
                >
                  U
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-40 z-[70]">
                <DropdownMenuItem
                  onClick={handleLogout}
                  className="cursor-pointer text-red-600 focus:text-red-600"
                >
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>Sair</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </header>

      <div className="flex relative">
        {/* Mobile Overlay */}
        {sidebarOpen && (
          <div
            className="fixed inset-0 bg-black bg-opacity-50 z-40"
            onClick={() => setSidebarOpen(false)}
          />
        )}

        {/* Sidebar */}
        <aside
          className={`
            fixed top-[73px] bottom-0 left-0 z-50 w-48 bg-white shadow-lg
            transform transition-transform duration-300 ease-in-out
            ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}
        >
          <nav className="bg-white flex-1 py-2">
            <div className="space-y-1">
              <button
                onClick={() => router.push('/admin')}
                className={`w-full text-left px-4 py-3 text-sm font-medium transition-colors ${
                  activeSection === 'avaliacoes'
                    ? 'bg-purple-700 text-white'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                Avaliações
              </button>
              <button
                onClick={() => router.push('/admin/gerenciamento')}
                className={`w-full text-left px-4 py-3 text-sm font-medium transition-colors ${
                  activeSection === 'gerenciamento'
                    ? 'bg-purple-700 text-white'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                Gerenciamento
              </button>
            </div>
          </nav>
        </aside>

        {/* Main Content */}
        <main className="flex-1 p-6">
          {isLoading && <p>Carregando templates...</p>}
          {error && <p className="text-red-500">{error}</p>}

          {!isLoading && !error && templates.length === 0 && (
            <div className="text-center text-gray-500 py-10">
              <p className="text-lg">Nenhum template foi encontrado. </p>
              <p className="text-sm mt-2">Clique no card "<Plus className="inline h-4 w-4" />" para adicionar um novo.</p>
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* Template Cards */}
            {!isLoading && !error && templates.map((template) => (
              <div
                key={template.id}
                className="bg-white rounded-lg shadow-sm border p-6 hover:shadow-md transition-shadow relative"
              >
                <div className="absolute top-3 right-3 flex gap-2">
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-6 w-6 hover:bg-gray-100"
                    onClick={(e) => { e.preventDefault(); handleEditTemplate(template.id); }}
                    type="button"
                  >
                    <Edit className="h-4 w-4 text-gray-600" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-6 w-6 hover:bg-gray-100"
                    onClick={(e) => { e.preventDefault(); handleDeleteTemplate(template.id); }}
                    type="button"
                  >
                    <Trash2 className="h-4 w-4 text-gray-600" />
                  </Button>
                </div>
                <div className="space-y-2 pr-12">
                  <h3 className="font-semibold text-gray-900 text-lg">
                    {template.titulo}
                  </h3>
                  <p className="text-sm text-gray-500">
                    Criado em: {new Date(template.created_at).toLocaleDateString()}
                  </p>
                </div>
              </div>
            ))}

            {/* Add New Template Card */}
            <div
              onClick={handleAddTemplate}
              className="bg-white rounded-lg shadow-sm border p-6 hover:shadow-md transition-shadow cursor-pointer flex items-center justify-center min-h-[120px]"
            >
              <Plus className="h-12 w-12 text-gray-400" />
            </div>
          </div>
        </main>
      </div>

      {/* Template Editor Modal */}
      <Dialog open={editModalOpen} onOpenChange={setEditModalOpen}>
        <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editingTemplateId ? 'Editar Template' : 'Criar Novo Template'}</DialogTitle>
          </DialogHeader>

          <div className="space-y-6">
            {/* Template Name */}
            <div className="space-y-2">
              <Label htmlFor="templateName">Nome do template:</Label>
              <Input
                id="templateName"
                placeholder="Placeholder"
                value={templateName}
                onChange={(e) => setTemplateName(e.target.value)}
              />
            </div>

            {/* Questions */}
            {questions.filter(q => !q._destroy).map((question, index) => (
              <div
                key={question.id} // Chave única para cada questão
                className="space-y-4 p-4 border rounded-lg"
              >
                <h3 className="font-medium">Questão {index + 1}</h3>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Tipo:</Label>
                    <Select
                      value={question.type}
                      onValueChange={(value) =>
                        handleQuestionChange(question.id, 'type', value)
                      }
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Escala">Escala</SelectItem>
                        <SelectItem value="Texto">Texto</SelectItem>
                        <SelectItem value="Checkbox">Checkbox</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2 flex items-center gap-2 mt-4">
                    <input
                      type="checkbox"
                      id={`obrigatoria-${question.id}`}
                      checked={question.obrigatoria}
                      onChange={(e) =>
                        handleQuestionChange(question.id, 'obrigatoria', e.target.checked)
                      }
                      className="h-4 w-4 text-purple-600"
                    />
                    <Label htmlFor={`obrigatoria-${question.id}`}>Obrigatória</Label>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label>Texto:</Label>
                  <Input
                    placeholder="Placeholder"
                    value={question.text}
                    onChange={(e) =>
                      handleQuestionChange(question.id, 'text', e.target.value)
                    }
                  />
                </div>

                {(question.type === 'Escala' || question.type === 'Radio') && (
                  <div className="space-y-2">
                    <Label>Opções (separadas por vírgula):</Label>
                    <Input
                      placeholder="Ex: 5, 4, 3, 2, 1"
                      value={question.options || ''}
                      onChange={(e) =>
                        handleQuestionChange(
                          question.id,
                          'options',
                          e.target.value
                        )
                      }
                    />
                  </div>
                )}

                <div className="flex justify-center">
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    className="h-8 w-8 bg-red-500 rounded-full text-white hover:bg-red-600"
                    onClick={() => handleRemoveQuestion(question.id)}
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            ))}

            {/* Add Question Button */}
            <div className="flex justify-center">
              <Button
                variant="ghost"
                size="icon"
                className="w-8 h-8 bg-purple-700 rounded-full text-white hover:bg-purple-800"
                onClick={handleAddQuestion}
                type="button"
              >
                <Plus className="h-4 w-4" />
              </Button>
            </div>

            {/* Save Button */}
            <div className="flex justify-center pt-4">
              <Button
                onClick={handleSaveTemplate}
                className="bg-green-500 hover:bg-green-600 text-white px-8"
                type="button"
              >
                {editingTemplateId ? 'Salvar Alterações' : 'Criar'}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
'use client';

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
  questoes: Array<{ // Inclui as questões aninhadas
    id: number; // Questões já existentes terão ID
    tipo: string;
    enunciado: string;
    obrigatoria: boolean;
    opcoes?: string; // Mantém como string para o Input, depois será splitada
  }>;
}

// MODIFICADO: Interface Question para incluir 'obrigatoria'
interface Question {
  id: number;
  type: string;
  text: string;
  options?: string;
  obrigatoria: boolean; // NOVO: Adicionado campo obrigatoria
}

// URL base da sua API Ruby. Ajuste a porta se necessário (geralmente 3000 ou 3001)
const API_BASE_URL = 'http://localhost:3000/api/v1';

export default function GerenciamentoTemplatesPage() {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeSection, setActiveSection] = useState('gerenciamento');
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [templateName, setTemplateName] = useState('');

  // NOVO ESTADO: Para guardar o ID do template que está sendo editado. null = criação.
  const [editingTemplateId, setEditingTemplateId] = useState<number | null>(null);

  // MODIFICADO: Questões iniciais com obrigatoriedade padrão
  const [questions, setQuestions] = useState<Question[]>([
    { id: Date.now(), type: 'texto', text: '', obrigatoria: false, options: '' },
  ]);

  const [templates, setTemplates] = useState<Template[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchTemplates = async () => {
    setIsLoading(true);
    setError(null);
    try {
      console.log("DEBUG: Tentando buscar templates de:", `${API_BASE_URL}/templates`);
      const response = await fetch(`${API_BASE_URL}/templates`);
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

  // NOVO: Função para carregar os detalhes de um template específico para edição
  const loadTemplateForEdit = async (id: number) => {
    setIsLoading(true); // Pode ser um loading específico para o modal
    setError(null);
    try {
      console.log(`DEBUG: Carregando detalhes do template ID: ${id}`);
      const response = await fetch(`${API_BASE_URL}/templates/${id}`);
      if (!response.ok) {
        const errorBody = await response.text();
        throw new Error(`Erro ao carregar template: Status ${response.status} - ${errorBody}`);
      }
      const data: Template = await response.json();

      setTemplateName(data.titulo);
      // Mapeia as questões do backend para o formato do estado 'questions' do frontend
      setQuestions(
        data.questoes.map(q => ({
          id: q.id, // Usa o ID do banco para questões existentes
          type: q.tipo,
          text: q.enunciado,
          obrigatoria: q.obrigatoria,
          options: q.opcoes || '' // Garante que options é string vazia se undefined
        }))
      );
    } catch (err: any) {
      console.error("Erro ao carregar template para edição:", err);
      setError(`Não foi possível carregar os detalhes do template: ${err.message}`);
      setEditModalOpen(false); // Fecha o modal se houver erro ao carregar
    } finally {
      setIsLoading(false);
    }
  };


  const handleLogout = () => {
    console.log('Admin logout clicked');
  };

  const handleSectionChange = (section: string) => {
    setActiveSection(section);
    console.log('Navigating to:', section);
  };

  // MODIFICADO: handleEditTemplate para setar o ID e carregar os dados
  // FUNÇÃO 1: handleEditTemplate (chama quando clica no lápis)
  const handleEditTemplate = (templateId: number) => {
    console.log('DEBUG: Clicou em Editar Template ID:', templateId);
    setEditingTemplateId(templateId); // <--- AQUI O ID DO TEMPLATE É SETADO!
    loadTemplateForEdit(templateId);
    setEditModalOpen(true);
  };

  const handleDeleteTemplate = async (templateId: number) => {
    // NOVO: Log de depuração para confirmar que a função foi chamada
    console.log('DEBUG: handleDeleteTemplate foi chamado para o ID:', templateId);

    // Adiciona uma confirmação antes de tentar excluir
    if (!window.confirm('Tem certeza que deseja excluir este template? Esta ação é irreversível.')) {
      console.log('DEBUG: Exclusão cancelada pelo usuário.'); // NOVO: Log se o usuário cancelar
      return; // Sai da função se o usuário cancelar
    }

    try {
      console.log(`DEBUG: Enviando requisição DELETE para: ${API_BASE_URL}/templates/${templateId}`); // NOVO: Log da URL da requisição

      const response = await fetch(`${API_BASE_URL}/templates/${templateId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          // Se precisar de CSRF para DELETE, adicione aqui, mas geralmente não é necessário para APIs RESTful
          // let csrfToken = '';
          // const csrfMeta = document.querySelector("meta[name='csrf-token']");
          // if (csrfMeta) {
          //   csrfToken = csrfMeta.getAttribute("content") || '';
          // }
          // ...(csrfToken && { 'X-CSRF-Token': csrfToken })
        },
      });

      if (response.ok) { // Sucesso é status 200 ou 204 (No Content)
        alert('Template excluído com sucesso!');
        console.log('DEBUG: Template excluído com sucesso. Recarregando lista...'); // NOVO: Log de sucesso
        fetchTemplates(); // Recarrega a lista para remover o template excluído da UI
      } else {
        const errorBody = await response.text(); // Pega o corpo da resposta de erro
        let errorMessage = "Erro desconhecido ao excluir template.";
        try { // Tenta parsear como JSON se for um erro formatado
          const errorData = JSON.parse(errorBody);
          if (errorData.erro) {
              errorMessage = errorData.erro;
          } else if (errorData.message) {
              errorMessage = errorData.message;
          }
        } catch (e) {
          // Se não for JSON, usa o corpo da resposta como mensagem
          errorMessage = errorBody || "Mensagem de erro não disponível.";
        }
        console.error('DEBUG: Erro ao excluir template:', response.status, errorMessage); // NOVO: Log de erro
        alert(`Erro ao excluir template:\nStatus: ${response.status}\nDetalhes: ${errorMessage}`);
      }
    } catch (error: any) {
      console.error('DEBUG: Falha na comunicação com o servidor ao excluir:', error); // NOVO: Log para erros de rede
      alert('Não foi possível conectar ao servidor para excluir o template.');
    }
  };

  // MODIFICADO: handleAddTemplate para garantir que é um NOVO template
  const handleAddTemplate = () => {
    console.log('DEBUG: Clicou em Adicionar Novo Template');
    setEditingTemplateId(null); // <--- AQUI O ID É DEFINIDO COMO NULO PARA CRIAÇÃO!
    setTemplateName('');
    setQuestions([{ id: Date.now(), type: 'texto', text: '', obrigatoria: false, options: '' }]);
    setEditModalOpen(true);
  };

  const handleAddQuestion = () => {
    const newQuestion: Question = {
      id: Date.now(), // NOVO: ID único para novas questões no frontend
      type: 'texto',
      text: '',
      obrigatoria: false, // NOVO: Valor padrão para obrigatoriedade
      options: '',
    };
    setQuestions([...questions, newQuestion]);
  };

  const handleQuestionChange = (
    questionId: number,
    field: string,
    value: string | boolean // MODIFICADO: 'value' pode ser string ou boolean para 'obrigatoria'
  ) => {
    setQuestions(
      questions.map((q) => (q.id === questionId ? { ...q, [field]: value } : q))
    );
  };

  // NOVO: Função para remover uma questão do formulário
  const handleRemoveQuestion = (idToRemove: number) => {
    // Se a questão tiver um ID do banco de dados, marcamos ela para _destroy no payload.
    // Se não tiver (foi recém-adicionada no frontend), simplesmente a removemos.
    const updatedQuestions = questions
      .map(q => q.id === idToRemove && typeof q.id === 'number' ? { ...q, _destroy: true } : q)
      .filter(q => !(q.id === idToRemove && typeof q.id !== 'number')); // Remove questões sem ID do banco na hora
    setQuestions(updatedQuestions);
  };


  const handleSaveTemplate = async () => {
    // ESTES CONSOLE.LOGs SÃO CRÍTICOS PARA ENTENDER O QUE ESTÁ ACONTECENDO!
    console.log("DEBUG: Valor de editingTemplateId ao salvar:", editingTemplateId); // Mostra o ID no momento do clique

    const method = editingTemplateId ? 'PUT' : 'POST';
    const url = editingTemplateId ? `${API_BASE_URL}/templates/${editingTemplateId}` : `${API_BASE_URL}/templates`;

    console.log(`DEBUG: Requisição Final: Método ${method}, URL ${url}`); // Mostra qual requisição será feita

    const questionsToSend = questions.map(q => {
      if (q._destroy) {
        return { id: q.id, _destroy: true };
      }
      return {
        id: typeof q.id === 'number' && q.id > 0 ? q.id : undefined,
        tipo: q.type,
        enunciado: q.text,
        obrigatoria: q.obrigatoria,
        opcoes: q.options ? q.options.split(',').map(item => item.trim()) : [],
      };
    }).filter(q => q.enunciado.trim() !== '' || q._destroy);


    const payload = {
      template: {
        titulo: templateName,
        questoes_attributes: questionsToSend
      }
    };

    console.log("DEBUG: Enviando payload:", payload); // Mostra o que será enviado para o Rails

    try {
      let csrfToken = '';
      const csrfMeta = document.querySelector("meta[name='csrf-token']");
      if (csrfMeta) {
        csrfToken = csrfMeta.getAttribute("content") || '';
      }
      
      const response = await fetch(url, {
        method: method,
        headers: {
          'Content-Type': 'application/json',
          ...(csrfToken && { 'X-CSRF-Token': csrfToken })
        },
        body: JSON.stringify(payload)
      });

      if (response.ok) {
        const result = await response.json();
        alert(result.mensagem);
        setEditModalOpen(false);
        fetchTemplates();
      } else {
        const errorData = await response.json();
        let errorMessage = "Erro desconhecido ao salvar template.";
        if (errorData.erro) {
            errorMessage = errorData.erro;
        } else if (errorData.errors) {
            errorMessage = Object.entries(errorData.errors)
                                .map(([field, messages]) => `${field}: ${(messages as string[]).join(', ')}`)
                                .join('\n');
        } else if (errorData.message) {
            errorMessage = errorData.message;
        }
        alert(`Erro ao salvar:\n${errorMessage}`);
      }
    } catch (error) {
      console.error('Falha na comunicação com o servidor:', error);
      alert('Não foi possível conectar ao servidor. Tente novamente.');
    }
  };

  const router = useRouter();

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
              <p className="text-lg">Nenhum template foi encontrado.</p>
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
                    onClick={() => handleEditTemplate(template.id)}
                  >
                    <Edit className="h-4 w-4 text-gray-600" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-6 w-6 hover:bg-gray-100"
                    onClick={() => handleDeleteTemplate(template.id)}
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
            {/* MODIFICADO: Título dinâmico do modal */}
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
            {questions.map((question, index) => (
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
                        <SelectItem value="Radio">Radio</SelectItem> {/* NOVO: Adicionado Radio */}
                      </SelectContent>
                    </Select>
                  </div>
                  {/* NOVO: Campo para Obrigatoriedade */}
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

                {(question.type === 'Escala' || question.type === 'Radio') && ( // MODIFICADO: 'radio' para 'Radio'
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
                  {/* NOVO: Botão para remover questão */}
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
              >
                <Plus className="h-4 w-4" />
              </Button>
            </div>

            {/* Save Button */}
            <div className="flex justify-center pt-4">
              <Button
                onClick={handleSaveTemplate}
                className="bg-green-500 hover:bg-green-600 text-white px-8"
              >
                {/* MODIFICADO: Texto do botão dinâmico */}
                {editingTemplateId ? 'Salvar Alterações' : 'Criar'}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
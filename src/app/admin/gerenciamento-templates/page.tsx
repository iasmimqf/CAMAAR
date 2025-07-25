'use client';

import { useAuth } from '@/contexts/AuthContext';
import { Edit, Trash2, Plus, Loader2, Menu, X, LogOut } from 'lucide-react';
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
import { api } from '@/lib/api';
import { toast } from 'sonner'; // <<< 1. Importe o toast

// Interfaces (sem alterações)
interface Template {
  id: number;
  titulo: string;
  created_at: string;
  questoes: Array<{
    id?: number;
    tipo: string;
    enunciado: string;
    obrigatoria: boolean;
    opcoes?: string;
    _destroy?: boolean;
  }>;
}

interface Question {
  id: number | string;
  type: string;
  text: string;
  options?: string;
  obrigatoria: boolean;
  _destroy?: boolean;
}

export default function GerenciamentoTemplatesPage() {
  const { logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeSection, setActiveSection] = useState('gerenciamento');
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [templateName, setTemplateName] = useState('');
  const [editingTemplateId, setEditingTemplateId] = useState<number | null>(null);
  const [questions, setQuestions] = useState<Question[]>([
    { id: 'new-temp-1', type: 'texto', text: '', obrigatoria: false, options: '' },
  ]);
  const [templates, setTemplates] = useState<Template[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const fetchTemplates = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await api.get('/templates');
      setTemplates(response.data);
    } catch (err: any) {
      setError("Não foi possível carregar os templates.");
      console.error("Erro ao buscar templates:", err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchTemplates();
  }, []);

  const loadTemplateForEdit = async (id: number) => {
    try {
      const response = await api.get(`/templates/${id}`);
      const data = response.data;
      setTemplateName(data.titulo);
      setQuestions(
        data.questoes.map((q: any) => ({
          id: q.id,
          type: q.tipo,
          text: q.enunciado,
          obrigatoria: q.obrigatoria,
          options: q.opcoes_array?.join(', ') || ''
        }))
      );
    } catch (err: any) {
      setError(`Não foi possível carregar os detalhes do template.`);
      console.error("Erro ao carregar template para edição:", err);
      setEditModalOpen(false);
    }
  };

  // ===============================================================
  // ▼▼▼ FUNÇÕES ATUALIZADAS PARA USAR 'toast' ▼▼▼
  // ===============================================================
  const handleDeleteTemplate = async (templateId: number) => {
    if (!window.confirm('Tem a certeza que deseja excluir este template?')) return;

    try {
      const response = await api.delete(`/templates/${templateId}`);
      toast.success(response.data.mensagem || 'Template excluído com sucesso!');
      fetchTemplates();
    } catch (error: any) {
      const errorMessage = error.response?.data?.erro || 'Não foi possível conectar ao servidor.';
      toast.error(`Erro ao excluir: ${errorMessage}`);
      console.error('Erro ao excluir template:', error);
    }
  };

  const handleSaveTemplate = async () => {
    if (!templateName.trim()) {
      toast.error('O título do template é obrigatório.');
      return;
    }
    
    const questionsToSend = questions
      .filter(q => q.text?.trim() !== '' || q._destroy)
      .map(q => ({
        id: typeof q.id === 'number' ? q.id : undefined,
        tipo: q.type,
        enunciado: q.text,
        obrigatoria: q.obrigatoria,
        opcoes: q.options ? q.options.split(',').map(item => item.trim()) : [],
        _destroy: q._destroy
      }));

    if (questionsToSend.filter(q => !q._destroy).length === 0) {
      toast.error('Adicione pelo menos uma questão válida.');
      return;
    }

    const payload = {
      template: {
        titulo: templateName,
        questoes_attributes: questionsToSend
      }
    };

    try {
      let response;
      if (editingTemplateId) {
        response = await api.put(`/templates/${editingTemplateId}`, payload);
      } else {
        response = await api.post('/templates', payload);
      }
      toast.success(response.data.mensagem);
      setEditModalOpen(false);
      fetchTemplates();
    } catch (error: any) {
      const errorMessage = error.response?.data?.erro || 'Não foi possível conectar ao servidor.';
      toast.error(`Erro ao salvar: ${errorMessage}`);
      console.error('Erro ao salvar template:', error);
    }
  };
  // ===============================================================

  const handleEditTemplate = (templateId: number) => {
    setEditingTemplateId(templateId);
    loadTemplateForEdit(templateId);
    setEditModalOpen(true);
  };
  
  const handleAddTemplate = () => {
    setEditingTemplateId(null);
    setTemplateName('');
    setQuestions([{ id: `new-${Date.now()}`, type: 'Texto', text: '', obrigatoria: false, options: '' }]);
    setEditModalOpen(true);
  };

  const handleAddQuestion = () => {
    setQuestions([...questions, { id: `new-${Date.now()}`, type: 'Texto', text: '', obrigatoria: false, options: '' }]);
  };

  const handleQuestionChange = (id: number | string, field: string, value: string | boolean) => {
    setQuestions(questions.map(q => (q.id === id ? { ...q, [field]: value } : q)));
  };

  const handleRemoveQuestion = (id: number | string) => {
    setQuestions(questions.map(q => {
      if (q.id === id) {
        return typeof q.id === 'number' ? { ...q, _destroy: true } : null;
      }
      return q;
    }).filter(Boolean) as Question[]);
  };

  const renderContent = () => {
    if (isLoading) {
      return (
        <div className="flex justify-center items-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-purple-700" />
          <p className="ml-4">A carregar templates...</p>
        </div>
      );
    }
    if (error) {
      return <p className="text-red-500 text-center">{error}</p>;
    }
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {templates.map((template) => (
          <div key={template.id} className="bg-white rounded-lg shadow-sm border p-6 hover:shadow-md transition-shadow relative">
            <div className="absolute top-3 right-3 flex gap-2">
              <Button variant="ghost" size="icon" className="h-6 w-6 hover:bg-gray-100" onClick={() => handleEditTemplate(template.id)}>
                <Edit className="h-4 w-4 text-gray-600" />
              </Button>
              <Button variant="ghost" size="icon" className="h-6 w-6 hover:bg-gray-100" onClick={() => handleDeleteTemplate(template.id)}>
                <Trash2 className="h-4 w-4 text-gray-600" />
              </Button>
            </div>
            <div className="space-y-2 pr-12">
              <h3 className="font-semibold text-gray-900 text-lg">{template.titulo}</h3>
              <p className="text-sm text-gray-500">Criado em: {new Date(template.created_at).toLocaleDateString()}</p>
            </div>
          </div>
        ))}
        <div onClick={handleAddTemplate} className="bg-white rounded-lg shadow-sm border p-6 hover:shadow-md transition-shadow cursor-pointer flex items-center justify-center min-h-[120px]">
          <Plus className="h-12 w-12 text-gray-400" />
        </div>
      </div>
    );
  };

  return (
    <>
      <div className="min-h-screen bg-gray-200">
        <header className="bg-white shadow-sm border-b relative z-[60]">
          <div className="flex items-center justify-between px-4 py-3">
            <div className="flex items-center gap-4">
              <Button variant="ghost" size="icon" onClick={() => setSidebarOpen(!sidebarOpen)}>
                {sidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
              </Button>
              <h1 className="text-lg font-medium">Gerenciamento - Templates</h1>
            </div>
            <div className="flex items-center gap-4">
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" className="w-8 h-8 bg-purple-700 rounded-full flex items-center justify-center text-white font-medium text-sm hover:bg-purple-800 transition-colors">
                    U
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
                <button onClick={() => router.push('/admin')} className="w-full text-left px-4 py-3 text-sm font-medium text-gray-700 hover:bg-gray-100">
                  Avaliações
                </button>
                <button onClick={() => router.push('/admin/gerenciamento')} className="w-full text-left px-4 py-3 text-sm font-medium bg-purple-700 text-white">
                  Gerenciamento
                </button>
              </div>
            </nav>
          </aside>

          <main className="flex-1 p-6 w-full md:pl-48">
            {renderContent()}
          </main>
        </div>
      </div>

      <Dialog open={editModalOpen} onOpenChange={setEditModalOpen}>
        <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editingTemplateId ? 'Editar Template' : 'Criar Novo Template'}</DialogTitle>
          </DialogHeader>
          <div className="space-y-6">
            <div className="space-y-2">
              <Label htmlFor="templateName">Nome do template:</Label>
              <Input id="templateName" placeholder="Ex: Avaliação Semestral de Disciplina" value={templateName} onChange={(e) => setTemplateName(e.target.value)} />
            </div>
            {questions.filter(q => !q._destroy).map((question, index) => (
              <div key={question.id} className="space-y-4 p-4 border rounded-lg">
                <div className="flex justify-between items-center">
                  <h3 className="font-medium">Questão {index + 1}</h3>
                  <Button type="button" variant="ghost" size="icon" className="h-8 w-8 bg-red-500 rounded-full text-white hover:bg-red-600" onClick={() => handleRemoveQuestion(question.id)}>
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Tipo:</Label>
                    <Select value={question.type} onValueChange={(value) => handleQuestionChange(question.id, 'type', value)}>
                      <SelectTrigger><SelectValue /></SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Escala">Escala</SelectItem>
                        <SelectItem value="Texto">Texto</SelectItem>
                        <SelectItem value="Checkbox">Checkbox</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2 flex items-center gap-2 pt-6">
                    <input type="checkbox" id={`obrigatoria-${question.id}`} checked={question.obrigatoria} onChange={(e) => handleQuestionChange(question.id, 'obrigatoria', e.target.checked)} className="h-4 w-4" />
                    <Label htmlFor={`obrigatoria-${question.id}`}>Obrigatória</Label>
                  </div>
                </div>
                <div className="space-y-2">
                  <Label>Texto da Pergunta:</Label>
                  <Input placeholder="Ex: Qual a sua avaliação sobre o professor?" value={question.text} onChange={(e) => handleQuestionChange(question.id, 'text', e.target.value)} />
                </div>
                {(question.type === 'Escala' || question.type === 'Checkbox') && (
                  <div className="space-y-2">
                    <Label>Opções (separadas por vírgula):</Label>
                    <Input placeholder="Ex: Muito Bom, Bom, Regular, Ruim" value={question.options || ''} onChange={(e) => handleQuestionChange(question.id, 'options', e.target.value)} />
                  </div>
                )}
              </div>
            ))}
            <div className="flex justify-center">
              <Button variant="outline" size="icon" className="w-8 h-8 rounded-full" onClick={handleAddQuestion}>
                <Plus className="h-4 w-4" />
              </Button>
            </div>
            <div className="flex justify-end pt-4">
              <Button onClick={handleSaveTemplate} className="bg-green-600 hover:bg-green-700 text-white px-8">
                {editingTemplateId ? 'Salvar Alterações' : 'Criar Template'}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}
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
import { useState } from 'react';

import { useRouter } from 'next/navigation';

interface Question {
  id: number;
  type: string;
  text: string;
  options?: string;
}

export default function GerenciamentoTemplatesPage() {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeSection, setActiveSection] = useState('gerenciamento');
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [templateName, setTemplateName] = useState('');
  const [questions, setQuestions] = useState<Question[]>([
    { id: 1, type: 'radio', text: '', options: '' },
    { id: 2, type: 'texto', text: '' },
  ]);

  const templates = [
    { id: 1, name: 'Template 1', semester: 'semestre' },
    { id: 2, name: 'Template 1', semester: 'semestre' },
    { id: 3, name: 'Template 1', semester: 'semestre' },
    { id: 4, name: 'Template 1', semester: 'semestre' },
    { id: 5, name: 'Template 1', semester: 'semestre' },
  ];

  const handleLogout = () => {
    console.log('Admin logout clicked');
  };

  const handleSectionChange = (section: string) => {
    setActiveSection(section);
    console.log('Navigating to:', section);
  };

  const handleEditTemplate = (templateId: number) => {
    console.log('Edit template:', templateId);
    setEditModalOpen(true);
    setTemplateName('Template 1');
  };

  const handleDeleteTemplate = (templateId: number) => {
    console.log('Delete template:', templateId);
  };

  const handleAddTemplate = () => {
    console.log('Add new template');
    setEditModalOpen(true);
    setTemplateName('');
    setQuestions([{ id: 1, type: 'radio', text: '', options: '' }]);
  };

  const handleAddQuestion = () => {
    const newQuestion: Question = {
      id: questions.length + 1,
      type: 'texto',
      text: '',
      options: '',
    };
    setQuestions([...questions, newQuestion]);
  };

  const handleQuestionChange = (
    questionId: number,
    field: string,
    value: string
  ) => {
    setQuestions(
      questions.map((q) => (q.id === questionId ? { ...q, [field]: value } : q))
    );
  };

  const handleSaveTemplate = () => {
    console.log('Save template:', { templateName, questions });
    setEditModalOpen(false);
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
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* Template Cards */}
            {templates.map((template) => (
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
                    {template.name}
                  </h3>
                  <p className="text-sm text-gray-500">{template.semester}</p>
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
            <DialogTitle>Editar Template</DialogTitle>
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
                key={question.id}
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
                        <SelectItem value="radio">Radio</SelectItem>
                        <SelectItem value="texto">Texto</SelectItem>
                        <SelectItem value="checkbox">Checkbox</SelectItem>
                      </SelectContent>
                    </Select>
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

                {question.type === 'radio' && (
                  <div className="space-y-2">
                    <Label>Opções:</Label>
                    <Input
                      placeholder="Placeholder"
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
                    variant="ghost"
                    size="icon"
                    className="w-8 h-8 bg-gray-400 rounded-full text-white hover:bg-gray-500"
                    onClick={() => {
                      /* Add option logic */
                    }}
                  >
                    <Plus className="h-4 w-4" />
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
                Criar
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

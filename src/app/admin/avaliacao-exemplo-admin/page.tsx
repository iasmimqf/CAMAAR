'use client';

import { useAuth } from '@/contexts/AuthContext'; // <<< 1. Importe o nosso hook
import { Search, Menu, X, LogOut, ArrowRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Label } from '@/components/ui/label';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useState } from 'react';

export default function AvaliacaoPage() {
  const { logout } = useAuth(); // <<< 2. Obtenha a função de logout do contexto
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [question1, setQuestion1] = useState('');
  const [question2, setQuestion2] = useState('');
  const [question3, setQuestion3] = useState('');
  const [question4, setQuestion4] = useState('');
  const [activeSection, setActiveSection] = useState('avaliacoes');

  const handleLogout = () => {
    logout(); // <<< 3. Chame a função de logout
  };

  const handleSubmit = () => {
    console.log('avaliacao submitted:', {
      question1,
      question2,
      question3,
      question4,
    });
  };

  const handleSectionChange = (section: string) => {
    setActiveSection(section);
    console.log('Navigating to:', section);
  };

  const ratingOptions = [
    { value: 'muito-bom', label: 'Muito bom' },
    { value: 'bom', label: 'Bom' },
    { value: 'satisfatorio', label: 'Satisfatório' },
    { value: 'ruim', label: 'Ruim' },
    { value: 'pessimo', label: 'Péssimo' },
  ];

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
            <h1 className="text-lg font-medium">
              Avaliação - Nome da matéria - Semestre
            </h1>
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
         fixed top-[73px] bottom-0 left-0 z-50
         w-48 bg-white shadow-lg
         transform transition-transform duration-300 ease-in-out
         ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
        `}
        >
          <nav className="bg-white flex-1 py-2">
            <div className="space-y-1">
              <button
                onClick={() => handleSectionChange('avaliacoes')}
                className={`w-full text-left px-4 py-3 text-sm font-medium transition-colors ${
                  activeSection === 'avaliacoes'
                    ? 'bg-purple-700 text-white'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                Avaliações
              </button>
              <button
                onClick={() => handleSectionChange('gerenciamento')}
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
          <div className="max-w-4xl mx-auto">
            <div className="bg-white rounded-lg shadow-sm p-8">
              <div className="space-y-8">
                {/* Question 1 - Rating */}
                <div className="bg-gray-100 p-6 rounded-lg">
                  <h3 className="font-medium text-gray-900 mb-4">Pergunta</h3>
                  <RadioGroup value={question1} onValueChange={setQuestion1}>
                    <div className="space-y-3">
                      {ratingOptions.map((option) => (
                        <div
                          key={option.value}
                          className="flex items-center space-x-2"
                        >
                          <RadioGroupItem
                            value={option.value}
                            id={`q1-${option.value}`}
                          />
                          <Label
                            htmlFor={`q1-${option.value}`}
                            className="text-sm font-normal"
                          >
                            {option.label}
                          </Label>
                        </div>
                      ))}
                    </div>
                  </RadioGroup>
                </div>

                {/* Question 2 - Text Input */}
                <div className="bg-gray-100 p-6 rounded-lg">
                  <h3 className="font-medium text-gray-900 mb-4">Pergunta</h3>
                  <Input
                    placeholder="Resposta"
                    value={question2}
                    onChange={(e) => setQuestion2(e.target.value)}
                    className="w-full"
                  />
                </div>

                {/* Question 3 - Text Input */}
                <div className="bg-gray-100 p-6 rounded-lg">
                  <h3 className="font-medium text-gray-900 mb-4">Pergunta</h3>
                  <Input
                    placeholder="Resposta"
                    value={question3}
                    onChange={(e) => setQuestion3(e.target.value)}
                    className="w-full"
                  />
                </div>

                {/* Question 4 - Rating */}
                <div className="bg-gray-100 p-6 rounded-lg">
                  <h3 className="font-medium text-gray-900 mb-4">Pergunta</h3>
                  <RadioGroup value={question4} onValueChange={setQuestion4}>
                    <div className="space-y-3">
                      {ratingOptions.map((option) => (
                        <div
                          key={option.value}
                          className="flex items-center space-x-2"
                        >
                          <RadioGroupItem
                            value={option.value}
                            id={`q4-${option.value}`}
                          />
                          <Label
                            htmlFor={`q4-${option.value}`}
                            className="text-sm font-normal"
                          >
                            {option.label}
                          </Label>
                        </div>
                      ))}
                    </div>
                  </RadioGroup>
                </div>
              </div>
            </div>
          </div>

          {/* Submit Button */}
          <div className="fixed bottom-6 right-6">
            <Button
              onClick={handleSubmit}
              className="w-12 h-12 bg-purple-700 hover:bg-purple-800 rounded-full flex items-center justify-center shadow-lg"
            >
              <ArrowRight className="h-5 w-5 text-white" />
            </Button>
          </div>
        </main>
      </div>
    </div>
  );
}
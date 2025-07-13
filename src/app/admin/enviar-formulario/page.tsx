'use client';

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
import { useState } from 'react';

import { useRouter } from 'next/navigation';

interface Course {
  id: string;
  name: string;
  semester: string;
  code: string;
  selected: boolean;
}

export default function EnviarFormularioPage() {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeSection, setActiveSection] = useState('gerenciamento');
  const [selectedTemplate, setSelectedTemplate] = useState('');
  const [courses, setCourses] = useState<Course[]>([
    {
      id: '1',
      name: 'Estudos Em',
      semester: '2024.1',
      code: 'CIC1024',
      selected: true,
    },
    {
      id: '2',
      name: 'Estudos Em',
      semester: '2024.1',
      code: 'CIC1024',
      selected: false,
    },
    {
      id: '3',
      name: 'Matemática Discreta',
      semester: '2024.1',
      code: 'MAT1001',
      selected: false,
    },
    {
      id: '4',
      name: 'Programação Web',
      semester: '2024.1',
      code: 'WEB2002',
      selected: true,
    },
  ]);

  const handleLogout = () => {
    console.log('Admin logout clicked');
  };

  const handleSectionChange = (section: string) => {
    setActiveSection(section);
    console.log('Navigating to:', section);
  };

  const handleCourseSelect = (id: string, checked: boolean) => {
    setCourses(
      courses.map((course) =>
        course.id === id ? { ...course, selected: checked } : course
      )
    );
  };

  const handleSendForms = () => {
    const selectedCourses = courses.filter((course) => course.selected);
    console.log(
      'Sending forms for template:',
      selectedTemplate,
      'to courses:',
      selectedCourses
    );
    // Lógica para enviar formulários
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
            <h1 className="text-lg font-medium">Gerenciamento</h1>
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
          <div className="flex items-center justify-center min-h-[calc(100vh-200px)]">
            <div className="bg-white rounded-lg shadow-sm p-8 w-full max-w-2xl">
              <div className="space-y-6">
                {/* Template Selection */}
                <div className="flex items-center gap-4">
                  <label
                    htmlFor="template-select"
                    className="text-sm font-medium text-gray-700"
                  >
                    Template:
                  </label>
                  <Select
                    value={selectedTemplate}
                    onValueChange={setSelectedTemplate}
                  >
                    <SelectTrigger id="template-select" className="w-[200px]">
                      <SelectValue placeholder="Template" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="template1">Template 1</SelectItem>
                      <SelectItem value="template2">Template 2</SelectItem>
                      <SelectItem value="template3">Template 3</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                {/* Course List */}
                <div className="border rounded-md overflow-hidden">
                  <div className="grid grid-cols-[auto_1fr_auto_auto] gap-4 p-4 bg-gray-50 text-sm font-medium text-gray-700">
                    <div></div> {/* Checkbox column header */}
                    <div>Nome</div>
                    <div>Semestre</div>
                    <div>Código</div>
                  </div>
                  {courses.map((course) => (
                    <div
                      key={course.id}
                      className="grid grid-cols-[auto_1fr_auto_auto] gap-4 items-center p-4 border-t"
                    >
                      <Checkbox
                        id={`course-${course.id}`}
                        checked={course.selected}
                        onCheckedChange={(checked) =>
                          handleCourseSelect(course.id, checked as boolean)
                        }
                      />
                      <label
                        htmlFor={`course-${course.id}`}
                        className="text-sm font-normal text-gray-800"
                      >
                        {course.name}
                      </label>
                      <div className="text-sm text-gray-600">
                        {course.semester}
                      </div>
                      <div className="text-sm text-gray-600">{course.code}</div>
                    </div>
                  ))}
                </div>

                {/* Send Button */}
                <div className="flex justify-end">
                  <Button
                    onClick={handleSendForms}
                    className="bg-green-500 hover:bg-green-600 text-white font-medium py-2 px-6 rounded-md transition-colors duration-200"
                  >
                    Enviar
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}

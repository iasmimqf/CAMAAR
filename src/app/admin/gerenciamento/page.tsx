"use client"

import { useAuth } from "@/contexts/AuthContext"; // <<< 1. Importe o nosso hook
import { Search, Menu, X, LogOut } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { useState, useRef } from "react"
import { useRouter } from "next/navigation";

export default function GerenciamentoPage() {
  const { logout } = useAuth(); // <<< 2. Obtenha a função de logout do contexto
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [activeSection, setActiveSection] = useState("gerenciamento")
  const [importDataModalOpen, setImportDataModalOpen] = useState(false)
  const [uploadType, setUploadType] = useState<"turmas" | "alunos" | null>(null);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const router = useRouter();

  const handleLogout = () => {
    logout(); // <<< 3. Chame a função de logout
  }

  const handleManagementAction = (action: string) => {
    if (action === "importar-dados") {
      setImportDataModalOpen(true)
    }
  }

  const handleFileUpload = async () => {
    if (!selectedFile || !uploadType) {
      alert("Por favor, selecione um ficheiro e um tipo de importação.");
      return;
    }

    const uploadPath = uploadType === 'turmas'
        ? 'http://localhost:3000/admin/importacoes/importar_turmas' // Rota completa
        : 'http://localhost:3000/admin/importacoes/importar_alunos';   // Rota futura para alunos

    const formData = new FormData();
    formData.append('file', selectedFile);

    try {
      const response = await fetch(uploadPath, {
        method: 'POST',
        body: formData,
        headers: {
          'Accept': 'application/json',
        },
        credentials: 'include',
      });

      const contentType = response.headers.get("content-type");
      if (!contentType || !contentType.includes("application/json")) {
        const textResponse = await response.text();
        throw new Error(`O servidor respondeu com um formato inesperado. Verifique se está autenticado. Resposta: ${textResponse.substring(0, 100)}...`);
      }

      const result = await response.json();

      if (response.ok) {
        alert(result.notice || "Ficheiro enviado com sucesso!");
      } else {
        alert(result.alert || "Ocorreu um erro durante a importação.");
      }
    } catch (error) {
      console.error("Erro de rede ou de parse:", error);
      alert(error instanceof Error ? error.message : "Ocorreu um erro desconhecido.");
    } finally {
      setImportDataModalOpen(false);
      setUploadType(null);
      setSelectedFile(null);
    }
  };

  return (
    <div className="min-h-screen bg-gray-200">
      {/* Header e Sidebar (sem alterações) */}
      <header className="bg-white shadow-sm border-b relative z-[60]">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => setSidebarOpen(!sidebarOpen)}>
              {sidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </Button>
            <h1 className="text-lg font-medium">Gerenciamento</h1>
          </div>
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input placeholder="Search..." className="pl-10 w-64 rounded-full border-gray-300" />
            </div>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="w-8 h-8 bg-purple-700 rounded-full flex items-center justify-center text-white font-medium text-sm hover:bg-purple-800 transition-colors">
                  U
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-40 z-[70]">
                <DropdownMenuItem onClick={handleLogout} className="cursor-pointer text-red-600 focus:text-red-600">
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>Sair</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </header>
      <div className="flex relative">
        {sidebarOpen && (<div className="fixed inset-0 bg-black bg-opacity-50 z-40" onClick={() => setSidebarOpen(false)} />)}
        <aside
          className={`
            fixed top-[73px] bottom-0 left-0 z-50 w-48 bg-white shadow-lg
            transform transition-transform duration-300 ease-in-out
            ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}
        >
          <nav className="bg-white flex-1 py-2">
            <div className="space-y-1">
              <button onClick={() => router.push('/admin')} className={`w-full text-left px-4 py-3 text-sm font-medium transition-colors ${activeSection === 'avaliacoes' ? 'bg-purple-700 text-white' : 'text-gray-700 hover:bg-gray-100'}`}>
                Avaliações
              </button>
              <button onClick={() => router.push('/admin/gerenciamento')} className={`w-full text-left px-4 py-3 text-sm font-medium transition-colors ${activeSection === 'gerenciamento' ? 'bg-purple-700 text-white' : 'text-gray-700 hover:bg-gray-100'}`}>
                Gerenciamento
              </button>
            </div>
          </nav>
        </aside>

        {/* Conteúdo Principal (sem alterações) */}
        <main className="flex-1 p-6">
          <div className="flex items-center justify-center min-h-[calc(100vh-200px)]">
            <div className="bg-white rounded-lg shadow-sm p-12 w-full max-w-md">
              <div className="space-y-4">
                <Button onClick={() => handleManagementAction("importar-dados")} className="w-full bg-green-500 hover:bg-green-800 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200">
                  Importar dados
                </Button>
                <Button onClick={() => router.push('/admin/gerenciamento-templates')} className="w-full bg-green-500 hover:bg-green-800 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200">
                  Editar Templates
                </Button>
                <Button onClick={() => router.push('/admin/enviar-formulario')} className="w-full bg-green-500 hover:bg-green-800 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200">
                  Enviar Formulários
                </Button>
                <Button onClick={() => router.push('/admin/resultado')} className="w-full bg-green-500 hover:bg-green-800 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200">
                  Resultados
                </Button>
              </div>
            </div>
          </div>
        </main>
      </div>

      {/* Modal (sem alterações na lógica de exibição) */}
      <Dialog open={importDataModalOpen} onOpenChange={(isOpen) => {
        if (!isOpen) {
          setImportDataModalOpen(false);
          setUploadType(null);
          setSelectedFile(null);
        } else {
            setImportDataModalOpen(true);
        }
      }}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>
              {uploadType === 'turmas' && 'Importar Ficheiro de Turmas'}
              {uploadType === 'alunos' && 'Importar Ficheiro de Alunos'}
              {!uploadType && 'Importar Dados'}
            </DialogTitle>
          </DialogHeader>
          {!uploadType ? (
              <div className="grid gap-4 py-4">
                <Button onClick={() => setUploadType('turmas')} className="w-full bg-green-500 hover:bg-green-800 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200">
                  Importar Turmas
                </Button>
                <Button onClick={() => setUploadType('alunos')} className="w-full bg-green-500 hover:bg-green-800 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200">
                  Importar Alunos
                </Button>
              </div>
          ) : (
              <div className="grid gap-4 py-4">
                <p>Selecione o ficheiro .json para fazer o upload.</p>
                <Button variant="outline" onClick={() => fileInputRef.current?.click()} className="w-full bg-green-500 hover:bg-green-800 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200">
                  Escolher Ficheiro
                </Button>
                {selectedFile && <p className="text-sm text-gray-500">Ficheiro: {selectedFile.name}</p>}
                <input type="file" ref={fileInputRef} onChange={(e) => setSelectedFile(e.target.files?.[0] || null)} className="hidden" accept=".json" />
              </div>
          )}
          <DialogFooter>
            {selectedFile && (
                <Button onClick={handleFileUpload} className="bg-green-500 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200">
                  Enviar
                </Button>
            )}
            <Button variant="outline" onClick={() => setImportDataModalOpen(false)}>
              Cancelar
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
"use client"

import { useAuth } from "@/contexts/AuthContext";
import { Search, Menu, X, LogOut, Loader2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { useState, useRef } from "react"
import { useRouter } from "next/navigation";
import { api } from '@/lib/api'; // Este é o seu axios instance
import { toast } from 'sonner';

export default function GerenciamentoPage() {
  const { logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [activeSection, setActiveSection] = useState("gerenciamento")
  const [importDataModalOpen, setImportDataModalOpen] = useState(false)
  const [uploadType, setUploadType] = useState<"turmas" | "alunos" | null>(null); 
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const router = useRouter();

  const handleLogout = () => {
    logout();
  }

  const handleManagementAction = (action: string) => {
    if (action === "importar-dados") {
      setImportDataModalOpen(true)
    }
  }

  const handleFileUpload = async () => {
    if (!selectedFile || !uploadType) {
      toast.error("Por favor, selecione um ficheiro e um tipo de importação.");
      return;
    }

    setIsUploading(true);
    const formData = new FormData();
    formData.append('file', selectedFile);

    // ===============================================================
    // ▼▼▼ CORREÇÃO AQUI: ROTAS DISTINTAS PARA CADA TIPO DE UPLOAD ▼▼▼
    // ===============================================================
    let uploadPath = '';
    if (uploadType === 'turmas') {
      uploadPath = '/importacoes/importar_turmas'; // Rota específica para turmas
    } else if (uploadType === 'alunos') {
      uploadPath = '/importacoes/importar_alunos'; // Rota específica para alunos
    } else {
      toast.error("Tipo de importação inválido.");
      setIsUploading(false);
      return;
    }
    // ===============================================================

    try {
      const response = await api.post(uploadPath, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      toast.success(response.data.message || "Ficheiro enviado com sucesso!");

    } catch (error: any) {
      console.error("Erro na importação:", error);
      const errorMessage = error.response?.data?.error || "Ocorreu um erro desconhecido durante a importação.";
      toast.error(errorMessage);
    } finally {
      setIsUploading(false);
      setImportDataModalOpen(false);
      setUploadType(null); // Reseta o tipo de upload
      setSelectedFile(null);
    }
  };

  return (
    <div className="min-h-screen bg-gray-200">
      {/* ... (Header e Sidebar - sem alterações) ... */}

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

      {/* Modal - Revertido para ter botões separados e títulos claros */}
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
              {/* Títulos claros baseados no tipo de upload */}
              {uploadType === 'turmas' && 'Importar Ficheiro de Turmas'}
              {uploadType === 'alunos' && 'Importar Ficheiro de Alunos'}
              {!uploadType && 'Selecionar Tipo de Importação'} {/* Título inicial */}
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
                <Button onClick={handleFileUpload} disabled={isUploading} className="bg-green-500 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200">
                  {isUploading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                  {isUploading ? 'A enviar...' : 'Enviar'}
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
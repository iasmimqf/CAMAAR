// Caminho: src/app/admin/layout.tsx
'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation'; // Mantenha o useRouter se for redirecionar para /acesso-negado

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading, user } = useAuth();
  const router = useRouter(); // Necessário para redirecionar para /acesso-negado

  // O redirecionamento para /login é feito no AuthContext.
  // Este useEffect só precisa garantir que admins acessem áreas de admin, e não outras áreas.
  // if (!isLoading && !isAuthenticated) { // Essa lógica foi movida para AuthContext
  //   router.push('/login');
  // }
  if (!isLoading && isAuthenticated && !user?.admin) {
    console.log('>>> AdminLayout: Autenticado, mas não é admin. Redirecionando para /acesso-negado');
    router.push('/acesso-negado'); // Redireciona para uma página de acesso negado
  }

  // Enquanto verifica a autorização, mostra uma mensagem de carregamento.
  if (isLoading || !isAuthenticated || !user?.admin) {
    console.log('>>> AdminLayout: Mostrando tela de carregamento/não autorizado. isAuthenticated:', isAuthenticated, 'isLoading:', isLoading, 'user:', user);
    return (
        <div className="flex h-screen items-center justify-center bg-gray-200">
            <div className="text-center">
                <p className="text-lg font-semibold text-gray-700">A verificar autorização...</p>
                <p className="text-sm text-gray-500">Por favor, aguarde.</p>
            </div>
        </div>
    );
  }

  console.log('>>> AdminLayout: Usuário ADMIN autorizado. Renderizando children.');
  return <>{children}</>;
}
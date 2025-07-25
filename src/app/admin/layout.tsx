// Caminho: src/app/admin/layout.tsx
'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

// Um componente simples para a tela de carregamento, para manter o código principal limpo.
const FullScreenLoader = ({ message }: { message: string }) => (
  <div className="flex h-screen items-center justify-center bg-gray-200">
    <div className="text-center">
      <p className="text-lg font-semibold text-gray-700">{message}</p>
      <p className="mt-1 text-sm text-gray-500">Por favor, aguarde.</p>
    </div>
  </div>
);

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading, user } = useAuth();
  const router = useRouter();

  useEffect(() => {
    // Não fazemos nada enquanto o estado de autenticação ainda está sendo carregado.
    if (isLoading) {
      return;
    }

    // Assim que o carregamento termina, verificamos as permissões.
    // Se o usuário está logado, mas NÃO é um admin, o redirecionamos para a página do aluno.
    if (isAuthenticated && !user?.admin) {
      console.log(">>> AdminLayout: Acesso negado para não-admin. Redirecionando para /aluno...");
      router.replace('/aluno');
    }

    // Se o usuário não está logado, o redirecionamos para a página de login.
    // (Isso funciona como uma segurança extra, pois o AuthProvider já deve fazer isso).
    if (!isAuthenticated) {
        console.log(">>> AdminLayout: Usuário não autenticado. Redirecionando para /login...");
        router.replace('/login');
    }
  }, [isLoading, isAuthenticated, user, router]); // O efeito depende destes valores

  // --- Lógica de Renderização ---

  // 1. Se a verificação de autenticação ainda está em andamento, sempre mostre o loader.
  if (isLoading) {
    return <FullScreenLoader message="Carregando..." />;
  }

  // 2. Se a verificação terminou E o usuário é um admin autenticado (o "caminho feliz").
  if (isAuthenticated && user?.admin) {
    // Somente neste caso o conteúdo da página de admin é renderizado.
    return <>{children}</>;
  }

  // 3. Em todos os outros casos (não é admin, não está logado), o useEffect acima
  //    já foi acionado para fazer o redirecionamento. Mostramos um loader aqui
  //    para evitar que a tela pisque ou mostre conteúdo indevido antes que o
  //    redirecionamento seja concluído.
  return <FullScreenLoader message="Verificando autorização..." />;
}

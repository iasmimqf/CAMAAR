// Caminho: src/app/layout.tsx

import { AuthProvider } from '@/contexts/AuthContext';
import { Toaster } from '@/components/ui/sonner'; // <<< 1. Importe o Toaster
import './globals.css';

export const metadata = {
  title: 'CAMAAR',
  description: 'Sistema de Avaliação',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="pt-br">
      <body>
        <AuthProvider>
          {children}
          <Toaster richColors position="top-right" /> 
          {/* ^^^ 2. Adicione o componente aqui ^^^ */}
        </AuthProvider>
      </body>
    </html>
  );
}
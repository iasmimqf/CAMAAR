// Caminho: src/app/layout.tsx

import { AuthProvider } from '@/contexts/AuthContext';
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
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  );
}
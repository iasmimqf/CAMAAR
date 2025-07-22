# language: pt

Funcionalidade: Criação de Usuário e Solicitação de Senha Durante a Importação
  Como um administrador,
  ao importar dados de alunos,
  quero que novos usuários sejam criados e notificados para definirem sua senha,
  a fim de que possam acessar o sistema.

  @importacao_novo_usuario
  Cenário: Um novo aluno é importado com sucesso
    Dado que a turma "Cálculo 1" com código "MAT0030" já existe
    E o usuário "novo.aluno@email.com" NÃO existe no sistema
    Quando o administrador importa um arquivo de alunos para a turma "Cálculo 1" contendo os dados de "novo.aluno@email.com"
    Então o usuário "novo.aluno@email.com" deve ser criado no sistema
    And um e-mail de definição de senha deve ser enviado para "novo.aluno@email.com"

  @importacao_usuario_existente
  Cenário: Um aluno já existente é importado
    Dado que a turma "Cálculo 1" com código "MAT0030" já existe
    And o usuário "aluno.antigo@email.com" JÁ existe no sistema
    Quando o administrador importa um arquivo de alunos para a turma "Cálculo 1" contendo os dados de "aluno.antigo@email.com"
    Então um e-mail de definição de senha NÃO deve ser enviado para "aluno.antigo@email.com"

  @importacao_dados_invalidos
  Cenário: Um aluno com dados inválidos é importado
    Dado que a turma "Cálculo 1" com código "MAT0030" já existe
    Quando o administrador importa um arquivo de alunos com um e-mail inválido
    Então nenhum usuário novo deve ser criado
    And nenhum e-mail de definição de senha deve ser enviado

  @importacao_turma_invalida
  Cenário: Tentativa de importar um aluno para uma turma inexistente
    Dado que a turma com código "XYZ-001" NÃO existe no sistema
    Quando o administrador importa um arquivo de alunos para a turma "XYZ-001"
    Então nenhum usuário novo deve ser criado
    And nenhum e-mail de definição de senha deve ser enviado
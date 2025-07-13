# language: pt

Funcionalidade: Definição de Senha para Novo Usuário

  Como um Usuário,
  Quero definir uma senha para o meu usuário a partir de um link seguro,
  A fim de ativar minha conta e acessar o sistema.

  # --- Cenário de Sucesso ---
  Cenário: Definição de senha bem-sucedida
    Dado que sou um usuário recém-criado sem senha definida
    E que recebi um link válido para definir minha senha
    Quando eu clico no link e sou direcionado para a página "Defina sua Senha"
    E eu preencho o campo "Nova Senha" com "SenhaForte123!"
    E eu preencho o campo "Confirmar Senha" com "SenhaForte123!"
    E clico no botão "Salvar Senha"
    Então eu devo ver uma mensagem de sucesso como "Senha definida com sucesso! Você já pode acessar o sistema."
    E devo ser redirecionado para a página de login.

    # --- Cenário de Erro: Senhas Não Conferem ---
  Cenário: Tentativa de definir senhas que não conferem
    Dado que estou na página "Defina sua Senha" a partir de um link válido
    Quando eu preencho o campo "Nova Senha" com "senha123"
    E eu preencho o campo "Confirmar Senha" com "senha124"
    E clico no botão "Salvar Senha"
    Então eu devo ver uma mensagem de erro na tela, como "As senhas não conferem. Por favor, tente novamente."

    # --- Cenário de Erro: Link Inválido/Expirado ---
  Cenário: Acesso à página com um link inválido ou expirado
    Dado que eu possuo um link para definição de senha que já foi utilizado ou expirou
    Quando eu tento abrir este link no meu navegador
    Então devo ser direcionado para uma página de erro informando: "Este link é inválido ou já expirou."
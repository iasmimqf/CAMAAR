# language: pt
Funcionalidade: Redefinição de Senha de Usuário

  Como um Usuário cadastrado,
  eu quero poder definir uma nova senha a partir de um link seguro enviado por e-mail,
  a fim de acessar o sistema novamente.

  Contexto: Um usuário solicitou a redefinição de senha
    Dado que o usuário "ana@email.com" solicitou uma redefinição de senha


  Esquema do Cenário: Tentativa de redefinir a senha
    Quando eu visito a página de redefinição de senha com o token do usuário "ana@email.com"
    E preencho o campo "Nova Senha" com <Senha>
    E preencho o campo "Confirmação de Senha" com <Confirmacao>
    E clico no botão "Alterar minha senha"
    Então eu devo ver a mensagem <Mensagem>

    Exemplos:
        | Senha          | Confirmacao    | Mensagem                                       |
        | "Password@123" | "Password@123" | "Sua senha foi alterada com sucesso."          |
        | "Password@123" | "senha-errada" | "Confirmação de Senha não corresponde à Senha" |
        | "fraca"        | "fraca"        | "Senha é muito curta (mínimo de 8 caracteres)" |


  Cenário: Tentativa de usar um link inválido ou expirado
    Quando eu visito a página de redefinição de senha com o token "TOKEN_INVALIDO"
    Então eu devo ver a mensagem de erro "Token de redefinição de senha é inválido"
    E eu não devo ver o campo "Nova Senha"
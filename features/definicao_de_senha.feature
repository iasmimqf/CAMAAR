História de Usuário:

Como um Usuário
Quero definir uma senha para o meu usuário a partir do e-mail do sistema de solicitação de cadastro
A fim de acessar o sistema

Cenário: Definição de senha bem-sucedida
    Contexto:
        Dado que meu cadastro foi aprovado e eu recebi um e-mail com o link para definir minha senha
        E o link é válido e não expirou
    
    Quando eu clico no link e sou direcionado para a página "Defina sua Senha"
    E eu preencho o campo "Nova Senha" com uma senha que atende aos critérios de segurança (ex: "senha123")
    E eu preencho o campo "Confirmar Senha" com a mesma senha "senha123"
    E clico no botão "Salvar Senha"
    Então eu devo ver uma mensagem de sucesso como "Senha definida com sucesso! Você já pode acessar o sistema."
    E devo ser redirecionado para a página de login.

Cenário: Tentativa de definir senhas que não conferem
    Contexto:
        Dado que meu cadastro foi aprovado e eu recebi um e-mail com o link para definir minha senha
        E o link é válido e não expirou
    
    Quando eu preencho o campo "Nova Senha" com "senha123"
    E eu preencho o campo "Confirmar Senha" com "senha124"
    E clico no botão "Salvar Senha"
    Então eu devo ver uma mensagem de erro na tela, como "As senhas não conferem. Por favor, tente novamente."
    E devo permanecer na página "Defina sua Senha" para corrigir a informação.

Cenário: Tentativa de definir uma senha que não atende aos critérios de segurança
    Contexto:
        Dado que estou na página "Defina sua Senha" a partir de um link válido
        E o sistema exige que a senha tenha no mínimo 8 caracteres, uma letra maiúscula, uma letra maiúscula, um número e um caractere especial

    Quando eu preencho o campo "Nova Senha" com "fraca"
    E eu preencho o campo "Confirmar Senha" com "fraca"
    E clico no botão "Salvar Senha"
    Então eu devo ver uma mensagem de erro detalhando os requisitos não atendidos (ex: "A senha deve conter no mínimo 8 caracteres, uma letra maiúscula e um número.")
    E os campos de senha devem ser limpos.

Cenário: Acesso à página com um link inválido ou expirado
    Contexto:
        Dado que eu possuo um link para definição de senha que já foi utilizado ou expirou
        Quando eu tento abrir este link no meu navegador

    Então não devo ver os campos para definir a senha
    E devo ser direcionado para uma página de erro informando: "Este link é inválido ou já expirou. Por favor, solicite um novo link de redefinição de senha."
# language: pt
Funcionalidade: Visualização de Formulários Criados

História de Usuário:

Como Admin do sistema
Quero visualizar os formulários criados
A fim de poder gerar um relatório a partir das respostas

Cenário: Listagem de formulários
    Dado que eu sou um administrador autenticado
    E que eu esteja na página de formulários "Gerenciamento"
    E existem formulários criados a partir de templates existentes      
    Quando eu acesso a página de resultados "Resultados"
    Então devo ver uma tabela com os formulários criados
    E para cada formulário devo ver o nome, a data de criação e o status (ativo/inativo)
    E deve haver um botão "Gerar Relatório" disponível para cada formulário

Cenário: Nenhum formulário criado no sistema
    Dado que eu sou um administrador autenticado
    E que eu esteja na página de formulários "Gerenciamento"
    E que ainda não existam formulários criados no sistema
    Quando eu acesso a página de resultados "Resultados"
    Então devo ver uma mensagem de formulários como "Nenhum formulário foi encontrado."
    E não deve haver nenhuma tabela ou botão "Gerar Relatório" exibido

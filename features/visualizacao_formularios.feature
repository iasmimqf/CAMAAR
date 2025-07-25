# language: pt
Funcionalidade: Visualização de Formulários Criados

Como Admin do sistema
Quero visualizar os formulários criados
A fim de poder gerar um relatório a partir das respostas

Contexto:
    Dado que eu sou um administrador autenticado
    E que eu esteja na página de "Gerenciamento"
    E existem formulários criados a partir de templates existentes      

Cenário: Listagem de formulários
    Quando eu acesso a página de "Resultados"
    Então devo ver uma tabela com os formulários criados
    E para cada formulário devo ver o nome, a data de criação e o status (ativo/inativo)
    E deve haver um botão "Gerar Relatório" disponível para cada formulário

Cenário: Nenhum formulário criado no sistema
    Dado que ainda não existam formulários criados no sistema
    Quando eu acesso a página de "Resultados"
    Então devo ver uma mensagem como "Nenhum formulário foi encontrado."
    E não deve haver nenhuma tabela ou botão "Gerar Relatório" exibido
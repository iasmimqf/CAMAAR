# language: pt
Funcionalidade: Visualização de Formulários Criados
    Como administrador do sistema
    Quero visualizar os formulários criados
    Para poder gerenciar e gerar relatórios

    Contexto:
        Dado que estou autenticado como administrador

    @javascript
    Cenário: Listagem de formulários existentes
        Dado existem formulários criados no sistema
        E os formulários possuem diferentes status
        Quando eu acesso a página de "Resultados"
        Então devo ver uma tabela com os formulários criados
        E para cada formulário devo ver o template, criador, data de criação e turmas
        E deve haver um botão "Ver Detalhes" disponível para cada formulário

    @javascript
    Cenário: Nenhum formulário criado no sistema
        Dado que não existem formulários criados no sistema
        Quando eu acesso a página de "Resultados"
        Então devo ver uma mensagem "Nenhum formulário foi encontrado."
        E não deve haver nenhuma tabela de formulários exibida

    @javascript
    Cenário: Visualizar detalhes de um formulário específico
        Dado existem formulários criados no sistema
        E um formulário possui respostas dos alunos
        Quando eu acesso a página de "Resultados"
        Então devo ver os detalhes do formulário selecionado
        E devo ver as turmas associadas ao formulário
        E deve haver um botão "Gerar Relatório" disponível para cada formulário
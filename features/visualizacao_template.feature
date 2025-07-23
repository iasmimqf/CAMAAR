# language: pt
Funcionalidade: Visualização de Templates Criados

História de Usuário:

Eu como Admin do sistema
Quero visualizar os templates criados
A fim de poder editar e/ou deletar um template que eu criei

Contexto:
    Dado que eu sou um administrador autenticado

Cenário: Listagem de templates
    Dado existem os seguintes templates: "Avaliação exemplo, Avaliação exemplo2, Avaliação exemplo3"
    Quando eu acesso a página de "Gerenciamento - Templates"
    Então devo ver uma lista contendo "Avaliação exemplo, Avaliação exemplo2, Avaliação exemplo3"
    E cada template da lista deve conter os botões "Editar" e "Excluir"

Cenário: Nenhum template cadastrado no sistema
    Dado que ainda não existam templates cadastrados no sistema
    Quando eu acesso a página de "Gerenciamento - Templates"
    Então devo ver uma mensagem como "Nenhum template foi encontrado."
    E não deve haver botões "Editar" ou "Excluir" exibidos

@javascript
Cenário: Visualizar detalhes de um template específico
    Dado existem os seguintes templates: "Template de Teste"
    Quando eu acesso a página de "Gerenciamento - Templates"
    E clico em Visualizar do template "Template de Teste"
    Então devo ver os detalhes do template "Template de Teste"
    E devo ver as questões do template
    E devo ver botões de ação "Editar" e "Voltar"

Cenário: Verificar informações na listagem de templates
    Dado existem os seguintes templates: "Avaliação Docente"
    Quando eu acesso a página de "Gerenciamento - Templates"
    Então devo ver o nome do template "Avaliação Docente"
    E devo ver informações sobre questões
    E devo ver as ações disponíveis para o template

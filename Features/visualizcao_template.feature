Funcionalidade: Visualização de Templates Criados

História de Usuário:

Eu como Admin do sistema
Quero visualizar os templates criados
A fim de poder editar e/ou deletar um template que eu criei

Cenário: Listagem de templates
    Contexto: 
        Dado que eu sou um administrador autenticado
        E que estou na página de gerenciamento - templates
        E existem os seguintes templates: "Avaliação exemplo, Avaliação exemplo2, Avaliação exemplo3"
    
    Quando eu acesso a página de "Templates"
    Então devo ver uma lista contendo "Avaliação exemplo, Avaliação exemplo2, Avaliação exemplo3"
    E cada template da lista deve conter os botões "Editar" e "Excluir"

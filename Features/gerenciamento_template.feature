Funcionalidade: Edição e Exclusão de Templates sem afetar formulários já existentes

História de Usuário:

Eu como Admin do sistema
Quero editar e/ou deletar um template que eu criei sem afetar os formulários já criados
A fim de organizar os templates existentes

Cenário: Edição bem-sucedida de template
    Contexto:
    	Dado que eu sou um administrador autenticado
	E que eu esteja na página de gerenciamento - templates
    	E que existe um template chamado "Avaliação exemplo" criado por mim

    Quando eu acesso a lista de templates
    E clico em "Editar" no template "Avaliação exemplo"
    E altero o título para "Avaliação Atualizada"
    E clico em "Salvar"
    Então eu devo receber uma mensagem de sucesso como "O template foi atualizado com sucesso."
    E os formulários já criados com base nesse template não devem ser modificados

Cenário: Exclusão de template sem afetar formulários existentes
    Contexto:    
	Dado que eu sou um administrador autenticado
	E que eu esteja na página de gerenciamento - templates
        E que existe um template chamado "Template exemplo" criado por mim
	E que já existem formulários criados a partir desse template
    
    Quando eu acesso a lista de templates
    E clico em "Excluir" no template "Template exemplo"
    E confirmo a exclusão
    Então devo receber uma mensagem de sucesso como "O template foi excluído com sucesso."
    E os formulários criados a partir deste devem continuar acessíveis

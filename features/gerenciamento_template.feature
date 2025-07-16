# language: pt
Funcionalidade: Edição e Exclusão de Templates sem afetar formulários já existentes

  Como Admin do sistema
  Quero editar e/ou deletar um template que eu criei sem afetar os formulários já criados
  A fim de organizar os templates existentes

  Contexto:
    Dado que eu sou um administrador autenticado
    E que eu esteja na página de "Gerenciamento - Templates"

  Cenário: Edição bem-sucedida de template
    Dado que existe um template chamado "Avaliação exemplo"
    Quando eu acesso a lista de templates
    E clico em "Editar" no template "Avaliação exemplo"
    E altero o título para "Avaliação Atualizada"
    E clico em "Salvar"
    Então eu devo receber uma mensagem de sucesso como "O template foi atualizado com sucesso."
    E os formulários já criados com base nesse template não devem ser modificados

  Cenário: Tentativa de exclusão de template com formulários existentes
    Dado que existe um template chamado "Template exemplo"
    E que já existem formulários criados a partir desse template
    Quando eu acesso a lista de templates
    E clico em "Excluir" no template "Template exemplo"
    E confirmo a exclusão
    Então eu devo receber uma mensagem de erro como "Não é possível excluir o template pois existem formulários associados a ele."
    E os formulários criados a partir deste devem continuar acessíveis

  Cenário: Exclusão bem-sucedida de template sem formulários
    Dado que existe um template chamado "Template para excluir"
    Quando eu acesso a lista de templates
    E clico em "Excluir" no template "Template para excluir"
    E confirmo a exclusão
    Então eu devo receber uma mensagem de sucesso como "O template foi excluído com sucesso."

  Cenário: Falha ao editar template por erro de título
    Dado que existe um template chamado "Avaliação exemplo"
    Quando eu acesso a lista de templates
    E clico em "Editar" no template "Avaliação exemplo"
    E apago o conteúdo do campo "Título"
    E clico em "Salvar"
    Então eu devo receber uma mensagem de erro como "O título do template é obrigatório"
    E o template não deve ser atualizado
    E os formulários já criados não devem ser afetados
    

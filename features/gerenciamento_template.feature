# language: pt
Funcionalidade: Gerenciamento completo de Templates

  Como Administrador do sistema
  Quero gerenciar meus templates (editar, visualizar, excluir)
  Para manter organizados os templates do sistema

  Contexto:
    Dado que eu sou um administrador autenticado no sistema
    E estou na página de "Gerenciamento de Templates"

  @editar_template
  Cenário: Editar template existente com sucesso
    Dado que existe um template chamado "Avaliação de Desempenho"
    E o template possui 3 questões cadastradas
    Quando eu clico no botão "Editar" do template "Avaliação de Desempenho"
    Então eu devo ser redirecionado para a página de edição do template
    E devo ver o formulário preenchido com os dados atuais
    Quando eu altero o título para "Avaliação de Performance 2025"
    E adiciono uma nova questão "Qual sua satisfação geral?"
    E clico no botão "Atualizar Template"
    Então eu devo ver a mensagem "Template atualizado com sucesso"
    E devo ser redirecionado para a lista de templates
    E devo ver o template com o novo título "Avaliação de Performance 2025"

  @visualizar_template
  Cenário: Visualizar detalhes de um template
    Dado que existe um template chamado "Pesquisa de Satisfação"
    E o template possui as seguintes questões:
      | pergunta                          | tipo     |
      | Como você avalia nosso atendimento?| multiple |
      | Deixe seus comentários            | text     |
    Quando eu clico no botão "Visualizar" do template "Pesquisa de Satisfação"
    Então eu devo ser redirecionado para a página de detalhes do template
    E devo ver o título "Pesquisa de Satisfação"
    E devo ver as 2 questões listadas
    E devo ver botões "Editar Template" e "Voltar"

  @excluir_template_com_formularios
  Cenário: Tentar excluir template que possui formulários associados
    Dado que existe um template chamado "Template com Formulários"
    E existem 2 formulários criados baseados neste template
    Quando eu clico no botão "Excluir" do template "Template com Formulários"
    E confirmo a exclusão no modal de confirmação
    Então eu devo ver a mensagem de erro "Não é possível excluir este template pois existem formulários associados"
    E o template deve continuar na lista
    E os formulários associados devem permanecer intactos

  @excluir_template_sem_formularios
  Cenário: Excluir template sem formulários associados
    Dado que existe um template chamado "Template Não Utilizado"
    E não existem formulários criados baseados neste template
    Quando eu clico no botão "Excluir" do template "Template Não Utilizado"
    E confirmo a exclusão no modal de confirmação
    Então eu devo ver a mensagem "Template excluído com sucesso"
    E o template "Template Não Utilizado" não deve mais aparecer na lista

  @listar_templates
  Cenário: Visualizar lista de templates com diferentes estados
    Dado que existem os seguintes templates no sistema:
      | titulo                    | questoes | formularios |
      | Avaliação Docente        | 5        | 10          |
      | Pesquisa de Clima        | 3        | 0           |
      | Feedback de Evento       | 8        | 2           |
    Quando eu acesso a página de gerenciamento de templates
    Então eu devo ver uma tabela com todos os templates
    E cada template deve mostrar:
      | titulo | numero_questoes | numero_formularios | acoes |
    E para templates com formulários associados, o botão "Excluir" deve estar desabilitado
    E para templates sem formulários, o botão "Excluir" deve estar habilitado

  @template_vazio
  Cenário: Tentar visualizar template sem questões
    Dado que existe um template chamado "Template Vazio"
    E o template não possui questões cadastradas
    Quando eu clico no botão "Visualizar" do template "Template Vazio"
    Então eu devo ser redirecionado para a página de detalhes do template
    E devo ver a mensagem "Este template ainda não possui questões"
    E devo ver um botão "Adicionar Questões"
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
    

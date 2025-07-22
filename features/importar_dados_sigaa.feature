# language: pt
Funcionalidade: Importação de Dados de Turmas e Alunos
  Como um administrador,
  eu quero poder importar arquivos JSON para cadastrar turmas e alunos em lote,
  lidando com sucessos e falhas de forma clara.

Contexto:
  Dado que eu estou logado como um "administrador"
  E estou na página de Gerenciamento

# --- Cenários de Importação de TURMAS ---

@import_turma_sucesso
Cenário: Importar um arquivo de Turmas com sucesso
  Quando eu clico no link "Importar Dados"
  E clico no link "Importar Turmas"
  E anexo o arquivo "turmas_validas.json" ao campo "Arquivo de Turmas"
  E clico no botão "Enviar Arquivo"
  Então eu devo ver a mensagem "Arquivo de turmas processado com sucesso!"
  E a turma "BANCOS DE DADOS" deve ser criada no sistema.

@import_turma_formato_invalido
Cenário: Tentar importar Turmas com um arquivo de formato incorreto
  Quando eu clico no link "Importar Dados"
  E clico no link "Importar Turmas"
  E anexo o arquivo "arquivo_invalido.txt" ao campo "Arquivo de Turmas"
  E clico no botão "Enviar Arquivo"
  Então eu devo ver a mensagem de erro "Formato de arquivo inválido. Por favor, envie um arquivo .json."

@import_turma_json_malformado
Cenário: Tentar importar Turmas com um JSON malformado
  Quando eu clico no link "Importar Dados"
  E clico no link "Importar Turmas"
  E anexo o arquivo "turmas_malformado.json" ao campo "Arquivo de Turmas"
  E clico no botão "Enviar Arquivo"
  Então eu devo ver a mensagem de erro "Erro de sintaxe no arquivo JSON."
  
@import_turma_dados_invalidos
Cenário: Tentar importar Turmas com dados obrigatórios faltando
  Quando eu clico no link "Importar Dados"
  E clico no link "Importar Turmas"
  E anexo o arquivo "turmas_sem_codigo.json" ao campo "Arquivo de Turmas"
  E clico no botão "Enviar Arquivo"
  Então eu devo ver a mensagem de erro "Erro na estrutura do arquivo: 'code' e 'name' são obrigatórios para a disciplina."

# --- Cenários de Importação de ALUNOS ---

@import_alunos_sucesso
Cenário: Importar um arquivo de Alunos com sucesso
  Dado que a disciplina "BANCOS DE DADOS" com código "CIC0097" já existe
  Quando eu clico no link "Importar Dados"
  E clico no link "Importar Alunos"
  E anexo o arquivo "alunos_validos.json" ao campo "Arquivo de Alunos"
  E clico no botão "Enviar Arquivo"
  Então eu devo ver a mensagem "Importação concluída! 1 novos alunos e 1 novos professores foram cadastrados."
  E o usuário "Ana Clara Jordao Perna" deve ser criado e associado à turma "BANCOS DE DADOS".

@import_alunos_turma_inexistente
Cenário: Tentar importar Alunos para uma turma que não existe
  Quando eu clico no link "Importar Dados"
  E clico no link "Importar Alunos"
  E anexo o arquivo "alunos_turma_inexistente.json" ao campo "Arquivo de Alunos"
  E clico no botão "Enviar Arquivo"
  Então eu devo ver a mensagem de erro "Erro: A turma com código XYZ não foi encontrada."

@import_alunos_parcial
Cenário: Importar um arquivo de Alunos com sucesso parcial
  Dado que a disciplina "BANCOS DE DADOS" com código "CIC0097" já existe
  Quando eu clico no link "Importar Dados"
  E clico no link "Importar Alunos"
  E anexo o arquivo "alunos_com_erro.json" ao campo "Arquivo de Alunos"
  E clico no botão "Enviar Arquivo"
  Então eu devo ver a mensagem "Importação concluída com erros."
  E eu devo ver os detalhes do erro "Email não pode ficar em branco"
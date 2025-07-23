# language: pt
Funcionalidade: API de Importação de Dados de Turmas e Alunos

  Como um administrador,
  eu quero poder importar arquivos JSON para a API para cadastrar turmas e alunos,
  recebendo respostas claras sobre o sucesso ou a falha da operação.

  Contexto:
    Dado que eu estou autenticado como um "administrador"

  @import_turma
  Cenário: Importar um arquivo de Turmas com sucesso
    Quando eu envio o arquivo "classes.json" para o endpoint de importação de turmas
    Então a resposta da API deve ser de sucesso
    E a turma "BANCOS DE DADOS" deve ser criada no sistema.

  @import_turma_sad_paths
  Esquema do Cenário: Tentar importar Turmas com arquivos inválidos
    Quando eu envio o arquivo <Arquivo> para o endpoint de importação de turmas
    Então a resposta da API deve ser um erro com a mensagem <Mensagem>

    Exemplos:
      | Arquivo                  | Mensagem                                                                            |
      | "arquivo_invalido.txt"   | "Formato de arquivo inválido. Por favor, envie um arquivo .json."                   |
      | "turmas_malformado.json" | "Erro de sintaxe no arquivo JSON."                                                  |
      | "turmas_sem_codigo.json" | "Erro na estrutura do arquivo: 'code' e 'name' são obrigatórios para a disciplina." |

  @import_alunos
  Cenário: Importar um arquivo de Alunos com sucesso
    Dado que a disciplina "BANCOS DE DADOS" com código "CIC0097" já existe
    Quando eu envio o arquivo "class_members.json" para o endpoint de importação de alunos
    Então a resposta da API deve ser de sucesso
    E o usuário "Ana Clara Jordao Perna" deve ser criado e associado à turma "BANCOS DE DADOS".

  @import_alunos_sad_paths
  Esquema do Cenário: Tentar importar Alunos com dados inconsistentes
    Dado que a disciplina "BANCOS DE DADOS" com código "CIC0097" já existe
    Quando eu envio o arquivo <Arquivo> para o endpoint de importação de alunos
    Então a resposta da API deve ser um erro com a mensagem <Mensagem>

    Exemplos:
      | Arquivo                         | Mensagem                                           |
      | "alunos_turma_inexistente.json" | "Erro: A turma com código XYZ não foi encontrada." |
      | "alunos_com_erro.json"          | "Importação concluída com erros."                  |
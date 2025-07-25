# Wiki - Projeto CAMAAR  
*(Sprint 3: Refatoração e Documentação do código)*  

## Equipe  

| Nome                              | Matrícula  | Papel             |  
|-----------------------------------|------------|-------------------|  
| Iasmim de Queiroz Freitas         | 190108665  | **Product Owner** |  
| Hudson Cauã Costa Lima            | 211055512  | **Scrum Master**  |  
| Luis Gustavo de Sousa Silva       | 200046527  |  Desenvolvedor    |  
| Marcus Emanuel Carvalho T. Freitas| 222025960  |  Desenvolvedor    |  

## Resumo da Sprint

O foco principal desta sprint foi a **finalização, teste e refatoração** das funcionalidades desenvolvidas, além da documentação do código, seguindo os critérios de qualidade estabelecidos.

Como a implementação dos testes da Sprint 2 não foi concluída, o início desta sprint foi dedicado a estabilizar a base de código, garantir que as features existentes estivessem 100% funcionais e com testes robustos, para só então aplicar as análises de qualidade e documentação.

---
## Atividades Realizadas por Feature

### Feature 1: Autenticação de Usuários

**Responsáveis:** `[Iasmim e Hudson]`

Esta feature já tinha sua lógica de API funcional, mas os testes automatizados não estavam integrados ou passando. O trabalho realizado foi:

* **Testes de Aceitação (Cucumber):** O arquivo `autenticacao.feature` foi mantido como a especificação de comportamento. O arquivo de steps (`autenticacao_steps.rb`) foi completamente refatorado. Os passos que antes tentavam simular um navegador (com Capybara) foram ajustados para fazer **requisições diretas à API**, verificando as respostas JSON e os códigos de status HTTP. Com isso, todos os cenários de Happy e Sad Path foram validados e agora passam com sucesso.

* **Testes de Integração (RSpec):** Foi criado o arquivo `autenticacao_spec.rb` para realizar testes de baixo nível na API. Este arquivo testa de forma isolada e rápida o endpoint de login, verificando detalhadamente a estrutura do JSON de resposta, os cabeçalhos (como o `Authorization` com o token) e os códigos de status (`200 OK` para sucesso, `401 Unauthorized` para falha).

* **Conclusão da Feature:** Com todos os testes passando (Cucumber e RSpec), a branch da feature (`feature/F1-autenticacao`) foi considerada completa, integrada à branch `develop` através de um Pull Request e, em seguida, removida para manter o repositório organizado.

### Feature 2: Redefinição de Senha

**Responsáveis:** `[Iasmim e Hudson]`

O trabalho nesta feature focou na implementação da API de redefinição de senha e na criação de testes para validar seu comportamento.

* **Estratégia de Teste:** Para esta feature, que é **puramente uma funcionalidade de API** (o frontend envia dados, o backend responde com JSON), foi adotada uma estratégia de teste focada em **RSpec Request Specs** como principal ferramenta de validação. O arquivo `.feature` (`definicao_de_senha.feature`) foi mantido como uma especificação de alto nível do comportamento esperado.

* **Testes de Integração (RSpec):** O arquivo `passwords_api_spec.rb` foi criado para servir como o **teste de aceitação principal** da API. Ele cobre exaustivamente todos os cenários de **Happy Path e Sad Path**, incluindo:
    * Solicitação de redefinição para um usuário existente e o envio do e-mail (Happy Path).
    * Redefinição de senha bem-sucedida com um token válido (Happy Path).
    * Tentativa de redefinição com senhas que não conferem (Sad Path).
    * Tentativa de redefinição com uma senha fraca que não passa nas validações do modelo (Sad Path).
    * Tentativa de redefinição com um token inválido (Sad Path).

* **Conclusão da Feature:** Com todos os testes RSpec para os cenários de sucesso e falha passando, a funcionalidade da API foi considerada completa e robusta. A branch da feature foi integrada à branch `develop` através de um Pull Request e, em seguida, removida para manter o repositório organizado (por um erro de logística, os testes de aceitação (cucumber) foram concluídos na branch da feature 3).

### Feature 3: Importação de Dados do SIGAA

**Responsáveis:** `[Iasmim e Hudson]`

O objetivo desta feature é permitir que um administrador importe dados de Turmas e Alunos/Professores a partir de arquivos JSON, populando a base de dados do sistema.

* **Estratégia de Teste e Refatoração:** Seguindo os requisitos da Sprint 3, a implementação desta feature foi guiada por testes e refatoração. A lógica de negócio, que é complexa, foi extraída do `Admin::ImportacoesController` para **Service Objects** dedicados (`TurmaImporterService` e `AlunoImporterService`), resultando em um código mais limpo, com menor complexidade (ABC Score) e mais fácil de testar, mas o resto da refatoração vai ser feito depois.

* **Lógica de Negócio Implementada:**
    * O sistema utiliza uma lógica "encontre ou crie" para evitar a duplicação de `Disciplinas`, `Turmas` e `Usuarios`.
    * Ao criar um **novo usuário** (aluno ou professor) através da importação, o sistema automaticamente dispara um **e-mail para a definição de senha**, cumprindo um requisito chave da funcionalidade.
    * A importação lida com **sucessos parciais**, retornando um resumo dos sucessos e uma lista detalhada de erros caso o ficheiro contenha dados inválidos ou inconsistentes (ex: tentar importar alunos para uma turma que não existe).

* **Testes (RSpec):** Os testes de aceitação para esta feature foram implementados como **testes de serviço** em RSpec (`spec/services/`). Esta abordagem permite testar a lógica de negócio de forma independente e completa, verificando todos os **Happy Paths e Sad Paths**, como:
    * Criação correta de novos registros (turmas, alunos, professores).
    * Associação correta de alunos e professores às turmas.
    * Envio do e-mail de definição de senha apenas para novos usuários.
    * Tratamento de erros de ficheiro (JSON malformado, formato inválido).
    * Tratamento de erros de dados (turma inexistente, dados de usuário inválidos).

### Feature 4: CRUD de Templates

**Responsáveis:** `[Iasmim e Hudson]`

Implementamos testes RSpec para a API de templates, cobrindo:

- Validações de campos obrigatórios (título e questões)
- Fluxos principais de criação, edição e exclusão
- Sad Paths (títulos vazios, templates sem questões, erros de autorização)
- Códigos de status HTTP adequados (400, 422)

*Testes de aceitação via Cucumber foram postergados para focar nos testes de integração. A feature está funcional e integrada em `develop`.*


### Feature 5: [Nome da Feature]

**Responsável:** Marcus Emanuel

Os testes desta feature foram implementados por Marcus, mas não houve tempo hábil para revisão detalhada dos cenários e cobertura. Recomenda-se revisar os testes e documentar os principais casos validados na próxima sprint.

### Feature 6: Criação de Formulários

**Responsáveis:** `[Iasmim e Hudson]`

Foram implementados testes automatizados utilizando RSpec, cobrindo:

- Testes de model para validação dos atributos do formulário
- Testes de requests para os endpoints de criação, edição e envio de respostas de formulários
- Validação dos fluxos principais e dos Sad Paths (dados inválidos, erros de autorização, etc.)

### Status das demais features

As demais features não tiveram tempo hábil para revisão dos testes nesta sprint. A revisão e documentação detalhada dos testes será priorizada na próxima entrega.

---
## Análise de Qualidade e Refatoração (Sprint 3)

### Cobertura de Testes (SimpleCov)

* **Controllers:**
    * `app/controllers/home_controller.rb`: `[100%]`
    * `app/controllers/application_controller.rb`: `[100%]`
    * `app/controllers/api/v1/passwords_controller.rb`: `[100%]`
    * `app/controllers/admin/base_controller.rb`: `[100%]`
    * `app/controllers/usuarios/sessions_controller.rb`: `[88,89%]`
    * `app/controllers/api/v1/templates_controller.rb`: `[87,50%]`
    * `app/controllers/api/v1/base_controller.rb`: `[85,71%]`
    * `app/controllers/admin/formularios_controller.rb`: `[44,19%]`
* **Models:**
    * `app/models/template.rb`: `[100%]`
    * `app/models/formulario.rb`: `[100%]`
    * `app/models/disciplina.rb`: `[100%]`
    * `app/models/turma.rb`: `[88,89%]`
    * `app/models/questao.rb`: `[87,50%]`
    * `app/models/resposta_questao.rb`: `[30,30%]`
* **Services:**
    * `app/services/aluno_importer_service.rb`: `[92%]`
    * `app/services/aluno_importer_service.rb`: `[85,71%]`
* **Mailers:**
    * `app/mailers/custom_devise_mailer.rb`: `[100%]`
### Complexidade de Código (RubyCritic)

* **Overview RubyCritic:**
  
![overview](https://github.com/user-attachments/assets/8f7f39d1-0f56-46a8-a81c-d7b527973ed9)

* **Code RubyCritic:**
| Rating | Name                          | Churn | Complexity | Duplication | Smells |
|--------|-------------------------------|-------|------------|-------------|--------|
| F      | ImportacoesController         | 3     | 450.37     | 284         | 63     |
| D      | FormulariosController         | 6     | 213.39     | 38          | 25     |
| D      | FormulariosController         | 2     | 137.89     | 44          | 21     |
| C      | AlunoImporterService          | 2     | 93.15      | 92          | 21     |
| B      | RespostaQuestao               | 3     | 85.92      | 0           | 7      |
| B      | ResultadosController          | 3     | 78.13      | 0           | 9      |
| B      | FormulariosController         | 5     | 75.49      | 0           | 3      |
| B      | TemplatesController           | 10    | 52.25      | 0           | 4      |
| A      | TemplatesController           | 6     | 45.02      | 0           | 3      |
| A      | ImportacoesController         | 12    | 44.66      | 0           | 7      |
| A      | Usuario                       | 18    | 41.58      | 0           | 11     |
| A      | TurmasController              | 4     | 37.14      | 0           | 7      |
| A      | TurmaImporterService          | 2     | 34.07      | 0           | 8      |
| A      | PasswordsController           | 3     | 22.9       | 0           | 1      |
| A      | PasswordComplexityValidator   | 1     | 16.92      | 0           | 4      |
| A      | Questao                       | 8     | 14.06      | 0           | 1      |
| A      | SessionsController            | 6     | 13.11      | 0           | 2      |
| A      | TurmasController              | 2     | 11.21      | 0           | 1      |
| A      | ApplicationController         | 18    | 9.0        | 0           | 1      |
| A      | SessionsController            | 4     | 8.8        | 0           | 1      |
| A      | Template                      | 13    | 6.95       | 0           | 1      |
| A      | BaseController                | 7     | 6.2        | 0           | 0      |
| A      | PasswordResetToken            | 2     | 5.4        | 0           | 2      |
| A      | DashboardController           | 3     | 4.81       | 0           | 2      |
| A      | Formulario                    | 6     | 4.71       | 0           | 1      |
| A      | Turma                         | 8     | 4.2        | 0           | 1      |
| A      | BaseController                | 4     | 3.45       | 0           | 2      |
| A      | CustomDeviseMailer            | 3     | 3.0        | 0           | 2      |
| A      | PasswordResetsController      | 5     | 1.0        | 0           | 2      |
| A      | AlunosController              | 4     | 0.0        | 0           | 1      |
| A      | HomeController                | 2     | 0.0        | 0           | 1      |
| A      | PagesController               | 2     | 0.0        | 0           | 1      |
| A      | ApplicationHelper             | 2     | 0.0        | 0           | 1      |
| A      | HomeHelper                    | 2     | 0.0        | 0           | 1      |
| A      | ApplicationJob                | 2     | 0.0        | 0           | 1      |
| A      | ApplicationMailer             | 3     | 0.0        | 0           | 1      |
| A      | ApplicationRecord             | 2     | 0.0        | 0           | 1      |
| A      | Disciplina                    | 3     | 0.0        | 0           | 1      |
| A      | JwtDenylist                   | 2     | 0.0        | 0           | 1      |
| A      | RespostaFormulario            | 2     | 0.0        | 0           | 1      |

### Documentação (RDoc)

**Responsável:** `[Luis Gustavo]`

* Nem todos os métodos criados ou significativamente alterados nos controllers e models da aplicação foram devidamente documentados seguindo o padrão RDoc, porém todos foram comentados explicando sua finalidade, argumentos, retornos e efeitos colaterais. 

**Cobertura de Documentação:** 59.91%  
**Arquivos Analisados:** 270  
**Itens Documentados:** 136/227  

| Categoria | Total | Não Documentados | % Coberto |
|-----------|-------|------------------|-----------|
| Classes   | 71    | 36               | 49.3%     |
| Modules   | 9     | 4                | 55.6%     |
| Methods   | 144   | 50               | 65.3%     |
| Constants | 2     | 1                | 50%       |

* Total: 227 (91 não documentado)
    59.91% documentado


## Considerações Finais do Trabalho

Tivemos muitos problemas na implementação e nos testes, que acabaram levando mais tempo do que o previsto. Por conta disso, não conseguimos concluir todas as entregas conforme solicitado. Percebemos que a organização era crucial para o andamento do projeto, mas a quantidade de trabalhos no final do semestre dificultou bastante. Apesar do sistema estar funcional, os testes não garantem uma cobertura adequada e não conseguimos revisar o ABC Score como planejado.

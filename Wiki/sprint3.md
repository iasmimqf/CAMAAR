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

O trabalho nesta feature também começou com a padronização dos testes.

* **BDD e Estratégia de Teste:** O arquivo `.feature` (`definicao_de_senha.feature`) foi ajustado para descrever claramente os cenários de negócio. Para esta feature, que é **puramente uma funcionalidade de API** (o frontend envia um token e uma nova senha, o backend responde com JSON), foi adotada uma estratégia de teste focada em RSpec Request Specs.

* **Testes de Aceitação (RSpec):** O arquivo `passwords_api_spec.rb` foi criado para servir como o **teste de aceitação principal** da API. Ele cobre exaustivamente todos os cenários de Happy Path e Sad Path, incluindo:
    * Solicitação de redefinição para um usuário existente (Happy Path).
    * Redefinição de senha com um token válido (Happy Path).
    * Tentativa de redefinição com senhas que não conferem (Sad Path).
    * Tentativa de redefinição com uma senha fraca que não passa nas validações (Sad Path).
    * Tentativa de redefinição com um token inválido (Sad Path).

* **Justificativa:** Esta abordagem foi escolhida porque o RSpec permite a verificação precisa das respostas JSON e dos códigos de status, cumprindo o requisito de testar todos os caminhos da feature. Por este motivo, a implementação dos "steps" do Cucumber, que recriaria os mesmos testes de API, foi considerada redundante para esta funcionalidade específica.

### Feature 3: Importação de Dados do SIGAA

**Responsáveis:** `[Iasmim e Hudson]`

O objetivo desta feature é permitir que um administrador importe dados de Turmas e Alunos/Professores a partir de arquivos JSON, populando a base de dados do sistema.

* **Lógica de Negócio Implementada:**
    * O sistema utiliza uma lógica "encontre ou crie" para evitar a duplicação de `Disciplinas`, `Turmas` e `Usuarios`.
    * Ao criar um **novo usuário** (aluno ou professor) através da importação, o sistema automaticamente dispara um **e-mail para a definição de senha**, cumprindo um requisito chave da funcionalidade.

* **Testes (RSpec):** Os testes de aceitação para esta feature foram implementados como **testes de serviço** em RSpec (`spec/services/`). Foram verificados varios **Happy Paths e Sad Paths**, como:
    * Criação correta de novos registros (turmas, alunos, professores).
    * Associação correta de alunos e professores às turmas.
    * Envio do e-mail de definição de senha apenas para novos usuários.
    * Tratamento de erros de ficheiro (JSON malformado, formato inválido).
    * Tratamento de erros de dados (turma inexistente, dados de usuário inválidos).

### Feature 4: Criação de Templates

**Responsáveis:** `[Iasmim e Hudson]`

Implementamos testes RSpec para a API de templates, cobrindo:

- Validações de campos obrigatórios (título e questões)
- Fluxos principais de criação, edição e exclusão
- Sad Paths (títulos vazios, templates sem questões, erros de autorização)
- Códigos de status HTTP adequados (400, 422)

*Testes de aceitação via Cucumber foram postergados para focar nos testes de integração. A feature está funcional e integrada em `develop`.*

### Feature 5: CRUD Templates

**Responsáveis:** `[Marcus e Hudson]` 

Os testes desta feature foram implementados por Marcus...

### Feature 6: Criação de Formulários

**Responsáveis:** `[Iasmim e Hudson]`

Foram implementados testes automatizados utilizando RSpec, cobrindo:

- Testes de model para validação dos atributos do formulário
- Testes de requests para os endpoints de criação, edição e envio de respostas de formulários
- Validação dos fluxos principais e dos Sad Paths (dados inválidos, erros de autorização, etc.)

### Status das demais features

As demais features não tiveram tempo hábil para revisão dos testes nesta sprint.

---
## Análise de Qualidade e Refatoração (Sprint 3)

*(Esta seção deve ser preenchida após a finalização de todas as implementações e testes)*

### Cobertura de Testes (SimpleCov)

* **Controllers:**
    * `Usuarios::SessionsController`: `[Preencher %]`
    * `Api::V1::PasswordsController`: `[Preencher %]`
* **Models:**
    * `Usuario`: `[Preencher %]`

### Complexidade de Código (RubyCritic)

* Nenhum método implementado nesta sprint apresentou um ABC Score igual ou superior a 20. As refatorações realizadas (como no `Admin::BaseController`) foram focadas em manter a complexidade baixa. (Assim espero!!!!)
* **Tabela de Refatorações Notáveis:**
    | Método Original | Complexidade ABC (Antes) | Complexidade ABC (Depois) | Justificativa |
    | :--- | :--- | :--- | :--- |
    | `Admin::BaseController#authenticate_admin_access!` | 20.43 | `[Preencher]` | O método foi reescrito de forma mais linear, utilizando helpers do Devise e `respond_to`, o que reduziu o número de ramificações e condições. |
    | `[Outro método, se houver]` | `...` | `...` | `...` |


### Documentação (RDoc)

* Todos os métodos criados ou significativamente alterados nos controllers e models da aplicação foram documentados seguindo o padrão RDoc, explicando sua finalidade, argumentos, retornos e efeitos colaterais.

## Considerações Finais do Trabalho

Tivemos muitos problemas na implementação e nos testes, que acabaram levando mais tempo do que o previsto. Por conta disso, não conseguimos concluir todas as entregas conforme solicitado. Percebemos que a organização era crucial para o andamento do projeto, mas a quantidade de trabalhos no final do semestre dificultou bastante. Apesar do sistema estar funcional, os testes não garantem uma cobertura adequada e não conseguimos revisar o ABC Score como planejado.
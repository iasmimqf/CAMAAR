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
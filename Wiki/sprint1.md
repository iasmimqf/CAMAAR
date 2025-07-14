# Wiki - Projeto CAMAAR  
*(Sprint 2: Implementaçã### Formulários & Relatórios 🔄

| Funcionalidade               | Status | Responsável | Observações |
|------------------------------|--------|-------------|-------------|
| Criar Formulário             | ✅ DONE | Marcus | Interface e backend integrados |
| Responder Formulário         | ✅ DONE | Marcus | Fluxo completo implementado |
| Visualizar Formulários Pendentes | ✅ DONE | Marcus | Interface responsiva |
| Gerar Relatório              | 📋 SPRINT 3 | A definir | Pendente: CSV export completo |
| Visualizar Resultados        | 📋 SPRINT 3 | A definir | Pendente: Dashboard e gráficos |lários & Relatórios 🔄

## Equipe  

| Nome                              | Matrícula  | Papel           |  
|-----------------------------------|------------|----------------|  
| Iasmim de Queiroz Freitas         | 190108665  | **Scrum Master** |  
| Hudson Cauã Costa Lima            | 211055512  | **Product Owner** |  
| Luis Gustavo de Sousa Silva       | 200046527  | Desenvolvedor   |  
| Marcus Emanuel Carvalho T. Freitas| 222025960  | Desenvolvedor   |  

---
## Link do repositório - https://github.com/iasmimqf/CAMAAR

## Sprint 2 - Objetivos e Resultados

### Objetivos da Sprint 2
- **Implementação das features** cujos cenários BDD foram especificados na Sprint 1
- **Desenvolvimento dos controllers, views e models** necessários
- **Integração e validação** das funcionalidades implementadas
- **Documentação atualizada** das features na Wiki do repositório
- **Kanban organizado** usando a interface de projetos do GitHub

### Metodologia de Testes
**Nota sobre RSpec:** Embora inicialmente planejado o uso de RSpec para testes unitários, a equipe optou por focar na implementação das funcionalidades usando Cucumber para testes BDD durante esta sprint. **O RSpec será implementado na Sprint 3** para complementar a cobertura de testes com testes unitários e de integração.

### Kanban - Organização do Trabalho
O projeto utiliza a interface de projetos do GitHub com as seguintes lanes:
- **Backlog**: Features planejadas para implementação
- **Doing**: Features em desenvolvimento ativo
- **Done**: Features implementadas e testadas
- **Accepted**: Features validadas e aceitas pelo Product Owner

## Status das Funcionalidades - Sprint 2  

### Autenticação ✅

| Funcionalidade               | Status | Responsável | Observações |
|------------------------------|--------|-------------|-------------|
| Sistema de Login             | ✅ DONE | Luis Gustavo (Front) + Iasmin (Back) | Interface completa + validações Devise |
| Sistema de Definição de Senha| 🔄 DOING | Hudson (Back) + Luis Gustavo (Front) | Validações backend + formulários responsivos |

### Gestão de Templates ✅

| Funcionalidade               | Status | Responsável | Observações |
|------------------------------|--------|-------------|-------------|
| Criar Template               | ✅ DONE | Marcus (Back) + Luis (Front) + Iasmim (Integração) | CRUD completo, interface integrada |
| Editar/Deletar Template      | ✅ DONE | Marcus (Back + Testes) + Luis (Interface) | Validações, permissões e UX completos |
| Visualizar Templates         | ✅ DONE | Marcus | Interface administrativa responsiva |

### Formulários & Relatórios 🔄

| Funcionalidade               | Status | Responsável | Pontos | Observações |
|------------------------------|--------|-------------|--------|-------------|
| Criar Formulário             | ✅ DONE |  Marcus | 3      | Interface e backend integrados |
| Responder Formulário         | ✅ DONE | Marcus | 3      | Fluxo completo implementado |
| Visualizar Formulários Pendentes | ✅ DONE | Marcus | 2      | Interface responsiva |
| Gerar Relatório              | � SPRINT 3 | A definir | 3      | Pendente: CSV export completo |
| Visualizar Resultados        | 📋 SPRINT 3 | A definir | 5      | Pendente: Dashboard e gráficos |

### Integração 📋

| Funcionalidade               | Status | Responsável | Observações |
|------------------------------|--------|-------------|-------------|
| Integrar Front-end com Backend (Formulários/Templates) | 🔄 DOING | Iasmim + Hudson | Conexão de interfaces com APIs |
| Importar Dados do SIGAA      | 📋 SPRINT 2 | Hudson | Análise completa, implementação pendente |
| Atualizar Base com SIGAA     | 📋 SPRINT 2 | Iasmim | Arquitetura planejada |


## Implementações Técnicas Realizadas

### Models & Backend (Marcus)
- **Template**: Modelo consolidado com documentação completa e scopes
- **Questao**: Modelo português ativo (Question em inglês removido)
- **Usuario**: Sistema de autenticação com Devise integrado
- **Formulario**: Relacionamentos e validações implementadas
- **Turma/Disciplina**: Estrutura base com foreign keys

### Controllers & API (Marcus)
- **Admin::TemplatesController**: CRUD completo para templates
- **Admin::FormulariosController**: Gestão de formulários e relatórios
- **ApplicationController**: Autenticação e autorização base
- **HomeController**: Endpoints principais

### Front-end & Interface (Luis Gustavo)
- **Interface administrativa**: Layout completo e responsivo
- **Formulários dinâmicos**: Criação e edição de templates
- **Páginas de listagem**: Filtros e paginação
- **Componentes reutilizáveis**: Botões, modais, navegação
- **UX/UI**: Design consistente e intuitivo

### Integração & Coordenação (Iasmim & Hudson)
- **Fluxos end-to-end**: Validação de funcionalidades completas
- **Coordenação técnica**: Integração entre front e back
- **Verificação de requisitos**: Validação com critérios de aceitação
- **Testes de aceitação**: Validação de cenários de usuário

### Testes & Quality Assurance (Marcus + Equipe)
- **13 features BDD**: Especificadas em Gherkin/Cucumber
- **Testes de formulários**: Cobertura de cenários críticos
- **85% de aprovação**: Nos testes implementados
- **Testes de integração**: Validação de fluxos completos

## Política de Branching - Sprint 2

### Fluxo Atual
- **`main`**: Branch protegida (versão estável)
- **`feature/F7-F8`**: Branch de desenvolvimento ativa
- **Branches específicas** por funcionalidade

### Processo de Desenvolvimento
1. **Feature branches** criadas a partir de `main`
2. **Pull requests** para revisão de código
3. **Testes automáticos** executados no CI
4. **Merge** após aprovação

---

### Distribuição de Responsabilidades - Sprint 2

#### Front-end 🎨
**Luis Gustavo** - Desenvolvedor Front-end
- Interface administrativa completa
- Layouts responsivos
- Componentes de formulários
- Navegação e UX

#### Back-end & Testes 🔧
**Marcus** - Desenvolvedor Back-end
- Models consolidados (Template, Questao)
- Controllers implementados
- Testes BDD de formulários
- Validações e regras de negócio

#### Integração & Verificação 🔗
**Iasmim** (Scrum Master) & **Hudson** (Product Owner)
- Integração de telas e funcionalidades
- Verificação de requisitos
- Coordenação entre front-end e back-end
- Validação de fluxos completos

### Distribuição por Membro
| Membro | Responsabilidade Principal | Status |
|--------|---------------------------|---------|
| Luis Gustavo | Front-end & Interface | ✅ Meta superada |
| Marcus | Back-end & Testes | ✅ Meta superada |
| Iasmim | Integração & Coordenação | ✅ Meta atingida |
| Hudson | Verificação & Validação | ✅ Meta atingida |

## Resumo da Sprint 2

### ✅ Sucessos
- **Front-end completo** desenvolvido por Luis Gustavo
- **Back-end robusto** implementado por Marcus com testes BDD
- **Integração eficiente** coordenada por Iasmim e Hudson
- **Interface administrativa** completamente funcional
- **Consolidação dos models** com nomenclatura consistente
- **Colaboração excepcional** entre as equipes

### 🔄 Funcionalidades Principais Implementadas
- **Sistema de Templates:** CRUD completo com validações
- **Gestão de Formulários:** Interface administrativa funcional
- **Autenticação:** Sistema seguro com Devise
- **Estrutura de Dados:** Models consolidados e relacionamentos

### 📋 Roadmap Sprint 3 - Prioridades

#### 🎯 Funcionalidades Críticas
1. **Relatórios Avançados**
   - Exportação CSV completa
   - Filtros e agregações
   - **Responsável:** Marcus (back-end) + Luis Gustavo (front-end)

2. **Visualização de Resultados**
   - Gráficos interativos
   - Dashboard analítico
   - Métricas em tempo real
   - **Responsável:** Luis Gustavo (front-end) + Marcus (API)

#### 🧪 Melhoria de Testes
3. **Refatoração de Testes**
   - Implementação de RSpec (testes unitários)
   - Ampliação da cobertura BDD
   - Testes de integração
   - **Responsável:** Marcus (liderança) + toda equipe

4. **Qualidade de Código**
   - Code review sistemático
   - Documentação técnica
   - Performance optimization
   - **Responsável:** Iasmim (coordenação) + Hudson (validação)

### 🔄 Distribuição Sprint 3
- **Luis Gustavo:** Dashboard e visualizações
- **Marcus:** APIs de relatórios e arquitetura de testes
- **Iasmim:** Coordenação e integração de componentes
- **Hudson:** Validação de requisitos e UX
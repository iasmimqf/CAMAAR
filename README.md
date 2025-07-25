# CAMAAR
Sistema para avaliação de atividades acadêmicas remotas do CIC
---
---
## Pré-requisitos

Antes de começar, garanta que você tenha o seguinte instalado:
* Ruby & Bundler
* Node.js & npm
* SQLite3

---
## Como Rodar o Projeto

Para rodar a aplicação completa, você precisará de **dois terminais abertos** ao mesmo tempo: um para o backend e um para o frontend.

### 1. Instalar Dependências

Execute os comandos a partir da **pasta raiz** do projeto.

```bash
# 1. Instala as dependências do Ruby (backend)
bundle install

# 2. Navega até a pasta do frontend e instala as dependências do Node.js
cd src
npm install
cd .. 
# Volta para a pasta raiz
```

### 2. Preparar o Banco de Dados

Este comando irá criar o banco de dados, carregar a estrutura das tabelas e popular com dados iniciais (como o usuário admin). Execute a partir da **pasta raiz**.

```bash
rails db:reset
```

### 3. Iniciar a Aplicação

* **No Terminal 1 (Backend):**
  Inicie o servidor Rails na porta `3000`.

    ```bash
    # Na pasta raiz do projeto
    rails server
    ```

* **No Terminal 2 (Frontend):**
  Navegue até a pasta `src` e inicie o servidor de desenvolvimento do Next.js.

    ```bash
    # Primeiro, entre na pasta do frontend
    cd src

    # Inicie o servidor do Next.js
    npm run dev
    ```

### 4. Acesse a Aplicação

Com os dois servidores rodando, abra seu navegador e acesse o endereço do **frontend**:

**`http://localhost:3002`**

A aplicação estará funcionando. O frontend em `localhost:3002` fará as chamadas de API para o seu backend em `localhost:3000`.

---
## Tecnologias Utilizadas

* **Backend:** Ruby on Rails (API-only)
* **Frontend:** Next.js, React, TypeScript, Tailwind CSS
* **Autenticação:** Devise
* **Testes:** RSpec & Cucumber

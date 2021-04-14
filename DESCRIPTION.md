# API de Banking

O sistema deve oferecer a possibilidade de usuários realizarem transações financeiras
como saque e transferencia entre contas.

Um usuário pode se cadastrar e ao completar o cadastro ele recebe R$ 1000,00.

Com isso ele pode transferir dinheiro para outras contas e pode sacar dinheiro. O saque do dinheiro simplesmente manda um email para o usuário informando sobre o saque e reduz o seu saldo (o envio de email não precisa acontecer de fato, pode ser apenas logado e colocado como "placeholder" para envio de email de fato).

Nenhuma conta pode ficar com saldo negativo.

É necessário autenticação para realizar qualquer operação.

É preciso gerar um relatório no backoffice que dê o total transacionado (R$) por dia, mês, ano e total.

## Requisitos Técnicos

* O desafio deve ser feito na linguagem [Elixir](http://elixir-lang.github.io/).
* A API deve utilizar JSON (i.e.: Accept e Content-type)
* O uso de Docker é obrigatório.


## Critérios de Avaliação

* Familiaridade com o ecossistema Elixir
* Testes e Cobertura
* Documentação
  * Setup
  * Módulos
  * Deployment
  * API
* Deploy em local acessível publicamente


## Material de Estudo
* [Elixir School - Lições sobre a linguagem de programação Elixir](https://elixirschool.com/pt/)
* [O Guia de Estilo Elixir](https://github.com/gusaiani/elixir_style_guide/blob/master/README_ptBR.md)
* [Floating Point Math](https://0.30000000000000004.com/)


## Sugestões

* [Phoenix](https://github.com/phoenixframework/phoenix)
* [comeonin](https://github.com/riverrun/comeonin)
   * Na configuração de testes, configure o backend para fazer menos operações (ex.: config :bcrypt_elixir, :log_rounds, 4). Isso vai agilizar a suite de testes.
 * Atenção na autenticação do backoffice.
 * [credo](https://github.com/rrrene/credo)
 * [Heroku](https://www.heroku.com/) e [Gigalixir](https://www.gigalixir.com/)

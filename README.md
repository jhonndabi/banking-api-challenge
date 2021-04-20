# Banking Api Challenge

Aplicação do desafio proposto no encerramento do Programação de Formação em Elixir da Stone.

## Rodando a aplicação

Para levantar a aplicação é necessário levantar o banco de dados configurado com docker e rodar o comando de setup:

```shell
docker-compose up -d

mix setup

mix phx.server
```

Após isso você pode acessar a aplicação no seguinte endereço: `http://localhost:4000/`

Para listar as rotas disponíveis na aplicação execute o seguinte comando no terminal:

```shell
mix phx.routes BankingApiChallengeWeb.Router
```

## Rodando os testes

Para rodar a suíte de teste é necessário levantar o banco de dados primeiro configurado com o docker-compose:

```shell
docker-compose up -d

MIX_ENV=test mix setup

mix test
```

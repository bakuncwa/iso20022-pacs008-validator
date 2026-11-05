-include .env
export

N ?= 5000
RUN ?= run-001
RATE ?= 0.10
CONSUMERS ?= 8

.PHONY: build generate inject validate test api bench db-up db-init db-down

build:
	dotnet build

generate:
	./generator/run_rapide.sh $(N) $(RUN)

inject:
	dotnet run --project src/Iso20022.Injector -- --run $(RUN) --rate $(RATE)

validate:
	dotnet run --project src/Iso20022.Worker -- --run $(RUN) --consumers $(CONSUMERS)

test:
	dotnet test

api:
	dotnet run --project src/Iso20022.Api

bench:
	dotnet run -c Release --project tests/Iso20022.Benchmarks

db-up:
	docker compose up -d sql

db-init:
	docker compose exec sql /opt/mssql-tools18/bin/sqlcmd -C -b -S localhost -U sa -P "$(MSSQL_SA_PASSWORD)" -i /sql/01_schema.sql -i /sql/02_seed.sql

db-down:
	docker compose down

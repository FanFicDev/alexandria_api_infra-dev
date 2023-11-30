.PHONY: psql

psql:
	docker-compose exec db psql 'postgresql://hermes:pgpass@localhost/hermes'


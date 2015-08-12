.PHONY: null backup migrate build

null:
	echo "Choose a task init_db, local, build, test_db, backup"

backup:
	mkdir -p backup
	pg_dump -F c -U postgres moonscrape > backup/$$(date +%F_%H-%M-%S)_$$(luajit -e 'print(require("lapis.db").query("select max(name) from lapis_migrations")[1].max)').dump

migrate: build
	lapis migrate

build:
	tup

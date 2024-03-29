.DEFAULT_GOAL := list
list:
	@printf "%-20s %s\n" "Target" "Description"
	@printf "%-20s %s\n" "------" "-----------"
	@make -pqR : 2>/dev/null \
			| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
			| sort \
			| egrep -v -e '^[^[:alnum:]]' -e '^$@$$' \
			| xargs -I _ sh -c 'printf "%-20s " _; make _ -nB | (grep -i "^# Help:" || echo "") | tail -1 | sed "s/^# Help: //g"'
test:
	@# Help: Exec rspec tests
	@rails db:migrate RAILS_ENV=test
	@bundle exec rspec
install:
	@# Help: Install dependencies
	@bundle install foreman
	@bundle install
update:
	@# Help: Update dependencies
	@bundle update
audit:
	@# Help: Run audit tasks
	@bundle audit
clean:
	@# Help: Clear dependencies
	@bundle clean --force
run:
	@# Help: Run server
	@rails s
lint:
	@# Help: Run linter
	@standardrb --fix
migrate:
	@# Help: Migrate database
	@rails db:migrate
rollback:
	@# Help: Rollback database
	@rails db:rollback

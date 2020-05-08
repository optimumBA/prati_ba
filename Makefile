.PHONY: build

certbot:
	@docker-compose up certbot
	@docker-compose stop certbot
	@echo "[✔️] Certificate creation/renewal complete!"

start:
	@make certbot
	@docker-compose up -d --scale certbot=0
	@echo "[✔️] Docker containers started!"

stop:
	@docker-compose stop
	@echo "[✔️] Docker containers stopped!"

restart:
	@docker-compose restart
	@echo "[✔️] Docker containers restarted!"

update:
	@git pull
	@echo "[✔️] Git pulled!"
	@docker-compose build
	@echo "[✔️] Docker image build complete!"
	@make restart

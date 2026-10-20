#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ok()   { echo -e "${GREEN}$1${NC}"; }
fail() { echo -e "${RED}$1${NC}"; }

case "$1" in
	start)
		docker compose up -d --build
		elapsed=0
		db_ready=false
		while [ $elapsed -lt 10 ]; do
			if docker compose exec -T postgres pg_isready -U postgres; then
				db_ready=true
				break
			fi
			sleep 2
			elapsed=$((elapsed+2))
		done
		sleep 5
		if [ "$db_ready" = true ] && \
			curl -fs http://localhost:8080/actuator/health | grep -q '"status":"UP"' ; then
				ok "He thong quickbite hoat dong on dinh!"
				exit 0
		fi

		fail "Khoi dong that bai: database hoac API khong san sang"
		docker compose logs --tail 20 backend
		docker compose down 
		exit 1
		;;
	stop) docker compose stop;;
	clean) docker compose down -v ;;
	*) echo "Cach dung: $0 [start|stop|clean]"; exit 1;;
esac


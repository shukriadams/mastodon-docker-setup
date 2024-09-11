set -e

NOW=$(date +%F)

# backup postgres
docker exec -it mastodon-db sh -c "pg_dumpall -U postgres > /tmp/all.sql"
docker exec -it mastodon-db sh -c "cp /tmp/all.sql /postgres_backups/all.sql"

# pack everything of value into zip
zip -r ./backup_$NOW.zip ./redis ./postgres_backups ./public ./backup.sh ./docker-compose.yml ./.env.production ./proxy -x "public/system/cache/**"

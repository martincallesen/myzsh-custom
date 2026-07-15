#!/bin/zsh

function create_wordpress_post() {
    local username=$1
    local password=$2
    local url=$3

    local title=$4
    local content=$5

    local data=$(cat <<EOF
{
  "title": "${title}",
  "content": "${content}",
  "status": "publish"
}
EOF
)

    curl --user "${username}:${password}" \
         --header "Content-Type: application/json" \
         --data "${data}" \
         ${url}
}

# Brug funktionen til at oprette et nyt indlæg
# eks. create_wordpress_post $WP_USERNAME $WP_PASSWORD $1 "Titlen på dit indlæg" "Dit indlægsindhold her."
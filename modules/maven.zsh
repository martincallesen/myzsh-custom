function mvn() {
  if [[ -f ./mvnw ]]; then
    ./mvnw "$@"
  else
    command mvn "$@"
  fi
}

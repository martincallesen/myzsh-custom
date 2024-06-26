# Function to use mvnw if available
function mvn() {
  if [ -f ./mvnw ]; then
    echo 'Detected mvnw script file, using mvnw instead of mvn'
    ./mvnw "$@"
  else
    command mvn "$@"
  fi
}
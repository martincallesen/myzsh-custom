# Maven configuration and utilities
# Provides Maven wrapper (mvnw) detection and fallback to system Maven

# Function to use mvnw if available
# This wrapper checks if a Maven wrapper script exists in the current project
# and uses it for consistency. Falls back to the system mvn command if not available.
# 
# Usage: mvn [options] [goals]
# Example: mvn clean install
#          mvn test -DskipTests
function mvn() {
  # Check if Maven wrapper script exists in current directory
  if [ -f ./mvnw ]; then
    echo 'Detected mvnw script file, using mvnw instead of mvn'
    # Use the local Maven wrapper with all passed arguments
    ./mvnw "$@"
  else
    # Fall back to system Maven installation
    command mvn "$@"
  fi
}
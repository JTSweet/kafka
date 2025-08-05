# Use the official, verified IBM Semeru JDK 21 image
FROM ibm-semeru-runtimes:open-21.0.8_9-jdk-jammy

# Set metadata labels for clarity
LABEL maintainer="TSweet"
LABEL description="Build environment for Apache Kafka with IBM Semeru JDK 21"

# Set the working directory inside the container
WORKDIR /app

# CORRECTED COMMAND:
# Install certificate authorities and GPG tools first to ensure
# the package manager can securely access repositories, then install git.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy your entire Kafka source code into the container's working directory
COPY . .

# Set the command to run when the container starts.
# This executes the Gradle build inside the container with our proven flags.
CMD ["./gradlew", "clean", "releaseTarGz", "-x", "test", "-x", "integrationTest", "--no-build-cache", "--no-configuration-cache", "--no-daemon"]

# Use the official, verified IBM Semeru JDK 21 image
FROM ibm-semeru-runtimes:open-21.0.8_9-jdk-jammy

# Set metadata labels for clarity
LABEL maintainer="TSweet"
LABEL description="Build environment for Apache Kafka with IBM Semeru JDK 21"

# Set an environment variable to increase Gradle's heap size.
# This gives the main Gradle process 2GB of heap memory.
ENV GRADLE_OPTS="-Xmx2g"

# Set the working directory inside the container
WORKDIR /app

# Install certificate authorities, GPG tools, and git
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy your entire Kafka source code into the container's working directory
COPY . .

# Set the command to run when the container starts.
# Gradle will automatically pick up the GRADLE_OPTS environment variable.
CMD ["./gradlew", "clean", "releaseTarGz", "-x", "test", "-x", "integrationTest", "--no-build-cache", "--no-configuration-cache", "--no-daemon"]

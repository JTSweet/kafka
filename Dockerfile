# =============================================================================
# Stage 1: The Builder
# Use the full JDK to build the Kafka project from source.
# =============================================================================
FROM eclipse-temurin:21-jdk as builder

WORKDIR /app

# Copy source code into the builder
COPY . .

# Run the Gradle command to create the distribution tarball
RUN ./gradlew releaseTarGz -x test -x integrationTest --no-build-cache --no-configuration-cache --no-daemon

# Unpack the tarball into a clean directory
RUN mkdir /opt/kafka && tar -xzf ./core/build/distributions/kafka_2.13-*.tgz -C /opt/kafka --strip-components 1


# =============================================================================
# Stage 2: The JRE Runtime Image (for Production)
# A lean image with only the Java Runtime Environment.
# =============================================================================
FROM eclipse-temurin:21-jre

# Copy the compiled Kafka application from the builder stage
COPY --from=builder /opt/kafka /opt/kafka

# (Add user creation, permissions, and other runtime configurations here later)
WORKDIR /opt/kafka
# Default command to run when the container starts
CMD ["bin/kafka-server-start.sh", "config/kraft/server.properties"]


# =============================================================================
# Stage 3: The JDK Runtime Image (for Development/Diagnostics)
# A larger image that includes the full JDK for troubleshooting.
# =============================================================================
FROM eclipse-temurin:21-jdk

# Copy the compiled Kafka application from the builder stage
COPY --from=builder /opt/kafka /opt/kafka

# (Add user creation, permissions, and other runtime configurations here later)
WORKDIR /opt/kafka
# Default command to run when the container starts
CMD ["bin/kafka-server-start.sh", "config/kraft/server.properties"]

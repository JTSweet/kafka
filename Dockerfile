# STAGE 1: Build Stage
# Use the full IBM Semeru OpenJ9 JDK image as the builder environment.
FROM ibm-semeru-runtimes:open-21-jdk as builder

# Set the working directory for the build.
WORKDIR /opt/app

# Copy the entire project source code into the builder stage.
# This is necessary for Gradle to perform the build.
COPY..

# Grant execution permissions to the Gradle wrapper script.
RUN chmod +x./gradlew

# Execute the test-free build. This command generates the Kafka distribution
# archive (a.tgz file) in the 'distribution/build/distributions/' directory.
RUN./gradlew assemble -x test

# STAGE 2: Runtime Stage
# Start fresh with the minimal IBM Semeru OpenJ9 JRE image for a smaller, more secure final artifact.
FROM ibm-semeru-runtimes:open-21-jre

# Set the working directory for the running Kafka application.
WORKDIR /opt/kafka

# Copy ONLY the final distribution tarball from the builder stage.
# This is the core principle of a multi-stage build, discarding all source and build tools.
# The wildcard (*) handles variations in the Kafka version number in the filename.
COPY --from=builder /opt/app/distribution/build/distributions/kafka_*.tgz.

# Unpack the distribution archive into the current directory (/opt/kafka),
# stripping the top-level directory from the archive. Then, remove the.tgz file to save space.
RUN tar -xzf kafka_*.tgz --strip-components=1 && rm kafka_*.tgz

# Expose the default Kafka port for client connections.
EXPOSE 9092

# Define the command to run when the container starts.
# This executes the official Kafka startup script, passing the default server properties file.
# Sources: [1, 2]
CMD ["bin/kafka-server-start.sh", "config/server.properties"]

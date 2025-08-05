pipeline {
    // Run on any agent that has Docker installed
    agent any

    stages {
        stage('Initialize Build Environment') {
            steps {
                script {
                    echo "--- Verifying Jenkins Agent Sanity ---"
                    sh 'uname -a' // OS and kernel info
                    echo "Verifying ulimits..."
                    sh 'ulimit -a'
                    echo "Verifying systemd task limits (if applicable)..."
                    // This command will show the slice and its limits, confirming our previous work
                    sh 'systemctl status user-$(id -u).slice || echo "Could not query systemd slice."'
                    echo "------------------------------------"
                }
            }
        }

        stage('Checkout Docker Build Branch') {
            steps {
                // Jenkins will automatically check out the correct branch
                // specified in the job configuration.
                echo "Checked out branch: ${env.BRANCH_NAME}"
            }
        }

        stage('Build and Package inside Docker') {
            steps {
                script {
                    echo "Building Kafka with IBM Semeru JDK inside a Docker container..."

                    // Build the Docker image from our Dockerfile
                    // We tag it with the build number for easy identification
                    def dockerImage = docker.build("kafka-build-ibm-jdk:${env.BUILD_NUMBER}", ".")

                    // Run the container. The build command from the Dockerfile's CMD will execute.
                    // We add a try/finally block to ensure we handle success and failure
                    try {
                        dockerImage.run()
                        echo "Docker build completed successfully."
                        currentBuild.result = 'SUCCESS'
                    } catch (e) {
                        echo "Docker build failed."
                        currentBuild.result = 'FAILURE'
                        throw e // Re-throw the exception to fail the pipeline
                    }
                }
            }
        }
    }
    post {
        always {
            // Clean up the workspace to save disk space
            cleanWs()
        }
    }
}

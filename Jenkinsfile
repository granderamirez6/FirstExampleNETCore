pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Clonar el repositorio de Git en el directorio de trabajo del agente
                checkout scm
            }
        }

        stage('Deploy') {
            environment {
                // Define las variables de entorno para el despliegue
                // Asegúrate de reemplazar los valores con los de tu clúster OpenShift
                OPENSHIFT_NAMESPACE = 'granderamirez-6-dev'
                OPENSHIFT_API_URL = 'https://api.sandbox-m3.1530.p1.openshiftapps.com:6443'
                OPENSHIFT_TOKEN = 'sha256~1qcyg2e-TekWQxE67c6CWNZ3WEogZItPuKpuM3Mn6QM'
                APPLICATION_NAME = 'core-example'
                EXISTING_IMAGE_NAME = "image-registry.openshift-image-registry.svc:5000/granderamirez-6-dev/core-example-app"
                BUILD_CONFIG_NAME = 'new-example'
            }
            steps {
                script {
                    // Iniciar sesión en el clúster OpenShift
                    sh "oc login ${OPENSHIFT_API_URL} --token=${OPENSHIFT_TOKEN}"

                    // Check if the Deployment exists
                    def deploymentExists = sh(returnStatus: true, script: "oc get deployment ${APPLICATION_NAME} -n ${OPENSHIFT_NAMESPACE} --no-headers")

                    if (deploymentExists == 0) {
                        echo "Deployment ${APPLICATION_NAME} already exists. Updating the existing Deployment."
                        // Update the existing deployment with the latest image
                        sh "oc set image deployment/${APPLICATION_NAME} ${APPLICATION_NAME}=${EXISTING_IMAGE_NAME} -n ${OPENSHIFT_NAMESPACE}"
                    } else {
                        // Create the Deployment if it does not exist
                        try {
                            sh "oc new-app ${EXISTING_IMAGE_NAME} --name=${APPLICATION_NAME} -n ${OPENSHIFT_NAMESPACE}"
                        } catch (Exception e) {
                            echo "Failed to create Deployment. It may already exist."
                        }
                    }

                    // Check if the service exists
                    def serviceExists = sh(returnStatus: true, script: "oc get service ${APPLICATION_NAME} -n ${OPENSHIFT_NAMESPACE} --no-headers")

                    if (serviceExists == 0) {
                        echo "Service ${APPLICATION_NAME} already exists. Reusing the existing service."
                    } else {
                        // Create the service if it does not exist
                        try {
                            sh "oc expose deployment ${APPLICATION_NAME} --port=80 -n ${OPENSHIFT_NAMESPACE}"
                        } catch (Exception e) {
                            echo "Failed to create Service. It may already exist."
                        }
                    }

                    // Check if the route exists
                    def routeExists = sh(returnStatus: true, script: "oc get route ${APPLICATION_NAME} -n ${OPENSHIFT_NAMESPACE} --no-headers")

                    if (routeExists == 0) {
                        echo "Route ${APPLICATION_NAME} already exists. Reusing the existing route."
                    } else {
                        // Patch the route if it does not exist
                        try {
                            sh "oc patch route ${APPLICATION_NAME} -p '{\"spec\":{\"to\":{\"name\":\"${APPLICATION_NAME}\"}}}' -n ${OPENSHIFT_NAMESPACE}"
                        } catch (Exception e) {
                            echo "Failed to patch the Route. It may already exist."
                        }
                    }
                     sh "oc start-build ${BUILD_CONFIG_NAME} -n ${OPENSHIFT_NAMESPACE}"
                }
            }
        }
    }
}

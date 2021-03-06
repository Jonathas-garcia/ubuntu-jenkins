Instalar plugins jenkins de git, docker, maven, blueOcean etc.

Configurar chave do dockerhub-token

Configurar tool docker

Pipeline:


```
pipeline {
    agent { docker { image 'maven:3.3.3' } }
       
    environment {
        PROJECT_NAME = 'poc-testcontainer'
        IMAGE_NAME = 'jonathasgarcia/poc-testcontainer'
		GIT_URL_REPO =  'https://github.com/Jonathas-garcia/poc-testcontainer.git'
		DOCKER_HUB_CREDENTIAL = 'jonathas-garcia-dockerhub-token'
    }
    	
    stages {
		stage('Setup environment') {
			steps {
				echo "Environment variables"
				echo "PROJECT_NAME = 'poc-testcontainer'"
				echo "IMAGE_NAME = 'jonathasgarcia/poc-testcontainer'"
				echo "GIT_URL_REPO =  'https://github.com/Jonathas-garcia/poc-testcontainer.git'"
			}
		}
		stage('Clone') {
			steps {
				echo "Clonando repositorio GIT"
				git "${GIT_URL_REPO}"
			}
		}
		stage('Unit Tests') {
			steps {
				echo "Iniciando unit tests"
				sh 'mvn test'
			}
		}
		
		stage('Build docker image') {
			steps {
				script {
				    def dockerHome = tool 'myDocker'
					env.PATH = "${dockerHome}/bin:${env.PATH}"
					echo "Iniciando build da imagem"
					def image = docker.build("${PROJECT_NAME}:${env.BUILD_ID}")
		
				}
			}
		}
		
		stage('Push docker image') {
			steps {
				script {					
					echo "Enviando imagem para registry"
					docker.withRegistry( '', DOCKER_HUB_CREDENTIAL ) {
						sh "docker tag ${PROJECT_NAME}:${env.BUILD_ID} ${IMAGE_NAME}:latest"
						sh "docker push ${IMAGE_NAME}:latest"
					}
				}
			}
		}
	}
}

```




docker run -it --name ubuntu-jenkins -p 8080:8080 -v jenkins-data:/var/lib/jenkins -v "$HOME":/home -v /var/run/docker.sock:/var/run/docker.sock ubuntu-jenkins
Instalar plugins jenkins de git, docker, maven, blueOcean, ansible etc.

Configurar chave do jonathas-garcia-dockerhub-token

Configurar tool docker - myDocker
Configurar tool ansible - myAnsible2 /usr/bin
Configurar tool maven - maven /usr/share/maven

Pipeline:

```
pipeline {
    agent any 
       
    environment {
        PROJECT_NAME = 'demo-jenkins-ansible'
        IMAGE_NAME = 'jonathasgarcia/demo-jenkins-ansible'
		GIT_URL_REPO =  'https://github.com/Jonathas-garcia/demo-jenkins-ansible.git'
		DOCKER_HUB_CREDENTIAL = 'jonathas-garcia-dockerhub-token'
    }
    	
    stages {
        
		stage('Setup environment') {
		    steps {
		        echo "Environment variables"
				echo "PROJECT_NAME = ${PROJECT_NAME}"
				echo "IMAGE_NAME = ${IMAGE_NAME}"
		        echo "GIT_URL_REPO =  ${GIT_URL_REPO}"
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
				sh 'mvn -v'
    			sh 'mvn clean test'
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
		stage('Deploy') {
		    steps {
		        script {
		            def ansibleHome = tool 'myAnsible2'
				    env.PATH = "${ansibleHome}:${env.PATH}"
				    ansiblePlaybook(playbook: '/var/lib/jenkins/workspace/playbooks/playbook.yml', inventory: '/var/lib/jenkins/workspace/playbooks/hosts', colorized: true)
		            //sh "ansible-playbook -vvv /var/lib/jenkins/workspace/playbooks/playbook.yml -i /var/lib/jenkins/workspace/playbooks/hosts"
		        }
		    }
		}
	}
}
```

COPIAR CHAVE PEM PARA HOST
COPIAR ARQUIVOS HOSTS E PLAYBOOK PARA HOST

CONFIGURA DOCKER-COMPOSE NA MAQUINA DESTINO

```
apt update
apt install python3 python3-pip
pip3 install docker docker-compose
```

AVALIAR SE DEVE UTILIZAR USUARIO ROOT COMO JENKINS_USER SENAO ADICIONAR PERMISSAO 777 NA CHAVE PEM


docker run -it --name ubuntu-jenkins -p 8080:8080 -v jenkins-data:/var/lib/jenkins -v "$HOME":/home -v /var/run/docker.sock:/var/run/docker.sock ubuntu-jenkins
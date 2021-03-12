
# Passos

Projeto com dockerfile que sobe imagem ubuntu com jenkins e Ansible instalados(e outras ferramentas), para criar pipeline com deploy em instancia ec2 configurada.

### Executando ubunto com Jenkins
 
```
docker run -it --name ubuntu-jenkins -p 8080:8080 -v jenkins-data:/var/lib/jenkins -v "$HOME":/home -v /var/run/docker.sock:/var/run/docker.sock ubuntu-jenkins
```

- Após subir imagem docker acessar Jenkins - localhost:8080  

- Instalar plugins jenkins de git, docker, maven, blueOcean, ansible etc.

- Configurar chave dockerhub em credentials Manager com nome 'user-dockerhub-token'.
  
- Configurar tool docker 
	- name: myDocker

- Configurar tool ansible
	- name: myAnsible
	- Ansible home: /usr/bin
	
- Configurar tool maven 
	- name: maven
	- Maven home: maven /usr/share/maven

  

### Pipeline utilizado:

```

pipeline {
	agent any
	
	environment {
		PROJECT_NAME = 'demo-jenkins-ansible'
		IMAGE_NAME = 'jonathasgarcia/demo-jenkins-ansible'
		GIT_URL_REPO = 'https://github.com/Jonathas-garcia/demo-jenkins-ansible.git'
		DOCKER_HUB_CREDENTIAL = 'user-dockerhub-token'
	}

	stages {
		stage('Setup environment') {
			steps {
				echo "Environment variables"
				echo "PROJECT_NAME = ${PROJECT_NAME}"
				echo "IMAGE_NAME = ${IMAGE_NAME}"
				echo "GIT_URL_REPO = ${GIT_URL_REPO}"
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
					def ansibleHome = tool 'myAnsible'
					env.PATH = "${ansibleHome}:${env.PATH}"
					ansiblePlaybook(playbook:'/var/lib/jenkins/workspace/playbooks/playbook.yml', inventory: '/var/lib/jenkins/workspace/playbooks/hosts', colorized: true)
					//sh "ansible-playbook -vvv /var/lib/jenkins/workspace/playbooks/playbook.yml -i /var/lib/jenkins/workspace/playbooks/hosts"
				}
			}
		}
	}
}

```

  

### Na máquina host 

- Copiar chave SSH. 
	- (/var/lib/jenkins/workspace/playbooks/NOME_DA_CHAVE.pem)
- Copiar arquivos hosts e playbook.yml. 
	- (/var/lib/jenkins/workspace/playbooks)
- Permissão na chave PEM(avaliar outras alternativas).



  
  

### Na máquina destino  

- Configurar docker-compose 

```

apt update

apt install python3 python3-pip

pip3 install docker docker-compose

```

### Arquivo hosts
- Alterar arquivo com os parâmetros corretos.
```
[webservers]
{IP_MAQUINA_DESTINO} ansible_connection=ssh ansible_user={NOME_USUARIO} ansible_ssh_private_key_file={PATH_CHAVE_SSH} ansible_python_interpreter=/usr/bin/python3
```

  ### Arquivo playbook.yml
  - Alterar arquivo com os parâmetros corretos.
  
  ```
  - hosts: webservers
	tasks:
	  - name: Pull docker image
		docker_image:
			name: {NOME_IMAGEM_NO_DOCKERHUB}
			source: pull  
	  - name: Run docker container
		docker_container:
		  name: {NOME_CONTAINER}
		  image: {NOME_IMAGEM_NO_DOCKERHUB}
		  state: started
		  pull: true
		  ports:
		  - "8000:8000"
  ```
  

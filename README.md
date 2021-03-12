
Projeto com dockerfile que sobe imagem ubuntu com jenkins e Ansible instalados(e outras ferramentas), para criar pipeline com deploy em instancia ec2 configurada.


# Passos

### Executando ubunto com Jenkins

- Cria volume jenkins-data

```
docker volume create jenkins-data
```

- Executa container referenciando volume criado para jenkins, home para compartilhar arquivos e docker do host para execução de comandos na esteira.
 
```
docker run -it --name ubuntu-jenkins-ansible -p 8080:8080 -v jenkins-data:/var/lib/jenkins -v ${HOME}:/home -v /var/run/docker.sock:/var/run/docker.sock jonathasgarcia/ubuntu-jenkins
```

- Executar comando para iniciar jenkins

```
sudo service jenkins start
```

- Permissão para utilizar docker do host

```
chmod 777 var/run/docker.sock
```

- Após subir imagem docker acessar Jenkins - localhost:8080  

- Instalar plugins jenkins de docker, maven, blueOcean, ansible etc.

- Configurar chave dockerhub em credentials Manager com nome 'user-dockerhub-token'.
  
- Configurar tool docker 
	- name: docker

- Configurar tool ansible
	- name: ansible
	- Ansible home: /usr/bin
	
- Configurar tool maven 
	- name: maven
	- Maven home: maven /usr/share/maven

- Criar pasta "playbooks" no diretório do workspace do jenkins
	 - var/lib/jenkins/workspace
  

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
					def dockerHome = tool 'docker'
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
					def ansibleHome = tool 'ansible'
					env.PATH = "${ansibleHome}:${env.PATH}"
					ansiblePlaybook(playbook:'/var/lib/jenkins/workspace/playbooks/playbook.yml', inventory: '/var/lib/jenkins/workspace/playbooks/hosts', disableHostKeyChecking: true, colorized: true)
					//sh "ansible-playbook -vvv /var/lib/jenkins/workspace/playbooks/playbook.yml -i /var/lib/jenkins/workspace/playbooks/hosts"
				}
			}
		}
	}
}

```

  

## Na máquina host (rodando jenkins)

- Copiar chave SSH. 
	- (/var/lib/jenkins/workspace/playbooks/NOME_DA_CHAVE.pem)
- Copiar arquivos hosts e playbook.yml. 
	- (/var/lib/jenkins/workspace/playbooks)
- Permissão na chave PEM(avaliar outras alternativas).


### Arquivo *hosts*
- Alterar arquivo com os parâmetros corretos.
	 - **IP_MAQUINA_DESTINO** = IP máquina EC2. Exemplo: 54.237.114.3
	 - **NOME_USUARIO** = Usuário para se conectar a instância EC2. Exemplo: ubuntu
	 - **PATH_CHAVE_SSH** = Path absoluto da chave PEM. Exemplo: /var/lib/jenkins/workspace/playbooks/chave.pem
```
[webservers]
{IP_MAQUINA_DESTINO} ansible_connection=ssh ansible_user={NOME_USUARIO} ansible_ssh_private_key_file={PATH_CHAVE_SSH} ansible_python_interpreter=/usr/bin/python3
```

### Arquivo *playbook.yml*
  - Alterar arquivo com os parâmetros corretos.
	- **NOME_IMAGEM_NO_DOCKERHUB** = tag da imagem no dockerhub. Exemplo: jonathasgarcia/demo-jenkins-ansible  
	- **NOME_CONTAINER** = Nome que será gerado o container.
  - Setar portas utilizadas pela aplicação.
  
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

## Na máquina EC2 (destino)

- Configurar docker-compose 

```
apt update
apt install python3 python3-pip
pip3 install docker docker-compose
```
  

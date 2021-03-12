FROM ubuntu:20.04
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#TESTAR SEM INSTALAR O DOCKER JA QUE REFERENCIA NO RUN E DAR PERMISSAO NO VAR RUN DOCKER.SOCK
#INSTALA DOCKER
RUN apt-get update
RUN apt -qq -y install wget
RUN apt-get -qq -y install curl
RUN apt-get -qq -y install sudo
RUN /usr/bin/curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh


#INSTALA ANSIBLE
RUN sudo apt update
RUN sudo apt -y install ansible

#INSTALA JENKINS
RUN sudo apt -y install openjdk-8-jdk
RUN wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
RUN sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN sudo apt-get update
RUN sudo apt-get -y install jenkins
RUN sudo apt -y install git
RUN sudo apt -y install maven
RUN sudo apt -y install vim

RUN chmod 777 run/systemd/container



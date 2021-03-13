FROM ubuntu:20.04
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#INSTALA UTILITARIOS
RUN apt update
RUN apt -qq -y install wget
RUN apt -qq -y install curl
RUN apt -qq -y install sudo
RUN apt -qq -y install git
RUN apt -qq -y install maven
RUN apt -qq -y install vim
RUN apt -y install openjdk-8-jdk
RUN apt -y install openjdk-11-jdk

#INSTALA DOCKER
RUN /usr/bin/curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh


#INSTALA ANSIBLE
RUN apt -y install ansible

#INSTALA JENKINS
RUN apt-get update && apt-get install -y gnupg
RUN wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
RUN sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt update
RUN apt -y install jenkins

COPY ./hosts /ansible-files/
COPY ./playbook.yml /ansible-files/
COPY ./docker-entrypoint.sh /


ENTRYPOINT ["./docker-entrypoint.sh"]



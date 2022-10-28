FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV USER=jia
ENV PASSWD=pwd
ENV WORKDIR=work

USER root

RUN printf '\n\
deb http://mirrors.163.com/ubuntu/ focal main restricted universe multiverse \n\
deb http://mirrors.163.com/ubuntu/ focal-security main restricted universe multiverse \n\
deb http://mirrors.163.com/ubuntu/ focal-updates main restricted universe multiverse \n\
deb http://mirrors.163.com/ubuntu/ focal-backports main restricted universe multiverse \n' \
> /etc/apt/sources.list

RUN  apt-get clean

RUN apt-get update \
  && apt-get install -y \
    gawk g++ make automake bison flex cmake ninja-build texinfo \
    gperf libtool pkg-config patchutils bc \
    libmpc-dev libisl-dev zlib1g-dev libexpat-dev \
    net-tools tar rsync curl wget openssh-server \
    python3 python3-pip \
    sudo git zsh vim \
  && apt-get clean

RUN useradd --create-home --shell /bin/zsh -m ${USER} && yes ${PASSWD} | passwd ${USER}
RUN echo ${USER}' ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chmod 644 /etc/sudoers

CMD ["/usr/sbin/sshd", "-D"]

RUN rm -rf /var/lib/apt/lists/*

USER ${USER}

RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting z /' ~/.zshrc

RUN mkdir -p /home/${USER}/${WORKDIR}/

RUN mkdir -p /home/${USER}/.ssh && \
#####################################
printf '$YOUR_XXXKING_PUBLIC_KEY' > /home/${USER}/.ssh/authorized_keys
#####################################

WORKDIR /home/${USER}

#Download Download Ubuntu Image
FROM ubuntu:18.04
# Set the Image Maintainer
LABEL maintainer="Aperture Development <webmaster@Aperture-Development.de>"
# Disable interactive questions
ENV DEBIAN_FRONTEND noninteractive
# Install Requirements
RUN apt-get update &&\
    apt-get install --no-install-recommends -y git mysql-client libsqlite3-dev libsmbclient-dev libssh2-1-dev libssh-dev libaio-dev build-essential libmatheval-dev libmagic-dev libgd-dev rsync valgrind-dbg libxml2-dev php-readline cmake ssh curl build-essential python php php-cli php-gd php-imap php-mysql php-curl php-readline default-libmysqlclient-dev libsqlite3-dev libsmbclient-dev libuv-dev ca-certificates
# Check for Repository changes and invalidate the docker cache when there was one
ADD https://api.github.com/repos/FriendUPCloud/friendup/git/refs/heads/master friendup_version.json
ADD https://api.github.com/repos/Aperture-Development/friendup-docker/git/refs/heads/master friendup_docker_version.json
RUN mkdir /friendup && git clone --depth=1 https://github.com/FriendUPCloud/friendup /friendup
# Copy our Entrypoint into the container and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Link libaries fot the build process and build friend
RUN ln /usr/lib/x86_64-linux-gnu/libcrypto.a /friendup/libs-ext/openssl/libcrypto.a &&\
    ln /usr/lib/x86_64-linux-gnu/libssl.a /friendup/libs-ext/openssl/libssl.a
RUN cd /friendup &&\
    make setup &&\
    make compile install

#friendchat dependencies
RUN apt-get update && apt-get install -y libssl1.0-dev && apt-get install -y npm && npm install -g n && n stable
RUN mkdir -p /friendup/build/services/{Presence,FriendChat} ; mkdir -p /friendup/build/resources/webclient/apps/FriendChat && cd /friendup/build/services && git clone --depth=1 https://github.com/FriendSoftwareLabs/presence.git ./Presence && git clone --depth=1 https://github.com/FriendSoftwareLabs/friendchat ./FriendChat && cd Presence && npm install && cd /friendup/build/services/FriendChat; mv server/* .  && npm install && cp -a /friendup/build/services/FriendChat/client/* /friendup/build/resources/webclient/apps/FriendChat/

# Set the entrypoint for the container
ENTRYPOINT ["/entrypoint.sh"]

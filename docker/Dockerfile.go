FROM arris/dev:latest
MAINTAINER Arris Ray <arris.ray@gmail.com>

# Args
ARG GOPATH=${GOPATH}
ARG GOVERSION=1.11.5
ARG GOPLATFORM=linux-amd64
ARG GODEPVERSION=0.5.0
ARG GODELVEVERSION=1.2.0

# Envs
ENV GOPATH=${GOPATH}
ENV PATH="/usr/local/go/bin:${GOPATH}/bin:${PATH}"

RUN mkdir -p ${GOPATH}/bin \
# Install Go
    && cd /tmp \
    && wget -nc https://dl.google.com/go/go${GOVERSION}.${GOPLATFORM}.tar.gz \
        && tar -C /usr/local -xzf go${GOVERSION}.${GOPLATFORM}.tar.gz \
# Install dep
    && wget -nc https://github.com/golang/dep/releases/download/v${GODEPVERSION}/dep-${GOPLATFORM} \
        && cp dep-${GOPLATFORM} ${GOPATH}/bin/dep \
        && chmod +x ${GOPATH}/bin/dep \
# Install delve
    && cd ${GOPATH} \
        && go get -u golang.org/x/tools/... \
        && go get github.com/go-delve/delve/cmd/dlv \
        && cd src/github.com/go-delve/delve \
        && make install \
        && cd /tmp \
# Install migrate
    && go get -u -d github.com/mattes/migrate/cli github.com/go-sql-driver/mysql \
        && go build -tags 'mysql' -o ${GOPATH}/bin/migrate github.com/mattes/migrate/cli 

# Configure project
WORKDIR ${GOPATH}/src/${PROJECT_NS}
EXPOSE 2345 3000

# Run
COPY config/go/.vimrc /root/.vimrc
COPY config/go/supervisord.conf /etc/supervisord.conf
CMD /usr/bin/supervisord -c /etc/supervisord.conf
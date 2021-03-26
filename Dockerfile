FROM alpine:3.13

ENV GLIBC_VER=2.31-r0

## Installing awscliv2
# install glibc compatibility for alpine
RUN apk --no-cache add \
        binutils \
        curl \
        groff \
        less \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
        glibc-i18n-${GLIBC_VER}.apk \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        glibc-*.apk \
    && apk --no-cache del \
        binutils \
        curl \
    && rm -rf /var/cache/apk/*

RUN apk --no-cache add docker \
    && rm -rf /var/cache/apk/*

COPY daemon.json /etc/docker/daemon.json


COPY --from=hashicorp/terraform:0.14.8 /bin/terraform /usr/bin/terraform

RUN apk add --no-cache bash \
	gettext \
	jq \
	curl

ARG CODACY_VERSION=11.15.0
RUN curl -Ls -o codacy-coverage-reporter "https://artifacts.codacy.com/bin/codacy-coverage-reporter/${CODACY_VERSION}/codacy-coverage-reporter-linux" \
    && chmod +x codacy-coverage-reporter \
    && mv codacy-coverage-reporter /usr/local/bin/


ENV USERNAME=pipeline
ENV HOME=/home/$USERNAME

RUN adduser $USERNAME -H $HOME --disabled-password --uid=1001
USER $USERNAME
WORKDIR $HOME

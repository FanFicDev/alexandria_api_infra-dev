FROM python:3.11.6-slim-bookworm

ARG BUILD_DATE
ARG VERSION
ARG USER_UID
ARG USER_GID

LABEL build_version="version:- ${VERSION} build-date:- ${BUILD_DATE} USER_UID:- ${USER_UID} USER_GID:- ${USER_GID}"
LABEL maintainer="iris"

ENV APPNAME="alexandria" UMASK_SET="022"

RUN apt-get update && apt-get -y install gcc libpq-dev libglib2.0-dev

RUN python -m pip install virtualenv

RUN groupadd --gid ${USER_GID} alexandria && \
	useradd --uid ${USER_UID} --gid ${USER_GID} -s /bin/bash -m alexandria && \
	mkdir -p /app/alexandria/ && \
	chown alexandria:alexandria /app/alexandria/

USER alexandria
WORKDIR /app/alexandria/

ENV VIRTUAL_ENV=/app/alexandria/venv
RUN python -m virtualenv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python -m pip install --upgrade pip

WORKDIR /app/alexandria/hermes

ENV OIL_DB_HOST=db OIL_DB_DBNAME=hermes OIL_DB_USER=hermes OIL_DB_PASSWORD=pgpass
ENV FLASK_APP=./alexandria_api.py FLASK_ENV=development

CMD python -m pip install -r ./alexandria_api_requirements.txt && python ./schema.py --init && python -m flask run --host 0.0.0.0


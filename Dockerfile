FROM python:3.9.6-slim-buster

ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} build-date:- ${BUILD_DATE}"
LABEL maintainer="iris"

ENV APPNAME="alexandria" UMASK_SET="022"

RUN apt-get update && apt-get -y install gcc libpq-dev libglib2.0-dev

RUN python -m pip install virtualenv

RUN useradd -ms /bin/bash alexandria && \
	mkdir -p /app/alexandria/ && \
	chown alexandria:alexandria /app/alexandria/

USER alexandria
WORKDIR /app/alexandria/

ENV VIRTUAL_ENV=/app/alexandria/venv
RUN python -m virtualenv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY --chown=alexandria \
	./hermes/alexandria_api_requirements.txt ./requirements.txt

RUN python -m pip install --upgrade pip
RUN python -m pip install -r requirements.txt

COPY --chown=alexandria hermes/ ./

ENV OIL_DB_HOST=db OIL_DB_DBNAME=hermes OIL_DB_USER=hermes OIL_DB_PASSWORD=pgpass

ENV FLASK_APP=alexandria_api.py FLASK_ENV=development
CMD python ./schema.py --init && python -m flask run --host 0.0.0.0


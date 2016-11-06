PYTHON_VERSION=2.7.12
DJANGO_VERSION=1.7.11
HTTPD_VERSION=2.4.23
OPENJDK_VERSION=8-jre

.PSEUDO: all
all: build
	:

.PSEUDO: build
build:
	docker build --tag andydude64/python-django-httpd-openjdk:$(PYTHON_VERSION)-$(DJANGO_VERSION)-$(HTTPD_VERSION)-$(OPENJDK_VERSION) .

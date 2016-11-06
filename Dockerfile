FROM python:2.7
MAINTAINER and_j_rob@yahoo.com

# Combine environment vars
ENV DEBIAN_FRONTEND=noninteractive \
	DJANGO_VERSION=1.7.11 \
	APACHE_VERSION=2.4.10 \
	APACHE_DEBIAN_VERSION=2.4.10-10+deb8u7 \
	APACHE_MOD_WSGI_DEBIAN_VERSION=4.3.0-1 \
	APACHE_CONFDIR=/etc/apache2 \
	APACHE_CONFIG=/etc/apache2/apache2.conf \
	CA_CERTIFICATES_JAVA_VERSION=20140324 \
	JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre \
	OPENJDK_DEBIAN_VERSION=8u111-b14-2~bpo8+1 \
	JAVA_VERSION=8u102 \
	LANG=C.UTF-8

# Combine apt requirements
RUN set -x \
	&& echo 'deb http://deb.debian.org/debian jessie-backports main' \
		> /etc/apt/sources.list.d/jessie-backports.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		apache2="$APACHE_DEBIAN_VERSION" \
		libapache2-mod-wsgi="$APACHE_MOD_WSGI_DEBIAN_VERSION" \
		openjdk-8-jre-headless \
		ca-certificates-java \
		gettext sqlite3 \
		mysql-client libmysqlclient-dev \
		postgresql-client libpq-dev \
	&& rm -r /var/lib/apt/lists/*

# <https://github.com/docker-library/django/blob/master/2.7/Dockerfile>
RUN pip install mysqlclient psycopg2 django=="$DJANGO_VERSION"

# <https://github.com/docker-library/openjdk/blob/master/8-jre/Dockerfile>
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# <https://github.com/docker-library/httpd/blob/master/2.4/Dockerfile>
RUN sed -ri \
	-e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
	-e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
	"$APACHE_CONFIG"

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Don't forget to configure apache2 httpd, and python manage.py collectstatic!

EXPOSE 80
CMD /docker-entrypoint.sh

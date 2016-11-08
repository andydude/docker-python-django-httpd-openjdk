# `Dockerfile` links

* `2.7.12-1.7.11-2.4.23-8-jre` `latest` [(Dockerfile)](https://github.com/andydude/docker-python-django-httpd-openjdk/blob/master/2.7.12-1.7.11-2.4.23-8-jre/Dockerfile)

# Usage instructions

Here are a few tips on using this image to go from 0 to 60 in no time.

## Django instructions

The following shell commands will generate an example Django project (a Python web framework),
if you just want to get started quickly.

```sh
pip install django==1.7.11
django-admin startproject {{ my_project }}
cd {{ my_project }}
django-admin startapp common
```

This requires quite a bit of custom code. If you would rather experiment, 
then follow the Mezzanine instructions instead.

## Mezzanine instructions

The following shell commands will generate an example Mezzanine project (a Django blog framework),
if you want to get started with a blog website, for example.

```sh
pip install mezzanine==4.0.1
mezzanine-project {{ my_project }}
```

## Git instructions

If you are starting a new project, then it should be associated with a git repo for the following Python instructions to work. If you already have a git repo, and have a pip installable project, then you can skip this section.

```sh
git init
git tag 1.0.0
```

## Python instructions

Make sure you have a `setup.cfg` file like so.

```ini
[metadata]
name = {{ my_project }}
```

Make sure you have a `setup.py` file like so.

```python
from setuptools import setup

setup(
    setup_requires=['pbr>=1.9', 'setuptools>=17.1'],
    pbr=True)
```

Make sure you have a `requirements.txt` file like so.

```
Django==1.7.11
Mezzanine==4.0.1
```

and you will need to edit the `{{ my_project }}/settings.py` file like so.

```sh
cat >> {{ my_project }}/{{ my_project }}/local_settings.py <<EOF
ALLOWED_HOSTS = ["*"]
EOF
```

## Apache HTTPD instructions

To use Apache HTTPD effectively, it must be configured, so write a file at the root of your project with the following configuration.

```apacheconf
ServerName localhost
WSGIPythonPath /usr/local/src/{{ my_project }}

<VirtualHost *:80>
    #ServerName {{ my_project }}.{{ my_domain }}
    WSGIPassAuthorization On
    WSGIScriptAlias / /usr/local/src/{{ my_project }}/{{ my_project }}/wsgi.py
    Alias /static/ /usr/local/src/{{ my_project }}/static/
    <Directory /usr/local/src/{{ my_project }}/static>
        Require all granted
    </Directory>
    <Directory /usr/local/src/{{ my_project }}/media>
        Require all granted
    </Directory>
    <Directory /usr/local/src/{{ my_project }}/{{ my_project }}>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>
</VirtualHost>
```

## Docker instructions

Once you have a Django project started, or if want to Dockerize an existing Django project,
then all you need to do is write a `Dockerfile` similar to the following.

```dockerfile
FROM andydude64/python-django-httpd-openjdk:2.7.12-1.7.11-2.4.23-8-jre

ENV APACHE_VHOST=000-default.conf \
	DJANGO_SRCDIR=/usr/local/src \
	DJANGO_SETTINGS_MODULE={{ my_project }}.settings \
	DJANGO_ADMIN_EMAIL=root@localhost \
	DJANGO_ADMIN_USERNAME=admin \
	DJANGO_ADMIN_PASSWORD=admin
    
# Configure Apache HTTPD
COPY {{ my_project }}.apache2.conf \
	/etc/apache2/sites-available/$APACHE_VHOST
RUN rm -f /etc/apache2/sites-enabled/$APACHE_VHOST \
	&& ln -s ../sites-available/$APACHE_VHOST \
		/etc/apache2/sites-enabled/$APACHE_VHOST

# Configure Django and static files
COPY . $DJANGO_SRCDIR/{{ my_project }}
RUN pip install --upgrade pip \
	&& pip install -e $DJANGO_SRCDIR/{{ my_project }} \
	&& python $DJANGO_SRCDIR/{{ my_project }}/manage.py \
		collectstatic --noinput \
	&& python $DJANGO_SRCDIR/{{ my_project }}/manage.py migrate \
	&& python $DJANGO_SRCDIR/{{ my_project }}/manage.py \
		createsuperuser --noinput \
		--email=$DJANGO_ADMIN_EMAIL \
		--username=$DJANGO_ADMIN_USERNAME \
	&& python -c "\
import django; django.setup(); \
from django.contrib.auth.models import User; \
u = User.objects.get(username='$DJANGO_ADMIN_USERNAME'); \
u.set_password('$DJANGO_ADMIN_PASSWORD'); u.save()" \
	&& chown -R www-data:www-data $DJANGO_SRCDIR/{{ my_project }}

EXPOSE 80
CMD ["docker-entrypoint.sh"]
```

After you have added such a `Dockerfile` to the root of your project, then you can run the 
following shell commands to create and start a new container with your project.

```sh
docker build --tag {{ my_hub_repo }}/{{ my_project }}:latest .
docker run -Pit {{ my_hub_repo }}/{{ my_project }}
```

## Makefile instructions

If you would like, it helps to write a `Makefile` with common Docker commands.

```makefile
.PSEUDO: all
all: build
	:

.PSEUDO: build
build:
	docker build --tag {{ my_hub_repo }}/{{ my_project }}:latest .

.PSEUDO: run
run:
	docker run -Pit {{ my_hub_repo }}/{{ my_project }}
```

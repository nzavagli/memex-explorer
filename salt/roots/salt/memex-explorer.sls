/vagrant/source/memex/settings.py:
  file.copy:
    - source: /vagrant/source/memex/settings_files/deploy_settings.py

LOCAL_PATH:
  file.append:
    - name: /home/vagrant/.bashrc
    - text: export PATH="/home/vagrant/miniconda/envs/memex/bin:$PATH"

local_settings_path:
   environ.setenv:
     - name: LOCAL_SETTINGS_PATH
     - value: /vagrant/source/memex/local_settings.py

reset:
  file.absent:
    - name: /vagrant/source/db.sqlite3

migrate:
  cmd.run:
    - name: |
        /home/vagrant/miniconda/envs/memex/bin/python /vagrant/source/manage.py migrate
    - cwd: /home/vagrant
    - user: vagrant
    - require:
        - sls: conda-memex

collectstatic:
  cmd.run:
    - name: |
        echo yes | /home/vagrant/miniconda/envs/memex/bin/python /vagrant/source/manage.py collectstatic
    - cwd: /home/vagrant
    - user: vagrant
    - require:
        - sls: conda-memex

celery:
  cmd.run:
    - name: /home/vagrant/miniconda/envs/memex/bin/celery --detach --loglevel=debug --logfile=/vagrant/source/celeryd.log --workdir="/vagrant/source" -A memex worker
    - cwd: /vagrant/source
    - user: vagrant
    - env:
        - JAVA_HOME: '/usr/lib/jvm/java-7-oracle'
    - unless: "ps -p $(cat /vagrant/source/celeryd.pid)"
    - require:
        - sls: conda-memex

gunicorn:
  cmd.run:
    - name: /home/vagrant/miniconda/envs/memex/bin/gunicorn memex.wsgi:application --name $NAME --workers $NUM_WORKERS --log-level=debug --log-file=/vagrant/gunicorn-log --daemon
    - cwd: /vagrant/source
    - user: vagrant
    - group: vagrant
    - env:
        - DJANGO_WSGI_MODULE: 'memex.wsgi'
        - DJANGO_SETTINGS_MODULE: 'memex.settings'
        - NUM_WORKERS: '3'
        - SOCKFILE: '/tmp/gunicorn_supervisor.sock'
        - DJANGODIR: '/vagrant/source'
        - NAME: 'memex_explorer'
    - require:
        - sls: conda-memex

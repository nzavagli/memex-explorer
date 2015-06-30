docker-config:
  file.managed:
    - name: /etc/default/docker
    - makedirs: True
    - contents: |
        DOCKER_OPTS="-s aufs"
    - require_in:
        - service: docker

docker-repo:
  pkgrepo.managed:
    - humanname: Docker-maintained Package Installation
    - name: deb https://get.docker.com/ubuntu docker main
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9
    - keyserver: keyserver.ubuntu.com
    - require_in:
        - pkg: lxc-docker

old-docker-uninstalled:
  pkg.purged:
    - name: docker.io
    - require_in:
        - pkg: lxc-docker

old-docker-really-purged:
  file.absent:
    - name: /var/lib/docker/devicemapper
    - require_in:
        - pkg: lxc-docker

linux-image-extra-installed:
  pkg.installed:
    - name: linux-image-extra-3.13.0-51-generic
    - require_in:
        - pkg: lxc-docker

docker-installed:
  pkg.latest:
    - installed: [apt-transport-https]
    - name: lxc-docker
    - refresh: True

docker-running:
  service.running:
    - name: docker
    - require:
        - pkg: lxc-docker

docker-py:
  pip.installed:
    - name: docker-py == 0.5.0
    - reload_modules: True

{% from 'seafile/map.jinja' import seafile with context %}

seafile.dependencies:
  pkg.installed:
    - pkgs:
      - expect
      - python
      - python2.7
      - libpython2.7
      - python-setuptools
      - python-imaging
      - python-ldap
      - python-mysqldb
      - python-memcache
      - python-urllib3

{{ seafile.path }}:
  file.directory:
    - user: {{ seafile.user }}
    - group: {{ seafile.user }}
    - dir_mode: 775

seafile.installed:
  file.managed:
    - name: {{ seafile.path }}/installs/seafile-server_{{ seafile.version }}_{{ seafile.architecture }}.tar.gz
    - source: https://download.seadrive.org/seafile-server_{{ seafile.version }}_{{ seafile.architecture }}.tar.gz
    - user: {{ seafile.user }}
    - group: {{ seafile.user }}
    - mode: 644
    - makedirs: True
    - skip_verify: True
    - replace: False
  archive.extracted:
    - name: {{ seafile.path }}/
    - source: {{ seafile.path }}/installs/seafile-server_{{ seafile.version }}_{{ seafile.architecture }}.tar.gz
    - user: {{ seafile.user }}
    - group: {{ seafile.user }}
    - if_missing: {{ seafile.path }}/seafile-server-{{ seafile.version }}/

seafile.setup-helper:
  file.managed:
    - name: {{ seafile.path }}/seafile-server-{{ seafile.version }}/seafile-setup.sh
    - source: salt://seafile/files/seafile-setup.sh
    - user: {{ seafile.user }}
    - group: {{ seafile.user }}
    - mode: 754 
    - template: jinja
    - context:
        config: {{ seafile.config|tojson }}
        dir: {{ seafile.path|tojson }}

seafile.setup:
  cmd.run:
    - name: cd {{ seafile.path }}/seafile-server-{{ seafile.version }}/ && ./setup-seafile-mysql.sh auto -n {{ seafile.config.name }} -i {{ seafile.config.domain }} -d {{ seafile.path }}/seafile-data -e 1 -o {{ seafile.config.mysql.server }} -u {{ seafile.config.mysql.user }} -w {{ seafile.config.mysql.password }} -q % -c ccnet -s seafile -b seahub && ./seafile-setup.sh
    - runas: {{ seafile.user }}
    - unless: "ls {{ seafile.path }}/ccnet"

seafile.service:
  file.managed:
    - name: /etc/systemd/system/seafile.service
    - source: salt://seafile/files/seafile.service
    - user: root
    - group: root
    - mode: 754
    - template: jinja
    - context:
        seafile: {{ seafile|tojson }}

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: seafile.service

  service.running:
    - name: seafile
    - enable: True

seahub.config:
  file.replace:
    - name: {{ seafile.path }}/conf/ccnet.conf
    - pattern: SERVICE_URL = http://{{ seafile.config.domain }}:8000
    - repl: SERVICE_URL = https://{{ seafile.config.domain }}/seafhttp
    - count: 1

seahub.service:
  file.managed:
    - name: /etc/systemd/system/seahub.service
    - source: salt://seafile/files/seahub.service
    - user: root
    - group: root
    - mode: 754
    - template: jinja
    - context:
        seafile: {{ seafile|tojson }}

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: seahub.service

  service.running:
    - name: seahub
    - enable: True
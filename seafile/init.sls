{% from 'seafile/map.jinja' import seafile_settings with context %}

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

{{ seafile_settings.path }}:
  file.directory:
    - user: {{ seafile_settings.user }}
    - group: {{ seafile_settings.user }}
    - dir_mode: 775

seafile.installed:
  file.managed:
    - name: {{ seafile_settings.path }}/installs/seafile-server_{{ seafile_settings.version }}_{{ seafile_settings.architecture }}.tar.gz
    - source: https://download.seadrive.org/seafile-server_{{ seafile_settings.version }}_{{ seafile_settings.architecture }}.tar.gz
    - user: {{ seafile_settings.user }}
    - group: {{ seafile_settings.user }}
    - mode: 644
    - makedirs: True
    - skip_verify: True
    - replace: False
  archive.extracted:
    - name: {{ seafile_settings.path }}/
    - source: {{ seafile_settings.path }}/installs/seafile-server_{{ seafile_settings.version }}_{{ seafile_settings.architecture }}.tar.gz
    - user: {{ seafile_settings.user }}
    - group: {{ seafile_settings.user }}
    - if_missing: {{ seafile_settings.path }}/seafile-server-{{ seafile_settings.version }}/

seafile.setup-helper:
  file.managed:
    - name: {{ seafile_settings.path }}/seafile-server-{{ seafile_settings.version }}/seafile-setup.sh
    - source: salt://seafile/files/seafile-setup.sh
    - user: {{ seafile_settings.user }}
    - group: {{ seafile_settings.user }}
    - mode: 754 
    - template: jinja
    - context:
        config: {{ seafile_settings.config }}
        dir: {{ seafile_settings.path }}

seafile.setup:
  cmd.run:
    - name: cd {{ seafile_settings.path }}/seafile-server-{{ seafile_settings.version }}/ && ./setup-seafile-mysql.sh auto -n {{ seafile_settings.config.name }} -i {{ seafile_settings.config.domain }} -d {{ seafile_settings.path }}/seafile-data -e 1 -o {{ seafile_settings.config.mysql.server }} -u {{ seafile_settings.config.mysql.user }} -w {{ seafile_settings.config.mysql.password }} -q % -c ccnet -s seafile -b seahub && ./seafile-setup.sh
    - runas: {{ seafile_settings.user }}
    - unless: "ls {{ seafile_settings.path }}/ccnet"

seafile.service:
  file.managed:
    - name: /etc/systemd/system/seafile.service
    - source: salt://seafile/files/seafile.service
    - user: root
    - group: root
    - mode: 754
    - template: jinja
    - context:
        seafile: {{ seafile_settings }}

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: seafile.service

  service.running:
    - name: seafile
    - enable: True

seahub.config:
  file.replace:
    - name: {{ seafile_settings.path }}/conf/ccnet.conf
    - pattern: SERVICE_URL = http://{{ seafile_settings.config.domain }}:8000
    - repl: SERVICE_URL = https://{{ seafile_settings.config.domain }}/seafhttp
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
        seafile: {{ seafile_settings }}

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: seahub.service

  service.running:
    - name: seahub
    - enable: True
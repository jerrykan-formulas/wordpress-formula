{% from "wordpress/map.jinja" import map with context %}

{%- set wp_cli_env = salt['pillar.get']('wordpress:cli:env', {}) -%}

include:
  - wordpress.cli

{% for id, site in salt['pillar.get']('wordpress:sites', {}).items() %}
{{ map.docroot }}/{{ id }}:
  file.directory:
    - user: {{ map.www_user }}
    - group: {{ map.www_group }}
    - mode: 755
    - makedirs: True

# This command tells wp-cli to download wordpress
download_wordpress_{{ id }}:
 cmd.run:
  - cwd: {{ map.docroot }}/{{ id }}
  - name: '/usr/local/bin/wp core download --path="{{ map.docroot }}/{{ id }}/"'
  - env: {{ wp_cli_env|json }}
{%- if salt['grains.get']('saltversioninfo') < [2018, 3, 0] %}
  - user: {{ map.www_user }}
{%- else %}
  - runas: {{ map.www_user }}
{%- endif %}
  - unless: test -f {{ map.docroot }}/{{ id }}/wp-config.php

# This command tells wp-cli to create our wp-config.php, DB info needs to be the same as above
configure_{{ id }}:
 cmd.run:
  - name: '/usr/local/bin/wp core config --dbname="{{ site.get('database') }}" --dbuser="{{ site.get('dbuser') }}" --dbpass="{{ site.get('dbpass') }}" --dbhost="{{ site.get('dbhost') }}" --path="{{ map.docroot }}/{{ id }}"'
  - cwd: {{ map.docroot }}/{{ id }}
  - env: {{ wp_cli_env|json }}
{%- if salt['grains.get']('saltversioninfo') < [2018, 3, 0] %}
  - user: {{ map.www_user }}
{%- else %}
  - runas: {{ map.www_user }}
{%- endif %}
  - unless: test -f {{ map.docroot }}/{{ id }}/wp-config.php  

# This command tells wp-cli to install wordpress
install_{{ id }}:
 cmd.run:
  - cwd: {{ map.docroot }}/{{ id }}
  - name: '/usr/local/bin/wp core install --url="{{ site.get('url') }}" --title="{{ site.get('title') }}" --admin_user="{{ site.get('username') }}" --admin_password="{{ site.get('password') }}" --admin_email="{{ site.get('email') }}" --path="{{ map.docroot }}/{{ id }}/"'
  - env: {{ wp_cli_env|json }}
{%- if salt['grains.get']('saltversioninfo') < [2018, 3, 0] %}
  - user: {{ map.www_user }}
{%- else %}
  - runas: {{ map.www_user }}
{%- endif %}
  - unless: /usr/local/bin/wp core is-installed --path="{{ map.docroot }}/{{ id }}"
{% endfor %}

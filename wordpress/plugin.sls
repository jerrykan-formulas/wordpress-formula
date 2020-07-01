{% from "wordpress/map.jinja" import map with context %}
{% for name, site in pillar['wordpress']['sites'].items() %}
  {% if 'plugins' in pillar['wordpress']['sites'][name] %}
    {% for plugin_name in pillar['wordpress']['sites'][name]['plugins'] %}  

configure_plugin_{{ plugin_name }}:
 cmd.run:
  - name: '/usr/local/bin/wp plugin install --activate {{ plugin_name }}'
  - cwd: {{ map.docroot }}/{{ name }}
{%- if salt['grains.get']('saltversioninfo') < [2018, 3, 0] %}
  - user: {{ map.www_user }}
{%- else %}
  - runas: {{ map.www_user }}
{%- endif %}
  - unless: '/usr/local/bin/wp plugin is-installed {{ plugin_name }}'
  

    {% endfor %}
  {% endif %}
{% endfor %}

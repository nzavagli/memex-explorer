import sys
import os

from jinja2 import Template
from jinja2.runtime import Context

from django.core.management.base import BaseCommand, CommandError
from base.models import Container

class Command(BaseCommand):
    help = 'read services.yml and create containers to match it'

    def handle(self, *args, **options):
        example_dict = {'tika': {'docker': {'image': 'continuumio/tika',
            'ports': ['9998']}}, 'elasticsearch':      
                    {'docker': {'image': 'elasticsearch', 'ports':
                ['9200', '9300'], 'volumes':
                ['~/memex-explorer/source/container_volumes/elasticsearch/data:/data']}},
            'kibana': {'docker': {'environment': ['KIBANA_SECURE=false'],
                'image': 'continuumio/kibana', 'ports': ['8080:80'], 'links':
                ['elasticsearch:es']}, 'expose_publicly': {'path': '/kibana',
                    'port': 8080}}}

        Container.create_containers_from_servicedict()
        Container.create_containers()
        Container.map_public_ports()

from celery import shared_task
from base.models import Project
from base.models import Service
from base.models import Container

@shared_task()
def start_containers(project, service_names = ['tika', 'elasticsearch', 'kibana'], **kwargs):
    containers = []
    for service in Service.objects.filter(name__in = service_names).all():
        containers.append(service.create_container_entry(project))
    Container.create_containers()
    Container.map_public_ports()

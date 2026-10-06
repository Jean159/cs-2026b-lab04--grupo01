pip install diagrams
from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.client import Users
from diagrams.onprem.network import Nginx
from diagrams.programming.framework import Django
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.queue import Celery
from diagrams.onprem.network import Internet
from diagrams.generic.device import Mobile
from diagrams.onprem.monitoring import Grafana

graph_attr = {"fontsize": "20", "bgcolor": "white", "pad": "0.3"}
with Diagram("CitaSalud Arequipa - Vista de despliegue", filename="fig_citasalud", show=False,
             direction="LR", graph_attr=graph_attr, outformat="png") as diag:
    usuarios = Users("Pacientes y\nmédicos")
    movil = Mobile("PWA / Web\nen celular")
    with Cluster("Servidor en la nube (VPS)"):
        proxy = Nginx("Nginx\n(HTTPS)")
        with Cluster("Monolito modular"):
            app = Django("Django API\n(5 módulos)")
            worker = Celery("Tareas\nasíncronas")
            cache = Redis("Redis\n(caché + cola)")
            db = PostgreSQL("PostgreSQL")
            mon = Grafana("Monitoreo")
    
    usuarios >> movil >> proxy >> app
    app >> db
    app >> Edge(label="encola") >> cache >> worker
    worker >> Edge(label="notificación", style="dashed") >> Internet("WhatsApp API\n(servicio externo)")
    app >> Edge(style="dotted") >> mon

diag
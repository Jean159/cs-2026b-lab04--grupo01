workspace "CitaSalud Arequipa" "Modelo C4 de la plataforma de gestión y reserva de citas médicas" {

    !identifiers hierarchical

    model {
        paciente = person "Paciente" "Paciente registrado en CitaSalud que consulta disponibilidad y agenda citas médicas."
        admision = person "Personal de Admisión" "Personal de ventanilla que recepciona a los pacientes y valida citas del día."
        medico = person "Médico" "Profesional de salud que visualiza su agenda y registra atenciones médicas."

        cita = softwareSystem "CitaSalud Arequipa" "Permite a pacientes reservar citas médicas, gestionar horarios y coordinar atenciones sin cruce de horarios." {
            pwa = container "Aplicación Web Progresiva" "Interfaz web y móvil para pacientes y personal de admisión; optimizada para conexiones móviles 3G/4G." "React + Vite + Service Worker" "Web Browser"
            api = container "API CitaSalud" "Monolito modular que expone endpoints REST e implementa la lógica de negocio y control de concurrencia." "Python 3.12 / Django REST Framework" {
                auth = component "Módulo Auth y Usuarios" "Gestiona la autenticación, roles, perfiles y validación de DNI." "Django app"
                disponibilidad = component "Módulo Disponibilidad" "Gestiona horarios de médicos, turnos y control atómico de cupos disponibles." "Django app"
                reservas = component "Módulo Reservas" "Coordina la creación de citas, validación de reglas de negocio y transacciones." "Django app"
                cancelaciones = component "Módulo Cancelaciones" "Procesa solicitudes de cancelación y libera cupos en horarios." "Django app"
                notificaciones = component "Módulo Notificaciones" "Implementa el puerto Notificador y encola eventos de mensajería." "Django app"
            }
            worker = container "Worker de Tareas Asíncronas" "Procesa en segundo plano el despacho de notificaciones y recordatorios sin degradar el tiempo de respuesta web." "Celery / Python"
            db = container "Base de Datos" "Almacena usuarios, agendas médicas, cupos, citas y registros de auditoría (un esquema por módulo)." "PostgreSQL 16" "Database"
            cola = container "Cola de Mensajes y Caché" "Broker para encolamiento de tareas Celery y almacenamiento en caché de disponibilidad de turnos." "Redis 7.2" "Queue"
        }

        whatsapp = softwareSystem "WhatsApp Business API" "Plataforma de mensajería externa de Meta para envío de confirmaciones y recordatorios." "Externo"
        reniec = softwareSystem "Servicio Consulta DNI" "Servicio web externo para validar identidad de pacientes y personal médico." "Externo"

        # Relaciones de Nivel 1 (Contexto del Sistema)
        paciente -> cita "Consulta disponibilidad y reserva citas médicas"
        admision -> cita "Registra llegada y valida estado de citas"
        medico -> cita "Consulta agenda de pacientes del día"
        cita -> whatsapp "Envía confirmaciones y recordatorios" "HTTPS/JSON"
        cita -> reniec "Valida identidad mediante DNI" "HTTPS/JSON"

        # Relaciones de Nivel 2 (Contenedores)
        paciente -> cita.pwa "Accede a la plataforma desde su móvil o PC" "HTTPS"
        admision -> cita.pwa "Gestiona atenciones y pacientes en ventanilla" "HTTPS"
        medico -> cita.pwa "Revisa agenda y actualiza estados" "HTTPS"

        cita.pwa -> cita.api "Consume endpoints REST" "HTTPS/JSON (REST)"
        cita.api -> cita.db "Lee y escribe entidades de negocio" "SQL/TCP"
        cita.api -> cita.cola "Encola tareas de notificación y consulta caché" "Redis protocol"
        cita.worker -> cita.cola "Consume tareas encoladas" "Redis protocol"
        cita.worker -> whatsapp "Despacha mensajes de notificación" "HTTPS/JSON"
        cita.api -> reniec "Consulta validez de documento de identidad" "HTTPS/JSON"

        # Relaciones de Nivel 3 (Componentes de la API)
        cita.pwa -> cita.api.auth "Inicia sesión y consulta perfil" "HTTPS/JSON"
        cita.pwa -> cita.api.disponibilidad "Consulta turnos y cupos disponibles" "HTTPS/JSON"
        cita.pwa -> cita.api.reservas "Solicita reserva de cita médica" "HTTPS/JSON"
        cita.pwa -> cita.api.cancelaciones "Solicita cancelación de cita" "HTTPS/JSON"

        cita.api.reservas -> cita.api.disponibilidad "Reserva cupo atómicamente"
        cita.api.reservas -> cita.api.notificaciones "Solicita envío de confirmación"
        cita.api.cancelaciones -> cita.api.disponibilidad "Libera cupo de horario"
        cita.api.cancelaciones -> cita.api.notificaciones "Solicita aviso de cancelación"
        cita.api.auth -> reniec "Verifica DNI de usuario" "HTTPS/JSON"

        cita.api.notificaciones -> cita.cola "Encola mensaje de notificación" "Redis protocol"
        cita.api.auth -> cita.db "Lee y escribe credenciales y perfiles" "SQL"
        cita.api.disponibilidad -> cita.db "Lee y actualiza cupos de horarios" "SQL"
        cita.api.reservas -> cita.db "Persiste registro de cita médica" "SQL"
        cita.api.cancelaciones -> cita.db "Actualiza estado de cita y motivo" "SQL"

        # Despliegue en Producción
        produccion = deploymentEnvironment "Producción" {
            deploymentNode "Dispositivo del Usuario" "" "Smartphone Android/iOS o PC de escritorio" {
                containerInstance cita.pwa
            }
            deploymentNode "Servidor VPS en la Nube" "" "Ubuntu 24.04 LTS, 2 vCPU, 4 GB RAM (DigitalOcean / Linode)" {
                deploymentNode "Docker Compose" "" "Docker Engine 27 / Compose v2" {
                    containerInstance cita.api
                    containerInstance cita.worker
                    containerInstance cita.db
                    containerInstance cita.cola
                }
            }
        }
    }

    views {
        systemContext cita "Contexto" "Nivel 1: Contexto de CitaSalud Arequipa y su entorno de integración." {
            include *
            autolayout lr
        }

        container cita "Contenedores" "Nivel 2: Contenedores que componen CitaSalud Arequipa." {
            include *
            autolayout lr
        }

        component cita.api "Componentes" "Nivel 3: Componentes internos del contenedor API CitaSalud." {
            include *
            autolayout lr
        }

        dynamic cita.api "ReservaCita" "Vista Dinámica: Flujo crítico de reserva concurrente de cita médica." {
            cita.pwa -> cita.api.reservas "1. POST /citas/ (pacienteId, medicoId, fecha)"
            cita.api.reservas -> cita.api.disponibilidad "2. Reserva cupo atómicamente (reservarCupo)"
            cita.api.reservas -> cita.db "3. Inserta registro de cita [RESERVADA]"
            cita.api.reservas -> cita.api.notificaciones "4. Solicita confirmación (enviarConfirmacion)"
            cita.api.notificaciones -> cita.cola "5. Encola tarea asíncrona de notificación"
            cita.worker -> cita.cola "6. Consume tarea pendiente"
            cita.worker -> whatsapp "7. Envía mensaje por WhatsApp al paciente"
            autolayout lr
        }

        deployment cita produccion "Despliegue" "Nivel Despliegue: Infraestructura del entorno de producción MVP." {
            include *
            autolayout lr
        }

        styles {
            element "Person" {
                shape person
                background #08427B
                color #ffffff
            }
            element "Software System" {
                background #1168BD
                color #ffffff
            }
            element "Externo" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438DD5
                color #ffffff
            }
            element "Component" {
                background #85BBF0
                color #000000
            }
            element "Database" {
                shape cylinder
            }
            element "Queue" {
                shape pipe
            }
            element "Web Browser" {
                shape WebBrowser
            }
        }
    }
}

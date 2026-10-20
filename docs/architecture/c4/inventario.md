# Inventario de Elementos del Modelo C4 — CitaSalud Arequipa

El presente inventario consolida todos los elementos que forman parte de la arquitectura del sistema **CitaSalud Arequipa**, trazando su origen hacia las decisiones de diseño arquitectónico (ADR-001 y `drivers.md` del Laboratorio 04) y el diseño detallado orientado a objetos (diagramas UML del Laboratorio 05).

| Elemento | Tipo C4 | Descripción | Origen / Artefacto Previo |
| :--- | :--- | :--- | :--- |
| **Paciente** | Persona | Usuario registrado que consulta médicos, horarios disponibles y reserva citas médicas. | `drivers.md` (Lab 04), HU-01 (Lab 05) |
| **Personal de Admisión** | Persona | Personal administrativo de ventanilla que gestiona la llegada, valida citas y atiende consultas. | `drivers.md` (Lab 04), Actividades (Lab 05) |
| **Médico** | Persona | Profesional de la salud que consulta su agenda de atenciones y registra diagnósticos. | `drivers.md` (Lab 04), Clases E1 (Lab 05) |
| **CitaSalud Arequipa** | Sistema de Software | Plataforma integral que permite la reserva, gestión de turnos médicos y notificaciones clínicas. | Caso CitaSalud Arequipa |
| **WhatsApp Business API** | Sistema Externo | Servicio de mensajería en la nube de Meta para confirmaciones y recordatorios asíncronos. | ADR-001 (Lab 04), Notificador (Lab 05) |
| **Servicio de Consulta DNI (RENIEC)** | Sistema Externo | API gubernamental / externa para verificar la identidad legal del paciente mediante DNI. | `drivers.md` (Lab 04), Tabla 10 Guía 06 |
| **Aplicación Web Progresiva (PWA)** | Contenedor | Frontend móvil y de escritorio con soporte offline básico y navegación optimizada para conexiones móviles. | ADR-001 (Lab 04), PWA/Web (Lab 05) |
| **API CitaSalud** | Contenedor | Backend monolítico modular que implementa la lógica de negocio, reglas de concurrencia y expone REST API. | ADR-001 y `despliegue.py` (Lab 04) |
| **Base de Datos Principal** | Contenedor | Almacén relacional con esquemas lógicos separados para usuarios, horarios, citas y auditoría. | ADR-001 y `despliegue.py` (Lab 04) |
| **Cola de Mensajes y Caché** | Contenedor | Broker de mensajes para Celery y almacenamiento en memoria para disponibilidad de horarios. | ADR-001 y `despliegue.py` (Lab 04) |
| **Worker de Tareas Asíncronas** | Contenedor | Proceso en segundo plano que despacha notificaciones a WhatsApp y gestiona reintentos exponenciales. | ADR-001 y `despliegue.py` (Lab 04) |
| **Módulo Auth y Usuarios** | Componente | Gestión de cuentas, roles (paciente, médico, admisión), sesiones seguras y consulta de DNI. | `paquetes.puml` (Lab 05) |
| **Módulo Disponibilidad** | Componente | Gestión de turnos médicos, horarios y control atómico de cupos con bloqueo optimista/pesimista. | `paquetes.puml` y `Horario` (Lab 05) |
| **Módulo Reservas** | Componente | Lógica de reserva de citas, validación de estados y coordinación transaccional. | `paquetes.puml` y `ServicioCitas` (Lab 05) |
| **Módulo Cancelaciones** | Componente | Reglas de cancelación por paciente o clínica y liberación automática de cupos. | `paquetes.puml` (Lab 05) |
| **Módulo Notificaciones** | Componente | Implementación del puerto abstracto Notificador y encolado de mensajes hacia Redis/Celery. | `paquetes.puml` y `WhatsAppAdapter` (Lab 05) |
| **Flujo Crítico: Reserva de Cita Médica** | Vista Dinámica | Interacción secuencial paso a paso para reservar cupo, persistir la cita y encolar notificación asíncrona. | Diagrama de Secuencia E2 (Lab 05) |

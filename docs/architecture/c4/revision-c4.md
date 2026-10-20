# Auditoría de Calidad del Modelo C4 — CitaSalud Arequipa

Se aplicó la **Lista de Revisión Oficial del Modelo C4** (según `c4model.com/diagrams/checklist`) a las cinco vistas generadas para el sistema CitaSalud Arequipa. Asimismo, se realizó una auditoría complementaria asistida por un modelo de lenguaje (LLM), documentando sus hallazgos y discriminando falsos positivos.

---

## 1. Aplicación de la Lista de Revisión Oficial

| Grupo | Pregunta de la Lista de Revisión | Cumple (Sí/No) | Evidencia en el Modelo |
| :--- | :--- | :---: | :--- |
| **General** | ¿Tiene título claro y descriptivo? | **Sí** | Cada vista posee título formal: *System Context View: CitaSalud Arequipa*, *Container View*, *Component View*, *Dynamic View: ReservaCita*, *Deployment View*. |
| **General** | ¿Se entiende el tipo de diagrama y alcance? | **Sí** | Las descripciones especifican explícitamente el nivel C4 (Nivel 1, Nivel 2, Nivel 3, Dinámico y Despliegue Producción). |
| **General** | ¿Tiene leyenda explicativa? | **Sí** | Se configuró directiva `SHOW_LEGEND()` y bloques `styles { ... }` con formas y colores estandarizados para Person, Container, Component, Database, Queue y Externo. |
| **Elementos** | ¿Cada elemento tiene nombre significativo? | **Sí** | Nombres formales sin ambigüedades: *Paciente*, *Personal de Admisión*, *API CitaSalud*, *Base de Datos*, *Worker de Tareas Asíncronas*. |
| **Elementos** | ¿Cada elemento indica su tipo C4? | **Sí** | Todas las cajas especifican si son `Person`, `Software System`, `Container` o `Component`. |
| **Elementos** | ¿Cada elemento describe su responsabilidad? | **Sí** | Se incluye texto descriptivo claro sobre qué función cumple cada elemento en el negocio. |
| **Elementos** | ¿Los contenedores y componentes indican su tecnología? | **Sí** | *React + Vite*, *Python 3.12 / Django REST Framework*, *PostgreSQL 16*, *Redis 7.2*, *Celery*. |
| **Elementos** | ¿Se evitan nombres de infraestructura como "Docker" en contenedores? | **Sí** | Ningún contenedor se llama Docker o Servidor. Docker Compose aparece estrictamente como nodo en la vista de despliegue. |
| **Relaciones** | ¿Cada flecha tiene una etiqueta que describe su intención? | **Sí** | Flechas con verbos de negocio activos: "Consulta disponibilidad", "Reserva cupo atómicamente", "Encola tarea", "Despacha mensajes". Se evitó el verbo vago "usa". |
| **Relaciones** | ¿La etiqueta coincide con la dirección de la flecha? | **Sí** | En todas las relaciones, el origen invoca la acción sobre el destino. |
| **Relaciones** | ¿Se especifica la tecnología/protocolo en las relaciones técnicas? | **Sí** | Se detallan protocolos explícitos: `HTTPS/JSON (REST)`, `SQL/TCP`, `Redis protocol`, `HTTPS/JSON`. |

---

## 2. Auditoría con Inteligencia Artificial y Detección de Falsos Positivos

Para simular una revisión crítica por pares, se sometió el modelo a un LLM como revisor independiente. A continuación se detallan los hallazgos emitidos y el veredicto del equipo:

| Vista | Hallazgo reportado por la IA | Veredicto del Equipo | Justificación Técnica |
| :--- | :--- | :---: | :--- |
| **Contexto (N1)** | *"La relación entre el Paciente y CitaSalud carece de especificación del protocolo de comunicación (falta HTTPS)"*. | **Falso Positivo Rechazado** | En el Nivel 1 (Contexto del Sistema), el público objetivo incluye usuarios no técnicos y directivos clínicos. La guía oficial de Simon Brown prohíbe explícitamente sobrecargar el contexto con protocolos técnicos en las relaciones con personas; basta con describir la intención del usuario. |
| **Contenedores (N2)** | *"La relación entre la API y la Cola/Caché ('Encola tareas de notificación y consulta caché') contiene dos intenciones en una sola flecha"*. | **Observación Aceptada y Ajustada** | Si bien ambas interacciones comparten el protocolo `Redis protocol`, la duplicidad de intención puede generar confusión. Se clarificó la documentación de la relación para indicar que el módulo de notificaciones encola y el módulo de disponibilidad consulta la caché de horarios. |
| **Componentes (N3)** | *"Existe una presunta dependencia cíclica entre Reservas y Disponibilidad"*. | **Falso Positivo Rechazado** | La IA confundió la interacción transaccional con una dependencia circular de módulos. En nuestro modelo, `Reservas` depende unidireccionalmente de `Disponibilidad` (invoca `reservarCupo()`). `Disponibilidad` no conoce ni depende de `Reservas` ni de citas concretas, respetando la Regla C4 del Lab 05. |
| **Despliegue** | *"No se especifica el dimensionamiento del hardware para la base de datos"*. | **Observación Corregida** | Se añadió en la descripción del nodo VPS las características exactas (`Ubuntu 24.04 LTS, 2 vCPU, 4 GB RAM`), coherente con la restricción presupuestaria de $15-25/mes del MVP en `drivers.md`. |

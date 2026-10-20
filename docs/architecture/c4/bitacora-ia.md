# Bitácora de Interacciones con Inteligencia Artificial (Lab 06)

**Regla de oro del laboratorio:** *La IA propone, el equipo decide y verifica.*

A continuación se registran las interacciones sostenidas con el asistente de IA durante el diseño, validación y documentación de la arquitectura C4 para **CitaSalud Arequipa**.

---

### Interacción 1: Generación del borrador de `workspace.dsl`
* **Fecha:** 14/10/2026
* **Herramienta:** Asistente de IA (Gemini / Claude)
* **Prompt del equipo:**
  > "Actúa como arquitecto de software experto en el modelo C4 y Structurizr DSL. Con base en el siguiente inventario de CitaSalud Arequipa (ADR-001: monolito modular en Django, PostgreSQL 16, Redis y Celery; picos de 5000 pacientes), genera el borrador de workspace.dsl con vistas de contexto, contenedores, componentes, dinámica y despliegue. Usa !identifiers hierarchical y solo tecnologías del ADR."
* **Propuesta de la IA:**
  La IA propuso un workspace completo, pero incluyó un contenedor llamado `"Docker Compose"` dentro de CitaSalud y colocó a `"WhatsApp Business API"` como un contenedor interno de tipo `"Microservicio de Mensajería"`.
* **Verificación del equipo:**
  Se detectó que la IA incurrió en dos errores conceptuales clásicos de C4: confundir contenedor C4 con tecnología de orquestación (Docker Compose es infraestructura) y modelar un servicio SaaS externo como si fuera un contenedor que desarrollamos y desplegamos internamente.
* **Decisión del equipo:**
  **Corregida.** Se reubicó Docker Compose como nodo de ejecución en el deploymentEnvironment y se definió WhatsApp Business API como un `softwareSystem` con etiqueta `"Externo"`.

---

### Interacción 2: Modelado del control de concurrencia en la vista dinámica
* **Fecha:** 15/10/2026
* **Herramienta:** Asistente de IA
* **Prompt del equipo:**
  > "Revisa el flujo dinámico de la HU-01 (Reserva de Cita Médica) para workspace.dsl. Debe reflejar fielmente el diagrama de secuencia del Lab 05, garantizando que el bloqueo de cupos sea atómico y que el envío de confirmación no bloquee la respuesta HTTP al paciente."
* **Propuesta de la IA:**
  La IA propuso que el módulo de Reservas llamara directamente vía HTTPS a WhatsApp Business API en el paso 4 y luego retornara el código 200 OK al paciente.
* **Verificación del equipo:**
  Se verificó que esta propuesta violaba directamente el ADR-001 (Monolito modular con notificaciones asíncronas). Durante el pico matutino de 5,000 pacientes, invocar llamadas síncronas a WhatsApp agotaría los workers de Django debido a la latencia de la API externa (200-800 ms), colapsando el servidor.
* **Decisión del equipo:**
  **Rechazada y Corregida.** Se obligó a la vista dinámica a delegar el mensaje a `notificaciones`, quien encola la tarea en `cola` (Redis) de inmediato (< 5 ms). El worker Celery consume y contacta a WhatsApp de forma completamente asíncrona.

---

### Interacción 3: Auditoría C4 con lista de revisión oficial
* **Fecha:** 15/10/2026
* **Herramienta:** Asistente de IA (Rol de Auditor C4)
* **Prompt del equipo:**
  > "Actúa como revisor de diagramas de arquitectura C4. Evalúa las 5 vistas de CitaSalud con la lista de revisión de c4model.com (generales, elementos, relaciones). Responde en una tabla con hallazgos y correcciones. No inventes problemas donde no los hay."
* **Propuesta de la IA:**
  La IA reportó como falta crítica que las flechas de los actores humanos (Paciente, Admisión, Médico) hacia el sistema en Nivel 1 carecían del protocolo `HTTPS`.
* **Verificación del equipo:**
  Se contrastó con la documentación oficial de Simon Brown en `c4model.com/diagrams/checklist`. En el Nivel 1 de Contexto, los diagramas están orientados a audiencias mixtas (incluyendo usuarios de negocio). Exigir protocolos técnicos a relaciones entre personas y sistemas es considerado mala práctica en C4.
* **Decisión del equipo:**
  **Clasificado como Falso Positivo.** Se desestimó la recomendación para el Nivel 1, manteniéndose únicamente la intención funcional del usuario. Se mantuvieron los protocolos rigurosos para los Niveles 2, 3 y Despliegue.

---

### Interacción 4: Redacción de explicación para stakeholder no técnico
* **Fecha:** 16/10/2026
* **Herramienta:** Asistente de IA
* **Prompt del equipo:**
  > "Explica la arquitectura del sistema CitaSalud al Director Médico de la clínica, quien no es técnico, en máximo 120 palabras. Explica qué hace, quién lo usa y de qué servicios depende. Evita términos como API, Celery, Docker o PostgreSQL."
* **Propuesta de la IA:**
  La IA redactó un texto de 145 palabras que contenía frases como *"arquitectura de monolito modular basada en microservicios asíncronos y contenedores Docker en la nube"*.
* **Verificación del equipo:**
  El texto excedió el límite de palabras (145 > 120) y violó la restricción de evitar jerga técnica incomprensible para un médico o administrador clínico.
* **Decisión del equipo:**
  **Reescrita y Ajustada.** El equipo editó el borrador, depuró la jerga técnica y redujo la extensión a exactamente 112 palabras, enfocándose en el valor clínico: evitar colas, eliminar doble reserva y avisar por WhatsApp.

---

### Interacción 5: Generación de la exportación a Mermaid C4 para GitHub
* **Fecha:** 16/10/2026
* **Herramienta:** Asistente de IA
* **Prompt del equipo:**
  > "Convierte la vista de contenedores de CitaSalud a sintaxis nativa de Mermaid C4Container para que GitHub la renderice automáticamente en el README.md sin requerir extensiones externas."
* **Propuesta de la IA:**
  La IA entregó un bloque `C4Container` pero empleó directivas obsoletas que GitHub Actions no renderiza en Markdown estándar.
* **Verificación del equipo:**
  Se testeó el bloque en el visualizador Mermaid. Se identificó que faltaba la declaración de `System_Boundary` y el cierre correcto de etiquetas.
* **Decisión del equipo:**
  **Corregida.** Se ajustó la sintaxis a la convención estándar soportada por GitHub (`C4Container`, `Person`, `Container`, `ContainerDb`, `ContainerQueue`, `Rel`), verificando su correcta previsualización.

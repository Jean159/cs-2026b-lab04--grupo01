# Bitácora de Uso de Inteligencia Artificial (IA) - CitaSalud Arequipa

Este documento registra las interacciones realizadas con asistentes de IA durante el proceso de diseño arquitectónico del MVP, documentando las propuestas, validaciones, correcciones y rechazos realizados por el equipo de desarrollo.

| N° | Fecha | Herramienta de IA | Resumen del Prompt / Consulta | Propuesta de la IA | Decisión del Equipo (Aceptado / Corregido / Rechazado) | Evidencia de Verificación / Justificación |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **01** | 05/10/2026 | ChatGPT (GPT-4o) | Solicitud de estilos arquitectónicos para "CitaSalud Arequipa" soportando 5000 usuarios concurrentes a las 7:00 a. m. y un plazo de 1 mes[cite: 13, 14, 15]. | Sugirió una arquitectura basada en microservicios puros con Kubernetes y API Gateway descentralizado. | **Rechazado** | El equipo rechazó esta opción porque viola la restricción de tiempo (1 mes de desarrollo) y la simplicidad operativa para un grupo pequeño[cite: 14, 15]. Se optó por un monolito modular con colas. |
| **02** | 05/10/2026 | ChatGPT (GPT-4o) | Prompt para estructurar los escenarios de calidad y los drivers específicos de concurrencia y notificaciones WhatsApp[cite: 13, 15]. | Generó la tabla de escenarios de seis partes y priorización de atributos (Rendimiento, Modificabilidad, Fiabilidad). | **Aceptado (con ajustes)** | Se revisó que los valores del percentil ($p95 \le 3\text{ s}$) y el volumen de usuarios coincidieran exactamente con los requerimientos del Caso 1[cite: 13]. |
| **03** | 05/10/2026 | Claude 3.5 Sonnet | Consulta sobre estrategias para evitar la duplicidad de citas médicas bajo alta concurrencia matutina. | Propuso el uso de bloqueos pesimosos a nivel de base de datos y transacciones serializables o restricciones únicas por horario/médico. | **Aceptado** | Verificado técnicamente: garantiza que ninguna cita sea asignada dos veces a las 7:00 a. m.[cite: 13] sin sobrecargar el servidor principal. |
| **04** | 05/10/2026 | ChatGPT (GPT-4o) | Solicitar una propuesta de criterios y ponderaciones para la matriz de decisión orientada a un MVP de salud. | Asignó pesos a rendimiento (30%), tiempo de entrega (25%), costo/simplicidad (20%), modificabilidad (15%) y fiabilidad (10%). | **Aceptado** | Los pesos reflejan fielmente las restricciones críticas del proyecto (plazo de entrega y el pico matutino)[cite: 13, 14, 15]. |
| **05** | 05/10/2026 | Claude 3.5 Sonnet | Solicitud de diseño de la vista de despliegue usando la librería Python Diagrams[cite: 9, 17]. | Propuso un esquema con Nginx como proxy reverso, un servidor VPS principal para la app, base de datos PostgreSQL y Redis para la cola de WhatsApp. | **Aceptado** | El diseño se ajusta al presupuesto bajo y utiliza un único VPS con componentes bien delimitados[cite: 14]. |

---

## Anexo: Prompts Completos Utilizados

### Prompt 01 (Generación de Alternativas)
> *"Actúa como arquitecto de software senior. Contexto: Plataforma 'CitaSalud Arequipa' para reserva de citas médicas (pacientes, admisión, médicos). Funcionalidades: búsqueda por especialidad, reserva, cancelación, recordatorios por WhatsApp y lista del día para el médico[cite: 13]. Requisito crítico: 5000 pacientes intentan reservar entre 7:00 y 7:15 a. m., p95 $\le$ 3s, cero citas duplicadas[cite: 13]. Restricciones: MVP en 1 mes, equipo pequeño, presupuesto bajo (un VPS)[cite: 14, 15]. Propón 3 alternativas arquitectónicas con fortalezas, debilidades y riesgos."*

### Prompt 02 (Crítica Adversarial)
> *"Actúa como 'abogado del diablo'. Critica duramente la alternativa de microservicios recomendada para CitaSalud Arequipa evaluando el plazo de 1 mes, el pico de las 7:00 a. m. y el bajo presupuesto[cite: 13, 14, 15]. Enumera los 5 riesgos más graves y sus tácticas de mitigación."*
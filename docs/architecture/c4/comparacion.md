# Comparación de Enfoques de Arquitectura: Modelado vs. Diagramación

En este informe comparativo se evalúan dos paradigmas fundamentales para la representación arquitectónica en software: la **diagramación manual independiente** (empleando macros de C4-PlantUML y sintaxis de Mermaid en archivos aislados) frente al **modelado unificado de arquitectura como código** (utilizando Structurizr DSL).

---

## 1. Métricas de Comparación Técnica

| Criterio | Diagramación Manual (C4-PlantUML / Mermaid) | Modelado con Structurizr DSL |
| :--- | :--- | :--- |
| **Tiempo de configuración inicial** | Menor (15-20 min para el primer diagrama suelto). | Moderado (30-40 min para definir el metamodelo unificado). |
| **Tiempo de mantenimiento ante cambios** | Muy alto. Un cambio en un contenedor exige modificar 5 archivos independientes. | Prácticamente instantáneo (O(1)). Se modifica una sola línea en `workspace.dsl` y se regeneran todas las vistas. |
| **Riesgo de inconsistencias y deriva** | Crítico. Es común que el nivel de componentes use nombres o protocolos distintos al nivel de contenedores. | Nulo. La herramienta valida la coherencia entre vistas y rechaza identificadores no definidos. |
| **Soporte de verificación sintáctica** | Limitado al renderizador gráfico (errores de dibujo). | Estricto mediante `structurizr validate` (valida jerarquía, referencias y unicidad). |
| **Integración con decisiones (ADRs)** | Manual y propensa al olvido. | Nativa mediante directivas `!adrs` y `!docs` embebidas en el workspace. |
| **Generación multiplataforma** | Requiere escribir scripts separados para PlantUML y Mermaid. | Exportación automática a C4-PlantUML, Mermaid, DOT, D2 y JSON desde una única fuente de verdad. |

---

## 2. Respuestas a Preguntas Clave del Ejercicio E6

### ¿Qué errores se encontraron en la diagramación manual frente al modelo exportado?
Durante la escritura manual de `contexto-manual.puml`, se cometieron pequeñas discrepancias tipográficas en las descripciones de los actores y se omitió inicialmente la especificación del protocolo `HTTPS/JSON` en la relación hacia RENIEC. En contraste, en `workspace.dsl`, al definir los sistemas externos y contenedores con sus atributos estandarizados una única vez, las exportaciones a C4-PlantUML y Mermaid heredaron las propiedades sin ninguna discrepancia de formato, etiquetas ni direcciones de flechas.

### ¿Qué pasaría si mañana cambia el nombre o tecnología de un contenedor?
* **En el enfoque de diagramación manual**: Si el contenedor `API CitaSalud` migra de versión o cambia su nombre a `CitaSalud Core Service`, el desarrollador debe rastrear y editar manualmente dicho contenedor en el diagrama de contenedores, en el diagrama de componentes, en la vista dinámica y en la vista de despliegue, además de revisar que ningún alias se rompa. Cualquier omisión genera **deriva arquitectónica (architectural drift)**.
* **En Structurizr DSL**: Se actualiza el atributo `name` o `technology` en la definición del contenedor dentro del bloque `model { ... }`. Al ejecutar el comando `./structurizr.sh export`, las 5 vistas (contenedores, componentes, dinámica y despliegue) se sincronizan de forma completamente determinista y libre de error humano.

---

## 3. Comparación entre Secuencia UML y Vista Dinámica C4 (Requisito E4.3)

* **Detalle que muestra la Secuencia UML y que la Dinámica C4 omite**:
  El diagrama de secuencia UML (Lab 05) modela a nivel micro-quirúrgico la signatura exacta de métodos de bajo nivel (`buscarHorario(medicoId, fecha): Horario`, `reservarCupo(): void`), retornos de control síncronos, valores devueltos (`horario`), excepciones (`409 Conflict - Sin cupos`) y bloques condicionales (`alt / else`, `opt`). La vista dinámica de C4 omite los retornos, tipos de datos primitivos y guardas algorítmicas, enfocándose en la interacción de alto nivel entre componentes y contenedores (p. ej. endpoints HTTP, llamadas a servicios de dominio y encolado de mensajes).

* **Público objetivo y cuándo usar cada una**:
  * **Vista Dinámica C4**: Dirigida a arquitectos de software, tech leads y desarrolladores durante discusiones de diseño de alto nivel o revisiones de integración. Permite responder rápidamente: *¿por qué contenedores viaja la petición y dónde se delega el trabajo asíncrono?*
  * **Diagrama de Secuencia UML**: Dirigido a los desarrolladores de backend que implementan el código y escriben pruebas unitarias/de integración. Permite responder: *¿qué métodos específicos deben invocarse en el código, en qué orden exacto y qué excepciones se deben capturar?*

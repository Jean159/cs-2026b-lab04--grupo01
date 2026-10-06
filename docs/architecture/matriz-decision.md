# Matriz de Decisión Arquitectónica - CitaSalud Arequipa

## 1. Alternativas Evaluadas (Propuestas por IA)
* **Alternativa A (Monolito Modular):** Una única aplicación bien estructurada en módulos independientes (Pacientes, Citas, Notificaciones, Médicos) conectada a una base de datos relacional optimizada.
* **Alternativa B (Microservicios):** Servicios distribuidos independientes para cada funcionalidad (servicio de auth, servicio de citas, servicio de WhatsApp), comunicados mediante colas/APIs.
* **Alternativa C (Arquitectura Híbrida / Monolito con Cola Asíncrona):** Monolito robusto para la lógica transaccional de citas y un worker separado (ej. con Redis/Celery) para manejar de forma asíncrona los recordatorios masivos de WhatsApp.

---

## 2. Criterios de Evaluación y Pesos
Se establecen 5 criterios ponderados en función de los drivers del sistema:
1. **Rendimiento y Consistencia bajo Concurrencia (30%):** Capacidad de soportar el pico matutino ($p95 \le 3\text{ s}$) evitando duplicidad de citas.
2. **Tiempo de Entrega / Viabilidad del MVP (25%):** Facilidad de desarrollo para cumplir estrictamente con el plazo de **1 mes**.
3. **Simplicidad Operativa y Costo (20%):** Bajo costo de infraestructura (un único VPS) y facilidad de despliegue.
4. **Modificabilidad (15%):** Facilidad para agregar nuevas especialidades o centros de salud en el futuro.
5. **Fiabilidad en Notificaciones (10%):** Manejo seguro de reintentos ante fallas de la API de WhatsApp.

---

## 3. Matriz de Puntuación (1 al 5)

| Criterio | Peso | Alt. A (Monolito Modular) | Alt. B (Microservicios) | Alt. C (Monolito + Cola Asíncrona) |
| :--- | :---: | :---: | :---: | :---: |
| **Rendimiento / Concurrencia** | 30% | 4 (1.20) | 5 (1.50) | **5 (1.50)** |
| **Tiempo de Entrega (1 mes)** | 25% | 4 (1.00) | 2 (0.50) | **4 (1.00)** |
| **Simplicidad Operativa / Costo** | 20% | 5 (1.00) | 2 (0.40) | **4 (0.80)** |
| **Modificabilidad** | 15% | 3 (0.45) | 5 (0.75) | **4 (0.60)** |
| **Fiabilidad en Notificaciones**| 10% | 3 (0.30) | 4 (0.40) | **5 (0.50)** |
| **PUNTAJE TOTAL** | **100%** | **3.95** | **3.55** | **4.40** |

---

## 4. Justificación y Selección
La alternativa seleccionada es la **Alternativa C (Monolito Híbrido con Cola Asíncrona)**, ya que obtiene el mayor puntaje ponderado (**4.40**). 
* Permite cumplir holgadamente con el plazo de **1 mes** de desarrollo (a diferencia de Microservicios que genera sobrecarga de red y despliegue).
* Resuelve el problema crítico del rendimiento y la concurrencia a las 7:00 a. m. mediante transacciones atómicas a nivel de base de datos y aísla el envío de recordatorios de WhatsApp en un proceso asíncrono para no saturar el flujo principal de reservas.
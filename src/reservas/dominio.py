from __future__ import annotations
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from uuid import UUID, uuid4

class EstadoCita(Enum):
    RESERVADA = "RESERVADA"
    CONFIRMADA = "CONFIRMADA"
    ATENDIDA = "ATENDIDA"
    NO_ASISTIO = "NO_ASISTIO"
    CANCELADA = "CANCELADA"

@dataclass
class Paciente:
    dni: str
    nombres: str
    celular: str
    id: UUID = field(default_factory=uuid4)

@dataclass
class Medico:
    colegiatura: str
    nombres: str
    especialidad: str
    id: UUID = field(default_factory=uuid4)

@dataclass
class Horario:
    medico: Medico
    fechaHora: datetime
    cuposDisponibles: int
    id: UUID = field(default_factory=uuid4)

    def reservarCupo(self) -> None:
        if self.cuposDisponibles <= 0:
            raise ValueError("Sin cupos disponibles")
        self.cuposDisponibles -= 1

    def liberarCupo(self) -> None:
        self.cuposDisponibles += 1

@dataclass
class Cita:
    paciente: Paciente
    horario: Horario
    estado: EstadoCita = EstadoCita.RESERVADA
    id: UUID = field(default_factory=uuid4)
    fechaRegistro: datetime = field(default_factory=datetime.now)

    def confirmarAsistencia(self) -> None:
        self.estado = EstadoCita.CONFIRMADA

    def registrarAtencion(self) -> None:
        self.estado = EstadoCita.ATENDIDA

    def cancelar(self, motivo: str) -> None:
        self.horario.liberarCupo()
        self.estado = EstadoCita.CANCELADA

class Notificador(ABC):
    @abstractmethod
    def enviarConfirmacion(self, cita: Cita) -> None:
        ...

class WhatsAppAdapter(Notificador):
    apiKey: str
    
    def enviarConfirmacion(self, cita: Cita) -> None:
        raise NotImplementedError("Integrar con Celery y API de WhatsApp")
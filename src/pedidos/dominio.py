"""Módulo Pedidos de AgroConecta: esqueleto generado con IA a partir de clases.puml."""
from __future__ import annotations
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from decimal import Decimal
from enum import Enum
from uuid import UUID, uuid4


class EstadoPedido(Enum):
    BORRADOR = "BORRADOR"
    CONFIRMADO = "CONFIRMADO"
    PAGO_PENDIENTE = "PAGO_PENDIENTE"
    PAGADO = "PAGADO"
    EN_PREPARACION = "EN_PREPARACION"
    ENTREGADO = "ENTREGADO"
    CANCELADO = "CANCELADO"


class MedioPago(Enum):
    YAPE = "YAPE"
    PLIN = "PLIN"


@dataclass
class Oferta:
    producto: str
    precio_unitario: Decimal
    stock_disponible: int
    id: UUID = field(default_factory=uuid4)

    def reservar(self, cantidad: int) -> None:
        if cantidad > self.stock_disponible:
            raise ValueError("Stock insuficiente")
        self.stock_disponible -= cantidad

    def liberar(self, cantidad: int) -> None:
        self.stock_disponible += cantidad


@dataclass
class LineaPedido:
    oferta: Oferta
    cantidad: int
    precio_unitario: Decimal

    def subtotal(self) -> Decimal:
        return self.precio_unitario * self.cantidad


@dataclass
class Pago:
    monto: Decimal
    medio: MedioPago
    codigo_operacion: str
    aprobado: bool
    id: UUID = field(default_factory=uuid4)


@dataclass
class Pedido:
    lineas: list[LineaPedido] = field(default_factory=list)
    estado: EstadoPedido = EstadoPedido.BORRADOR
    pago: Pago | None = None
    id: UUID = field(default_factory=uuid4)

    def agregar_linea(self, oferta: Oferta, cantidad: int) -> None:
        self.lineas.append(LineaPedido(oferta, cantidad, oferta.precio_unitario))

    def calcular_total(self) -> Decimal:
        return sum((l.subtotal() for l in self.lineas), Decimal("0"))

    def confirmar(self) -> None:
        for linea in self.lineas:
            linea.oferta.reservar(linea.cantidad)
        self.estado = EstadoPedido.CONFIRMADO

    def registrar_pago(self, pago: Pago) -> None:
        self.pago = pago
        self.estado = EstadoPedido.PAGADO

    def cancelar(self, motivo: str) -> None:
        self.estado = EstadoPedido.CANCELADO


class PasarelaPago(ABC):
    """Puerto hacia el proveedor de pagos (Yape/Plin)."""

    @abstractmethod
    def cobrar(self, monto: Decimal, celular: str) -> Pago: ...


class YapeAdapter(PasarelaPago):
    def cobrar(self, monto: Decimal, celular: str) -> Pago:
        raise NotImplementedError("Integrar con el proveedor de pagos")

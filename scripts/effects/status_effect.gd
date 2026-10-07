extends Resource
class_name StatusEffect

## Clase base conceptual para futuros efectos (AdwareEffect, InvertedControlsEffect...).
## No se instancia todavía en el juego: se añadirá en la Fase 5 cuando
## implementemos las amenazas concretas. Sirve como contrato de referencia:
##
## Cada efecto concreto debería definir:
##   - effect_name: String            -> el identificador usado en StatusEffectManager
##   - default_duration: float        -> duración por defecto en segundos
##   - func apply(player: Node) -> void
##   - func remove(player: Node) -> void

@export var effect_name: String = ""
@export var default_duration: float = 5.0


func apply(_player: Node) -> void:
	push_warning("StatusEffect.apply() no implementado para: %s" % effect_name)


func remove(_player: Node) -> void:
	push_warning("StatusEffect.remove() no implementado para: %s" % effect_name)

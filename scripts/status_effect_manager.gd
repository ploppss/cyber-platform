extends Node
class_name StatusEffectManager

## Gestiona los efectos de estado activos sobre el Player (Adware, Backdoor, etc.).
## Los efectos concretos (AdwareEffect, InvertedControlsEffect...) se añadirán
## en la Fase 5. Este manager solo provee la infraestructura genérica.

signal effect_started(effect_name: String)
signal effect_ended(effect_name: String)

# Diccionario de efectos activos.
# Estructura: { "nombre_efecto": { "duration_left": float, "data": Dictionary } }
var _active_effects: Dictionary = {}


func _physics_process(delta: float) -> void:
	if _active_effects.is_empty():
		return

	# Iteramos sobre una copia de las claves porque podemos borrar entradas
	# mientras recorremos el diccionario.
	for effect_name in _active_effects.keys().duplicate():
		var effect_info: Dictionary = _active_effects[effect_name]

		# duration_left < 0 significa "efecto indefinido" (sin caducidad automática).
		if effect_info["duration_left"] >= 0.0:
			effect_info["duration_left"] -= delta
			if effect_info["duration_left"] <= 0.0:
				remove_effect(effect_name)


## Activa un efecto. Si ya estaba activo, reinicia su duración.
## duration en segundos; usa -1.0 para un efecto sin caducidad automática.
func add_effect(effect_name: String, duration: float = -1.0, data: Dictionary = {}) -> void:
	var already_active := _active_effects.has(effect_name)
	_active_effects[effect_name] = {
		"duration_left": duration,
		"data": data,
	}
	if not already_active:
		effect_started.emit(effect_name)


func remove_effect(effect_name: String) -> void:
	if _active_effects.has(effect_name):
		_active_effects.erase(effect_name)
		effect_ended.emit(effect_name)


func has_effect(effect_name: String) -> bool:
	return _active_effects.has(effect_name)


func get_effect_data(effect_name: String) -> Dictionary:
	if _active_effects.has(effect_name):
		return _active_effects[effect_name]["data"]
	return {}


func get_active_effect_names() -> Array:
	return _active_effects.keys()


func clear_all_effects() -> void:
	for effect_name in _active_effects.keys().duplicate():
		remove_effect(effect_name)

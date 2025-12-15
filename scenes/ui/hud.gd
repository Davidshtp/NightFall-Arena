# hud.gd

extends CanvasLayer

# Referencias a los nodos de UI
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthContainer/HealthBar
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthContainer/HealthLabel
@onready var kills_label: Label = $MarginContainer/VBoxContainer/KillsLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel

func _ready():
	# Añadir al grupo "hud" para que el player pueda encontrarlo
	if not is_in_group("hud"):
		add_to_group("hud")
	
	# Inicializar valores por defecto
	update_health(100, 100)
	update_kills(0)
	update_time(0.0)

func update_health(current: int, maximum: int):
	"""Actualiza la barra de vida y el label con los valores actuales"""
	if not health_bar or not health_label:
		return
	
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "HP: %d/%d" % [current, maximum]
	
	# Cambiar color de la barra según el porcentaje de vida
	var health_percent = float(current) / float(maximum)
	
	if health_percent > 0.6:
		health_bar.modulate = Color(0.2, 1.0, 0.2)  # Verde
	elif health_percent > 0.3:
		health_bar.modulate = Color(1.0, 1.0, 0.2)  # Amarillo
	else:
		health_bar.modulate = Color(1.0, 0.2, 0.2)  # Rojo

func update_kills(count: int):
	"""Actualiza el contador de enemigos eliminados"""
	if not kills_label:
		return
	
	kills_label.text = "Kills: %d" % count

func update_time(seconds: float):
	"""Actualiza el timer de supervivencia en formato MM:SS"""
	if not time_label:
		return
	
	var time_int = int(seconds)
	var minutes = time_int / 60
	var secs = time_int % 60
	time_label.text = "Time: %d:%02d" % [minutes, secs]

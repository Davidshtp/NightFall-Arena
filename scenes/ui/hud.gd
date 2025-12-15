# hud.gd

extends CanvasLayer

# Referencias a los nodos de UI
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthContainer/HealthLabel
@onready var kills_label: Label = $MarginContainer/VBoxContainer/KillsLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel

func _ready():
	print("🎮 HUD _ready() iniciado")
	
	# Añadir al grupo "hud" para que el player pueda encontrarlo
	if not is_in_group("hud"):
		add_to_group("hud")
		print("✅ HUD añadido al grupo 'hud'")
	
	# Inicializar valores por defecto
	update_health(100, 100)
	update_kills(0)
	update_time(0.0)
	
	print("✅ HUD inicializado correctamente")

func update_health(current: int, maximum: int):
	"""Actualiza el label de vida con los valores actuales"""
	if not health_label:
		return
	
	health_label.text = "HP: %d/%d" % [current, maximum]

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

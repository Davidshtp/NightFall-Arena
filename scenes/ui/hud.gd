# hud.gd

extends CanvasLayer

# Referencias a los nodos de UI
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthContainer/HealthLabel
@onready var kills_label: Label = $MarginContainer/VBoxContainer/KillsLabel
@onready var xp_label: Label = $MarginContainer/VBoxContainer/XPLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel

func _ready():
	print("🎮 HUD _ready() iniciado")
	
	# Añadir al grupo "hud" para que el player pueda encontrarlo
	if not is_in_group("hud"):
		add_to_group("hud")
		print("✅ HUD añadido al grupo 'hud'")
	
	# Inicializar valores por defecto
	update_health(100, 100)
	update_kills(0)
	update_xp(0)
	update_time(0.0)
	update_level(1)
	update_xp_bar(0, 70, 1)
	
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

func update_xp(amount: int):
	"""Actualiza el contador de XP"""
	if not xp_label:
		return
	
	xp_label.text = "XP: %d" % amount

func update_xp_bar(current_xp: int, threshold: int, level: int):
	"""Actualiza la barra de XP visual"""
	if xp_bar:
		# Calcular el XP del nivel anterior
		var previous_threshold = 0
		if level > 1:
			var thresholds = [0, 70, 140, 210]
			if level - 1 < thresholds.size():
				previous_threshold = thresholds[level - 1]
		
		# XP relativo al nivel actual
		var xp_in_level = current_xp - previous_threshold
		var xp_needed = threshold - previous_threshold
		
		xp_bar.max_value = xp_needed
		xp_bar.value = min(xp_in_level, xp_needed)
	
	if xp_label:
		xp_label.text = "XP: %d / %d" % [current_xp, threshold]

func update_level(level: int):
	"""Actualiza el nivel mostrado"""
	if level_label:
		level_label.text = "Nivel: %d" % level

func update_time(seconds: float):
	"""Actualiza el timer de supervivencia en formato MM:SS"""
	if not time_label:
		return
	
	var time_int = int(seconds)
	var minutes = int(time_int / 60.0)
	var secs = time_int % 60
	time_label.text = "Time: %d:%02d" % [minutes, secs]

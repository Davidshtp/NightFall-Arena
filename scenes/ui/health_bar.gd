# health_bar.gd

extends ProgressBar

func _ready():
	# Configurar la barra de vida
	max_value = 100
	value = 100
	show_percentage = false

func update_health(current: int, maximum: int):
	"""Actualiza la barra de vida con los valores actuales"""
	max_value = maximum
	value = current
	
	# Cambiar color según la vida restante
	var health_percent = float(current) / float(maximum)
	
	# Verde cuando está saludable, amarillo cuando está a mitad, rojo cuando está bajo
	if health_percent > 0.6:
		modulate = Color(0.2, 1.0, 0.2) # Verde
	elif health_percent > 0.3:
		modulate = Color(1.0, 1.0, 0.2) # Amarillo
	else:
		modulate = Color(1.0, 0.2, 0.2) # Rojo

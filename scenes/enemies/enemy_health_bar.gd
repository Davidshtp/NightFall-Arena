# enemy_health_bar.gd
extends Node2D

var current_health: int = 100
var max_health: int = 100
var bar_width: int = 40
var bar_height: int = 6
var bar_offset_y: int = -30

func _ready():
	z_index = 100  # Renderizar sobre todo

func _draw():
	var bar_position = Vector2(-bar_width / 2, bar_offset_y)
	
	# Fondo negro
	draw_rect(Rect2(bar_position, Vector2(bar_width, bar_height)), Color(0, 0, 0, 0.8))
	
	# Barra de vida con color según porcentaje
	var health_percent = float(current_health) / float(max_health)
	var current_bar_width = bar_width * health_percent
	
	var bar_color: Color
	if health_percent > 0.6:
		bar_color = Color(0.2, 1.0, 0.2)  # Verde
	elif health_percent > 0.3:
		bar_color = Color(1.0, 1.0, 0.2)  # Amarillo
	else:
		bar_color = Color(1.0, 0.2, 0.2)  # Rojo
	
	draw_rect(Rect2(bar_position, Vector2(current_bar_width, bar_height)), bar_color)
	
	# Borde blanco
	draw_rect(Rect2(bar_position, Vector2(bar_width, bar_height)), Color(1, 1, 1, 0.5), false, 1.0)

func update_health(new_health: int, new_max_health: int):
	current_health = new_health
	max_health = new_max_health
	queue_redraw()

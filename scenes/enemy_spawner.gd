# enemy_spawner.gd

extends Node2D

# 🎯 Escenas de Enemigos que vamos a instanciar (Arrastrar desde el Inspector)
@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_radius: float = 800.0 # Distancia para generar enemigos lejos del Player

var player: Node2D

func _ready():
	# Buscamos al Player (asumiendo que está en el grupo "player")
	player = get_tree().get_first_node_in_group("player")

# Esta función se llama cada vez que el SpawnTimer hace timeout
func _on_spawn_timer_timeout():
	if player == null or enemy_scenes.is_empty():
		return
		
	# 1. Seleccionar Enemigo al azar
	# Obtenemos una escena de enemigo al azar del array
	var enemy_scene = enemy_scenes.pick_random() 
	
	# 2. Determinar la posición de aparición fuera de la vista
	var spawn_position = get_random_spawn_position()
	
	# 3. Instanciar y añadir
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = spawn_position

# Calcula una posición aleatoria en un círculo grande alrededor del Player
func get_random_spawn_position() -> Vector2:
	var angle = randf() * TAU # Ángulo aleatorio (0 a 360 grados)
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	
	return player.global_position + offset

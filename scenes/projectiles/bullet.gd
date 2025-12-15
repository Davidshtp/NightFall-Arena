# bullet.gd

extends Area2D

@export var damage_amount: int = 5 # <--- ¡Nuevo! Daño base de la bala
@export var speed: float = 600.0
var direction: Vector2 = Vector2.ZERO

func _process(delta):
	# Es más eficiente manejar el movimiento en _process, pero para un Area2D pequeño
	# es más seguro y limpio usar velocity y move_and_slide si lo hiciéramos en _physics_process.
	# Por ahora, dejémoslo aquí.
	if direction != Vector2.ZERO:
		position += direction * speed * delta

func set_direction(dir: Vector2):
	direction = dir.normalized()

# Nueva función conectada
func _on_body_entered(body):
	# 'body' es el nodo con el que la bala ha chocado.
	# Verificamos si ese nodo pertenece al grupo "enemy".
	if body.is_in_group("enemy"):
		# Llamamos a take_damage y le pasamos la cantidad de daño
		body.take_damage(damage_amount)
		
		# Eliminamos la bala de la escena (solo puede golpear una vez)
		queue_free()

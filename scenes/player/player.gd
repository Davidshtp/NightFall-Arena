extends CharacterBody2D

@export var speed: float = 300.0
@export var fire_rate: float = 0.4
@export var bullet_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: Vector2 = Vector2.RIGHT


func _ready():
	$FireTimer.wait_time = fire_rate

func _on_fire_timer_timeout():
	if bullet_scene == null:
		return
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.set_direction(last_direction)


func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		velocity = direction * speed
		last_direction = direction.normalized()
		animated_sprite.play("run")
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

	move_and_slide()

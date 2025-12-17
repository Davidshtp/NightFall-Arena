# main_menu.gd

extends CanvasLayer

var play_button: Button
var quit_button: Button

func _ready():
	play_button = $Panel/VBoxContainer/ButtonsContainer/PlayButton
	quit_button = $Panel/VBoxContainer/ButtonsContainer/QuitButton
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("🎮 Botón Jugar presionado - Cargando main_scene...")
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")

func _on_quit_pressed():
	print("🚪 Botón Salir presionado - Cerrando juego...")
	get_tree().quit()

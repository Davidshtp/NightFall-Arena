# scenes/ui/pause_menu.gd
extends CanvasLayer

@onready var resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event):
	# No pausar si la pantalla de mejoras está activa
	var upgrade_cards = get_tree().get_first_node_in_group("upgrade_cards")
	if upgrade_cards and upgrade_cards.visible:
		return

	# Permitir hacer click en los botones del menú mientras el juego está pausado
	if get_tree().paused and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mp = get_viewport().get_mouse_position()
		if resume_button and resume_button.get_global_rect().has_point(mp):
			_on_resume_pressed()
			return
		if quit_button and quit_button.get_global_rect().has_point(mp):
			_on_quit_pressed()
			return
	
	# Se eliminó la comprobación de "pause" para evitar el error. Ahora solo funciona con la tecla P.
	if event is InputEventKey and event.keycode == KEY_P and event.pressed and not event.echo:
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused

func _on_resume_pressed():
	toggle_pause()

func _on_quit_pressed():
	get_tree().paused = false # Despausar antes de salir
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

# upgrade_cards.gd - Sistema de cartas de mejora al subir de nivel

extends CanvasLayer

signal upgrade_selected(upgrade_type: String)

# Tipos de mejoras disponibles
const UPGRADE_TRIPLE_SHOT = "triple_shot"
const UPGRADE_SPEED_BOOST = "speed_boost"
const UPGRADE_REGEN = "regeneration"

var available_upgrades = [
	{
		"type": UPGRADE_TRIPLE_SHOT,
		"title": "Disparo Triple",
		"description": "Dispara 2 proyectiles\nadicionales de manera\nconsecutiva.",
		"color": Color(1, 0.5, 0.2),  # Naranja
		"icon": "🔥"
	},
	{
		"type": UPGRADE_SPEED_BOOST,
		"title": "Velocidad +4%",
		"description": "Aumenta la velocidad\nde movimiento del\njugador en un 4%.",
		"color": Color(0.2, 0.8, 1),  # Cyan
		"icon": "⚡"
	},
	{
		"type": UPGRADE_REGEN,
		"title": "Regeneración",
		"description": "Regenera 2 HP cada\n9 segundos si no\nrecibes daño.",
		"color": Color(0.2, 1, 0.4),  # Verde
		"icon": "💚"
	}
]

@onready var cards_container: HBoxContainer = $CenterContainer/VBoxContainer/CardsContainer
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Permitir procesar input incluso cuando el árbol está pausado
	visible = false
	
	# Añadir al grupo para que el player pueda encontrarlo
	if not is_in_group("upgrade_cards"):
		add_to_group("upgrade_cards")
		print("✅ UpgradeCards añadido al grupo")

func show_upgrade_selection():
	visible = true
	get_tree().paused = true
	
	# Limpiar cartas anteriores
	for child in cards_container.get_children():
		child.queue_free()
	
	# Crear las 3 cartas con las mejoras disponibles
	for upgrade in available_upgrades:
		var card = create_card(upgrade)
		cards_container.add_child(card)
	
	# Enfocar el primer botón creado (si existe)
	if cards_container.get_child_count() > 0:
		var first_card = cards_container.get_child(0)
		var first_button = _find_first_button(first_card)
		if first_button:
			first_button.grab_focus()

func create_card(upgrade: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(180, 250)
	
	# Crear estilo del panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	style.border_color = upgrade["color"]
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	card.add_theme_stylebox_override("panel", style)
	
	# Contenedor vertical para el contenido de la carta
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 15)
	card.add_child(vbox)
	
	# Margen interior
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	
	var inner_vbox = VBoxContainer.new()
	inner_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	inner_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(inner_vbox)
	
	# Icono grande
	var icon_label = Label.new()
	icon_label.text = upgrade["icon"]
	icon_label.add_theme_font_size_override("font_size", 48)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner_vbox.add_child(icon_label)
	
	# Título
	var title = Label.new()
	title.text = upgrade["title"]
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", upgrade["color"])
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner_vbox.add_child(title)
	
	# Separador
	var separator = HSeparator.new()
	separator.custom_minimum_size.x = 140
	inner_vbox.add_child(separator)
	
	# Descripción
	var description = Label.new()
	description.text = upgrade["description"]
	description.add_theme_font_size_override("font_size", 12)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD
	inner_vbox.add_child(description)
	
	# Spacer flexible
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner_vbox.add_child(spacer)
	
	# Botón de selección
	var button = Button.new()
	button.text = "Seleccionar"
	button.add_theme_font_size_override("font_size", 14)
	button.custom_minimum_size = Vector2(120, 35)
	# Guardar meta para usar en el input manual
	button.set_meta("upgrade_type", upgrade["type"])
	# Conectar con una lambda para pasar el tipo de mejora (más robusto)
	button.pressed.connect(func(): _on_upgrade_selected(upgrade["type"]))
	inner_vbox.add_child(button)
	
	# Reemplazar vbox con margin
	card.remove_child(vbox)
	vbox.queue_free()
	card.add_child(margin)
	
	# Efectos de hover
	card.mouse_entered.connect(func(): _on_card_hover(card, style, upgrade["color"]))
	card.mouse_exited.connect(func(): _on_card_unhover(card, style, upgrade["color"]))
	
	return card

# Helper: busca recursivamente el primer Button en un subárbol
func _find_first_button(node: Node) -> Button:
	for child in node.get_children():
		if child is Button:
			return child
		var b = _find_first_button(child)
		if b:
			return b
	return null

var _mouse_prev_pressed: bool = false

func _process(_delta):
	# Manejar clicks manualmente para que funcione incluso estando pausado
	if not visible:
		_mouse_prev_pressed = false
		return

	var pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if pressed and not _mouse_prev_pressed:
		var mp = get_viewport().get_mouse_position()
		# Iterar botones y detectar colisiones
		for card in cards_container.get_children():
			var btn = _find_first_button(card)
			if btn and btn.get_global_rect().has_point(mp):
				var up_type = btn.get_meta("upgrade_type")
				if up_type:
					_on_upgrade_selected(up_type)
					break

	_mouse_prev_pressed = pressed

func _on_card_hover(card: PanelContainer, style: StyleBoxFlat, color: Color):
	style.border_color = color.lightened(0.3)
	style.set_border_width_all(4)

func _on_card_unhover(card: PanelContainer, style: StyleBoxFlat, color: Color):
	style.border_color = color
	style.set_border_width_all(3)

func _on_upgrade_selected(upgrade_type: String):
	print("Mejora seleccionada: ", upgrade_type)
	upgrade_selected.emit(upgrade_type)
	visible = false
	get_tree().paused = false

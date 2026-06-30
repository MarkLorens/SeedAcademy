extends Control

# Order matches the player's `forms`: 0 = top, 1 = right, 2 = bottom, 3 = left.
# Built dynamically from the player's forms — see _on_forms_changed().
@export var hover_textures: Array[Texture2D] = []

# Parent radial button drives open/hover state (see radial_button.gd).
@onready var radial_btn := $".."
@onready var idle_state := $IdleState
@onready var active_state := $ActiveState

func _ready() -> void:
	assert(radial_btn, "CRITICAL: Radial button node was not found!")
	assert(idle_state, "CRITICAL: IDLE STATE TextureRect node was not found!")
	assert(active_state, "CRITICAL: ACTIVE STATE TextureRect node was not found")
	
	# Starts off idle
	idle_mode()

	# Build the wheel from the player's forms, and rebuild on every change
	assert(radial_btn.player, "CRITICAL: Player not set on radial button!")
	radial_btn.player.forms_changed.connect(_on_forms_changed)
	
	# Set the wheel	with the first texture
	active_state.texture = radial_btn.player.forms[0].wheel_menu_forms[0]

func _on_forms_changed(forms: Array) -> void:
	hover_textures.clear()
	
	for form in forms[-1].wheel_menu_forms:
		hover_textures.append(form)

func idle_mode() -> void:
	idle_state.visible = true
	active_state.visible = false

func active_mode() -> void:
	active_state.visible = true
	idle_state.visible = false

func _process(_delta: float) -> void:
	var is_open: bool = radial_btn.is_open or radial_btn.open_t > 0.001
	var idx: int = radial_btn.hovered_idx

	if idx >= 0 and idx < hover_textures.size():
		active_mode()
		active_state.texture = hover_textures[idx]
	elif is_open:
		active_mode()
		active_state.texture = hover_textures[0]
	else:
		idle_mode()

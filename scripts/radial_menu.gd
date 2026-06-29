extends Control

# Order matches the player's `forms`: 0 = top, 1 = right, 2 = bottom, 3 = left.
@export var hover_textures: Array[Texture2D] = []
@export var active_texture: Texture2D
@export var idle_texture: Texture2D

# Parent radial button drives open/hover state (see radial_button.gd).
@onready var btn := $".."
@onready var idle_state := $IdleState
@onready var active_state := $ActiveState

func _ready() -> void:
	assert(btn, "CRITICAL: Radial button node was not found!")
	assert(idle_state, "CRITICAL: IDLE STATE TextureRect node was not found!")
	assert(active_state, "CRITICAL: ACTIVE STATE TextureRect node was not found")
	
	# Starts off idle	
	idle_mode()

func idle_mode() -> void:
	idle_state.visible = true
	active_state.visible = false

func active_mode() -> void:
	active_state.visible = true
	idle_state.visible = false

func _process(_delta: float) -> void:
	var is_open: bool = btn.is_open or btn.open_t > 0.001
	var idx: int = btn.hovered_idx

	if idx >= 0 and idx < hover_textures.size():
		active_mode()
		active_state.texture = hover_textures[idx]
	elif is_open:
		active_mode()
	else:
		idle_mode()

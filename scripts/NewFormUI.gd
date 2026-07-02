extends Control
class_name NewFormUI

## Shown when the player reaches a NewFormCheckpoint. Pauses the game, displays
## the unlocked form and its wheel icon, then after a short delay lets the player
## tap/click anywhere to dismiss it and resume play.

const CLOSE_DELAY := 2.0

## Set by the checkpoint before this scene is added to the tree.
var form_data: FormData

@onready var form_rect: TextureRect = $CanvasLayer/Container/NewForm
@onready var wheel_rect: TextureRect = $CanvasLayer/Container/HBoxContainer/NewWheel

var _can_close := false

func _ready() -> void:
	# Keep running while the tree is paused so the timer and input still fire.
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	if form_data:
		form_rect.texture = form_data.form_texture
		if not form_data.wheel_menu_forms.is_empty():
			wheel_rect.texture = form_data.wheel_menu_forms[-1]

	# create_timer's process_always defaults to true, so it counts during pause.
	await get_tree().create_timer(CLOSE_DELAY).timeout
	_can_close = true

func _input(event: InputEvent) -> void:
	if not _can_close:
		return
	var pressed : bool = (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed)
	if pressed:
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		queue_free()

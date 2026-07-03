extends Control

## Pressed effect for the action button. Works with whatever texture the
## current form put on the button, so no per-form "pressed" images are needed.

const PRESSED_TINT := Color(0.7, 0.7, 0.7)
const PRESSED_SCALE := Vector2(0.9, 0.9)

@onready var button: TextureButton = $TextureButton

func _ready() -> void:
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)

func _on_button_down() -> void:
	# Scale around the center of the button, wherever layout put it.
	button.pivot_offset = button.size / 2.0
	button.modulate = PRESSED_TINT
	button.scale = PRESSED_SCALE

func _on_button_up() -> void:
	button.modulate = Color.WHITE
	button.scale = Vector2.ONE

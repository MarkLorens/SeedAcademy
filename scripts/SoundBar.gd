extends Control

## Emitted whenever the user drags the knob to a new value (0.0 - 1.0).
signal value_changed(value: float)

## Label used when printing the value (e.g. "SFX" / "BGM").
@export var bar_label: String = "SFX"

## Current level, 0.0 (empty) to 1.0 (full).
@export_range(0.0, 1.0, 0.01) var value: float = 0.7:
	set(v):
		value = clampf(v, 0.0, 1.0)
		_refresh()

@onready var fill_bar: TextureProgressBar = $FillBar
@onready var knob: TextureRect = $Knob

var _dragging: bool = false

func _ready() -> void:
	# Keep working while the game tree is paused (pause menu is open).
	process_mode = Node.PROCESS_MODE_ALWAYS
	resized.connect(_refresh)
	# Show the bus's current volume, so the slider remembers its position.
	value = AudioManager.get_volume(bar_label)
	_refresh()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_dragging = true
		_set_from_x(get_local_mouse_position().x)
		accept_event()

func _input(event: InputEvent) -> void:
	if not _dragging:
		return
	if event is InputEventMouseMotion:
		_set_from_x(get_local_mouse_position().x)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_dragging = false

func _set_from_x(x: float) -> void:
	var new_value: float = clampf(x / size.x, 0.0, 1.0)
	if is_equal_approx(new_value, value):
		return
	value = new_value
	AudioManager.set_volume(bar_label, value)
	value_changed.emit(value)

func _refresh() -> void:
	if fill_bar == null or knob == null:
		return
	fill_bar.value = value * 100.0
	var kx: float = clampf(value * size.x - knob.size.x * 0.5, 0.0, size.x - knob.size.x)
	knob.position = Vector2(kx, (size.y - knob.size.y) * 0.5)

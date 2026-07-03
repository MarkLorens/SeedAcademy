extends Control
class_name EventUI

signal dialogue_finished

@export var lines: Array[String] = []
@export var pause_game := true

var current_line := 0

@onready var label: Label = $NewGameDialogues/MarginContainer/CardPanel/DialogueLabel
@onready var next_button: Button = $NewGameDialogues/MarginContainer/NextButton

func _ready() -> void:
	# Keep running while the tree is paused so the button stays clickable.
	process_mode = Node.PROCESS_MODE_ALWAYS
	if pause_game:
		get_tree().paused = true
	next_button.pressed.connect(_on_next_pressed)
	if lines.is_empty():
		_finish()
		return
	_show_line()

func _show_line() -> void:
	label.text = lines[current_line]

func _on_next_pressed() -> void:
	current_line += 1
	if current_line >= lines.size():
		_finish()
	else:
		_show_line()

func _finish() -> void:
	if pause_game:
		get_tree().paused = false
	dialogue_finished.emit()
	queue_free()

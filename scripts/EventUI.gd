extends Control
class_name EventUI

signal dialogue_finished

@export var lines: Array[String] = []
var current_line := 0

@onready var label: Label = $NewGameDialogues/MarginContainer/DialogueLabel
@onready var next_button: Button = $NewGameDialogues/MarginContainer/NextButton

func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)
	_show_line()

func _show_line() -> void:
	label.text = lines[current_line]

func _on_next_pressed() -> void:
	current_line += 1
	if current_line >= lines.size():
		dialogue_finished.emit()
		queue_free()
	else:
		_show_line()

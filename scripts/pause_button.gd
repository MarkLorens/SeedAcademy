extends Control

func _ready() -> void:
	AudioManager.wire_buttons(self)

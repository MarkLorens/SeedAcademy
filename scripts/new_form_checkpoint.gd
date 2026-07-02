extends Area2D

@export var form_to_grant: FormData
@export var form_texture: Texture
@export var new_form_ui_scene: PackedScene = preload("res://ui/NewFormUI.tscn")
@onready var sprite: Sprite2D = $Sprite2D

var _used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite.texture = form_texture

func _on_body_entered(body) -> void:
	if _used or not body.is_in_group("player"):
		return
	_used = true
	body.unlock_form(form_to_grant)

	# NewFormUI pauses the game itself and resumes when dismissed.
	var ui: NewFormUI = new_form_ui_scene.instantiate()
	ui.form_data = form_to_grant
	get_tree().current_scene.add_child(ui)

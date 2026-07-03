extends Area2D

@export var form_to_grant: FormData
@export var form_texture: Texture
@export var new_form_ui_scene: PackedScene = preload("res://ui/NewFormUI.tscn")
@onready var sprite: Sprite2D = $Sprite2D

# Whether the intro UI has already played this session. Survives death respawns
# (the node persists), so re-acquiring the form after dying grants it silently.
var _ui_shown := false

func _ready() -> void:
	# Fallback if didnt change texture
	$Sprite2D.texture = form_to_grant.form_texture

	body_entered.connect(_on_body_entered)
	sprite.texture = form_texture

func _on_body_entered(body) -> void:
	if not body.is_in_group("player"):
		return
	# Re-grantable: unlock_form is a no-op if the player already owns the form,
	# so this can re-award it after a death dropped it.
	body.unlock_form(form_to_grant)

	# Only introduce the form the first time it's acquired this session.
	if _ui_shown:
		return
	_ui_shown = true

	# NewFormUI pauses the game itself and resumes when dismissed.
	var ui: NewFormUI = new_form_ui_scene.instantiate()
	ui.form_data = form_to_grant
	get_tree().current_scene.add_child(ui)

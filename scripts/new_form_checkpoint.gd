extends Area2D

@export var form_to_grant: FormData
@export var form_texture: Texture
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite.texture = form_texture

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		body.unlock_form(form_to_grant)

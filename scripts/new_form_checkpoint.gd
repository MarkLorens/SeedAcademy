extends Area2D

@export var form_to_grant: FormData

func _ready() -> void:
	# Fallback if didnt change texture	
	$Sprite2D.texture = form_to_grant.form_texture
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		get_tree().paused = true
		body.unlock_form(form_to_grant)
		await body.get_tree().create_timer(4.0).timeout
		get_tree().paused = false
		queue_free()

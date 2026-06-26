extends Area2D

@export var form_to_grant: FormData

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		get_tree().paused = true
		body.unlock_form(form_to_grant)
		get_tree().paused = false
		queue_free()

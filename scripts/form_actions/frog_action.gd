extends FormAction
class_name FrogAction

func execute(player: CharacterBody2D, form: FormData) -> void:
	if player.is_on_floor():
		player.velocity.y = form.jump_speed

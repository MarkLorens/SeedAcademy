extends FormAction
class_name FalconAction

func execute(player: CharacterBody2D, form: FormData) -> void:
	player.velocity.y = form.jump_speed

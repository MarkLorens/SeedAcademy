extends FormAction
class_name HumanAction

func execute(player: CharacterBody2D, _form: FormData) -> void:
	player.start_dash()

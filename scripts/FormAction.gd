extends Resource
class_name FormAction

func execute(_player: CharacterBody2D, _form: FormData) -> void:
	pass

func on_press(player: CharacterBody2D, form: FormData) -> void:
	execute(player, form)

func on_release(_player: CharacterBody2D, _form: FormData, _charge_ratio: float) -> void:
	pass

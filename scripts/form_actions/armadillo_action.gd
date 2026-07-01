extends FormAction
class_name ArmadilloAction

func on_press(player: CharacterBody2D, _form: FormData) -> void:
	player.is_shielded = true

func on_release(player: CharacterBody2D, _form: FormData, _charge_ratio: float) -> void:
	player.is_shielded = false

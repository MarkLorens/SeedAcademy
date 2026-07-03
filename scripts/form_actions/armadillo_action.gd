extends FormAction
class_name ArmadilloAction

func on_press(player: CharacterBody2D, _form: FormData) -> void:
	player.is_shielded = true
	player.show_ability_sprite()

func on_release(player: CharacterBody2D, _form: FormData, _charge_ratio: float) -> void:
	player.is_shielded = false
	player.show_walk_sprite()

extends FormAction
class_name ArmadilloAction

func on_press(player: CharacterBody2D, _form: FormData) -> void:
	player.get_node("ShieldCol").monitoring = true
	player.get_node("ShieldCol").monitorable = true

func on_release(player: CharacterBody2D, _form: FormData, _charge_ratio: float) -> void:
	player.get_node("ShieldCol").monitoring = false
	player.get_node("ShieldCol").monitorable = false

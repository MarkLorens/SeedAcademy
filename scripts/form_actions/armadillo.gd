extends FormAction
class_name ArmadilloAction

func execute(player: CharacterBody2D, _form: FormData) -> void:
	player.get_node("ShieldCol").monitoring = true
	player.get_node("ShieldCol").monitorable = true
	await player.get_tree().create_timer(1.0).timeout
	player.get_node("ShieldCol").monitoring = false
	player.get_node("ShieldCol").monitorable = false

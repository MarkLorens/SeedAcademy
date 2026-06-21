extends FormAction
class_name ApeAction

func execute(player: CharacterBody2D, _form: FormData) -> void:
	player.get_node("AttackCol").show()
	await player.get_tree().create_timer(1.0).timeout
	player.get_node("AttackCol").hide()

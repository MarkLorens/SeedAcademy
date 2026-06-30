extends FormAction
class_name ApeAction

func execute(player: CharacterBody2D, _form: FormData) -> void:
	print("ApeAction.execute -> attack window open")  # TEMP debug
	var hitbox := player.get_node("AttackHitbox")
	hitbox.monitoring = true
	await player.get_tree().create_timer(1.0).timeout
	hitbox.monitoring = false

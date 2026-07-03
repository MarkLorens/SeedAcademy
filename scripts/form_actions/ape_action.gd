extends FormAction
class_name ApeAction

func execute(player: CharacterBody2D, _form: FormData) -> void:
	var hitbox := player.get_node("AttackHitbox")
	hitbox.monitoring = true
	player.show_ability_sprite()
	await player.get_tree().create_timer(0.2).timeout
	hitbox.monitoring = false
	player.show_walk_sprite()

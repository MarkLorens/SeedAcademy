extends FormAction
class_name FrogAction

# Override on_press to do nothing — Frog doesn't jump on press, only on release.
func on_press(_player: CharacterBody2D, _form: FormData) -> void:
	pass

func on_release(player: CharacterBody2D, form: FormData, charge_ratio: float) -> void:
	if player.is_on_floor():
		player.velocity.y = lerp(form.min_jump_speed, form.jump_speed, charge_ratio)

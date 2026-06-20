extends CharacterBody2D

const GRAVITY: int = 4200
const JUMP_SPEED: int = -1800

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if Input.is_action_pressed("ui_accept"):
			velocity.y = JUMP_SPEED
	move_and_slide()

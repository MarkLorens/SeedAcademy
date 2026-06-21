extends CharacterBody2D

const GRAVITY: int = 4200
const JUMP_SPEED: int = -1800
var max_jump_height: float = 0.0

# Forms
enum Form {
	HUMAN,
	APE,
	FALCON
}
var current_form: Form = Form.HUMAN

func _ready() -> void:
	$AttackCol.hide()

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		match current_form:
			Form.HUMAN:
				human_action()
			Form.APE:
				ape_action()
			Form.FALCON:
				falcon_action()
	move_and_slide()

func human_action() -> void:
	if is_on_floor():
		velocity.y = JUMP_SPEED

func ape_action() -> void:
	$AttackCol.show()
	await get_tree().create_timer(1.0).timeout
	$AttackCol.hide()

func falcon_action() -> void:
	velocity.y = JUMP_SPEED

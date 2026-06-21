extends CharacterBody2D

const GRAVITY: int = 4200

@export var forms: Array[FormData] = []
var current_form_index: int = 0
var current_form: FormData

func _ready() -> void:
	$AttackCol.hide()
	set_form(2)

func set_form(index: int) -> void:
	current_form_index = index
	current_form = forms[index]
	$Sprite2D.texture = current_form.form_texture

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * current_form.gravity_scale * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		current_form.action_script.execute(self, current_form)
	
	
	
	move_and_slide()

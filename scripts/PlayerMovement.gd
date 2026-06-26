extends CharacterBody2D

const GRAVITY: int = 4200

# UI
@onready var radial_button: Control = $"../LevelUI/CanvasLayer/MarginContainer/RadialButton"
@onready var action_button: TextureButton = $"../LevelUI/CanvasLayer/MarginContainer2/ActionButton/TextureButton"
# Forms
@export var forms: Array[FormData] = []
var current_form_index: int = 0
var current_form: FormData
# Dash
@export var dash_speed: float = 1000.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.8
var is_dashing := false
var can_dash := true
var dash_timer := 0.0
var cooldown_timer := 0.0

func _ready() -> void:
	add_to_group("player")
	$AttackCol.disabled = true
	$ShieldCol.monitoring = false
	$ShieldCol.monitorable = false
	set_form(0)
	
	assert(radial_button, "CRITICAL: Radial button node was not found!")
	radial_button.character_selected.connect(_on_form_selected)
	
	assert(action_button, "CRITICAL: Action button node was not found!")
	action_button.pressed.connect(action_pressed)

# Fired by the radial menu when a slice is chosen on release.
func _on_form_selected(index: int) -> void:
	if index >= 0 and index < self.forms.size():
		self.set_form(index)

# Fired by action button
func action_pressed() -> void:
	self.current_form.action_script.execute(self, self.current_form)
	
func set_form(index: int) -> void:
	current_form_index = index
	current_form = forms[index]
	$Sprite2D.texture = current_form.form_texture

func _physics_process(delta: float) -> void:
	_update_dash_timers(delta)
	
	if is_dashing:
		velocity.x = dash_speed
	else:
		velocity.x = current_form.run_speed
		velocity.y += GRAVITY * current_form.gravity_scale * delta
	
	move_and_slide()

func _update_dash_timers(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			velocity.y = 0.0
	if not can_dash:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			can_dash = true

func start_dash() -> void:
	if not can_dash or is_dashing:
		return
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	cooldown_timer = dash_cooldown
	velocity.y = 0.0

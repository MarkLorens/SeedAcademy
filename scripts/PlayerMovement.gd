extends CharacterBody2D

const GRAVITY: int = 6725

# UI
@onready var radial_button: Control = $"../LevelUI/CanvasLayer/RadialMargin/RadialButton"
@onready var action_button: TextureButton = $"../LevelUI/CanvasLayer/ActionMargin/ActionButton/TextureButton"
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var charge_bar: ChargeBar = $ChargeBar
@onready var sprite: AnimatedSprite2D = $Sprite2D

# Forms
@export var forms: Array[FormData] = []
var current_form_index: int = 0
var current_form: FormData

# Emitted whenever the set of available forms changes (initial setup + unlocks).
# The radial menu listens to this to (re)build its wheel.
signal forms_changed(forms: Array[FormData])

# Dash
@export var dash_speed: float = 1000.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.8
var is_dashing := false
var can_dash := true
var dash_timer := 0.0
var cooldown_timer := 0.0

# Input monitor
@export var max_charge_time: float = 0.6
var is_charging := false
var charge_time := 0.0
# Event Handler
var can_move := false
var is_shielded := false

func _ready() -> void:
	add_to_group("player")
	attack_hitbox.monitoring = false
	attack_hitbox.body_shape_entered.connect(_on_attack_hit)
	$ShieldCol.monitoring = false
	$ShieldCol.monitorable = false
	set_form(0)
	
	assert(radial_button, "CRITICAL: Radial button node was not found!")
	radial_button.character_selected.connect(_on_form_selected)
	
	assert(action_button, "CRITICAL: Action button node was not found!")
	action_button.button_down.connect(_on_action_down)
	action_button.button_up.connect(_on_action_up)

	# Tell the wheel about the starting forms. Deferred so it fires after every
	# node's _ready has run, regardless of tree order.
	forms_changed.emit.call_deferred(forms)

func _process(delta: float) -> void:
	if is_charging:
		charge_time = min(charge_time + delta, max_charge_time)
		if charge_bar.visible:
			charge_bar.set_ratio(charge_time / max_charge_time)

func _on_action_down() -> void:
	if not can_move:
		return
	is_charging = true
	charge_time = 0.0
	# Frog is the only form that charges its action; show the charge bar for it.
	if current_form.action_script is FrogAction:
		charge_bar.set_ratio(0.0)
		charge_bar.visible = true
	current_form.action_script.on_press(self, current_form)

func _on_action_up() -> void:
	if not can_move:
		return
	is_charging = false
	charge_bar.visible = false
	
	var charge_ratio: float = charge_time / max_charge_time
	current_form.action_script.on_release(self, current_form, charge_ratio)

# Fired by the radial menu when a slice is chosen on release.
func _on_form_selected(index: int) -> void:
	if index >= 0 and index < self.forms.size():
		self.set_form(index)

# Fired by action button
func action_pressed() -> void:
	if not can_move:
		return
	self.current_form.action_script.execute(self, self.current_form)
	
func set_form(index: int) -> void:
	current_form_index = index
	current_form = forms[index]
	_build_walk_animation(current_form)

	action_button.texture_normal = current_form.action_button

	# No sound for the initial form applied during _ready.
	if is_node_ready():
		AudioManager.play_transform(current_form.form_name)

# Build "walk" and "ability" animations from the form's frames. Forms with no
# walk_frames fall back to a single-frame animation of their static
# form_texture; forms with no ability_frames simply have no "ability" animation.
func _build_walk_animation(form: FormData) -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("walk")
	frames.set_animation_loop("walk", true)
	frames.set_animation_speed("walk", form.walk_fps)
	if form.walk_frames.is_empty():
		if form.form_texture != null:
			frames.add_frame("walk", form.form_texture)
	else:
		for tex in form.walk_frames:
			frames.add_frame("walk", tex)
	if not form.ability_frames.is_empty():
		frames.add_animation("ability")
		frames.set_animation_loop("ability", true)
		frames.set_animation_speed("ability", form.ability_fps)
		for tex in form.ability_frames:
			frames.add_frame("ability", tex)
	sprite.sprite_frames = frames
	sprite.play("walk")

# Swap to the form's ability sprite while its action is active.
# Forms without ability frames (e.g. frog) keep their walk sprite.
func show_ability_sprite() -> void:
	if sprite.sprite_frames.has_animation("ability"):
		sprite.play("ability")

func show_walk_sprite() -> void:
	sprite.play("walk")

func _physics_process(delta: float) -> void:
	_update_dash_timers(delta)

	sprite.speed_scale = 1.0 if can_move else 0.0

	if not can_move:
		velocity = Vector2.ZERO
		return
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
			show_walk_sprite()
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
	show_ability_sprite()
	AudioManager.play_sfx(AudioManager.SFX_DASH)

func unlock_form(new_form: FormData) -> void:
	if new_form in forms:
		return
		
	forms.append(new_form)
	forms_changed.emit(forms)

func _on_attack_hit(_body_rid: RID, body: Node, _body_shape: int, _local_shape: int) -> void:
	if not body.has_method("break_in_global_rect"):
		return
	body.break_in_global_rect(_attack_world_rect())

# World-space AABB of the attack hitbox, used to find which tile was hit.
func _attack_world_rect() -> Rect2:
	var col: CollisionShape2D = attack_hitbox.get_node("CollisionShape2D")
	var size: Vector2 = (col.shape as RectangleShape2D).size
	var xform: Transform2D = col.global_transform
	var rect := Rect2(xform * (-size * 0.5), Vector2.ZERO)
	rect = rect.expand(xform * Vector2(size.x * 0.5, -size.y * 0.5))
	rect = rect.expand(xform * (size * 0.5))
	rect = rect.expand(xform * Vector2(-size.x * 0.5, size.y * 0.5))
	return rect

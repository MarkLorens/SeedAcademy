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
# The starting forms, captured on _ready so death can revert mid-level unlocks.
var _initial_forms: Array[FormData] = []
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
# True while an ability/dash sprite is being shown, so the air animation doesn't
# override it.
var _ability_active := false

func _ready() -> void:
	add_to_group("player")
	attack_hitbox.monitoring = false
	attack_hitbox.body_shape_entered.connect(_on_attack_hit)
	$ShieldCol.monitoring = false
	$ShieldCol.monitorable = false
	# Remember the starting forms so mid-level unlocks can be dropped on death.
	_initial_forms = forms.duplicate()
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

# Build "walk", plus optional "ability"/"jump"/"falling" animations from the
# form's frames. Forms with no walk_frames fall back to a single-frame animation
# of their static form_texture; optional animations are skipped when their frame
# list is empty.
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
	_add_optional_anim(frames, "ability", form.ability_frames, form.ability_fps)
	_add_optional_anim(frames, "jump", form.jump_frames, form.jump_fps)
	_add_optional_anim(frames, "falling", form.falling_frames, form.falling_fps)
	sprite.sprite_frames = frames
	sprite.play("walk")

func _add_optional_anim(frames: SpriteFrames, anim: String, textures: Array[Texture2D], fps: float) -> void:
	if textures.is_empty():
		return
	frames.add_animation(anim)
	frames.set_animation_loop(anim, true)
	frames.set_animation_speed(anim, fps)
	for tex in textures:
		frames.add_frame(anim, tex)

# Picks walk / jump / falling from the current physics state. Rising uses the
# "jump" sprite, any other airborne state uses "falling" (covers ledge falls);
# forms without those frames just keep walking. Skipped while an ability or dash
# controls the sprite explicitly.
func _update_air_animation() -> void:
	if is_dashing or _ability_active:
		return
	var frames := sprite.sprite_frames
	if not is_on_floor():
		if velocity.y < 0.0 and frames.has_animation("jump"):
			_play_anim("jump")
		elif frames.has_animation("falling"):
			_play_anim("falling")
		else:
			_play_anim("walk")
	else:
		_play_anim("walk")

func _play_anim(anim: String) -> void:
	if sprite.animation != anim:
		sprite.play(anim)

# Swap to the form's ability sprite while its action is active.
# Forms without ability frames (e.g. frog) keep their walk sprite.
func show_ability_sprite() -> void:
	_ability_active = true
	if sprite.sprite_frames.has_animation("ability"):
		sprite.play("ability")

func show_walk_sprite() -> void:
	_ability_active = false
	_update_air_animation()

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
	_update_air_animation()

	_check_lethal_wall()

# Running face-first into a wall is lethal, but only for BreakableLayer tiles or
# PlatformLayer tiles flagged `deadly` in the TileSet. We only test near-vertical
# faces opposing movement, so running up ramps (diagonal normal) and standing on
# top of tiles (upward normal) are always safe regardless of the flag.
func _check_lethal_wall() -> void:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var normal := col.get_normal()
		if normal.x > -0.9 or absf(normal.y) > 0.35:
			continue  # not a vertical wall facing against us
		var collider = col.get_collider()
		if collider is BreakableTileLayer:
			_die()  # the whole breakable layer is lethal
			return
		if collider is TileMapLayer:
			# Sample the tile just inside the surface and read its custom data.
			var point: Vector2 = col.get_position() - normal * 4.0
			var cell: Vector2i = collider.local_to_map(collider.to_local(point))
			var data: TileData = collider.get_cell_tile_data(cell)
			if data and data.get_custom_data("deadly"):
				_die()
				return

func _die() -> void:
	var level := get_tree().get_first_node_in_group("level_manager")
	if level and level.has_method("player_died"):
		level.player_died()

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

## Drop any mid-level unlocks and return to the level's starting forms.
## Called by the level manager when the player respawns after dying.
func reset_forms() -> void:
	forms = _initial_forms.duplicate()
	current_form_index = 0
	set_form(0)
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

extends Node2D

## Ceiling-mounted crusher. It rests idle (retracted, pole hidden) until the
## player enters one of its trigger zones, then performs a single slam cycle
## (down then back up). The single crusher PNG is split into a fixed "Pole"
## (revealed as the head drops) and a moving "Head" that carries the collision.
##
## WarningZone: placed further along the approach, it makes the crusher slam early
##   so the player learns it is a slamming hazard.
## SlamZone: placed close to the crusher, it triggers the slam the player must
##   dash through (walking is too slow to clear it).

## Downward (slam) speed in pixels per second.
@export var down_velocity: float = 1200.0
## Upward (retract) speed in pixels per second.
@export var up_velocity: float = 400.0
## How far (pixels) the head drops from the anchor before retracting.
@export var move_distance: float = 500.0
## Texture row where the pole ends and the crusher head begins. Nudge to match art.
@export var pole_texture_height: float = 1500.0

@onready var pole: Sprite2D = $Pole
@onready var head: Area2D = $Head
@onready var head_sprite: Sprite2D = $Head/Sprite2D
@onready var warning_zone: Area2D = $WarningZone
@onready var slam_zone: Area2D = $SlamZone

enum State { IDLE, SLAMMING, RETRACTING }

var _state: State = State.IDLE
var _extend: float = 0.0     # how far the head has dropped from the anchor
var _tex_width: float

func _ready() -> void:
	_tex_width = pole.texture.get_width()
	# Derive the head slice from the split so pole_texture_height is the only knob.
	head_sprite.region_rect = Rect2(0.0, pole_texture_height, _tex_width, \
		pole.texture.get_height() - pole_texture_height)
	head.body_entered.connect(_on_body_entered)
	warning_zone.body_entered.connect(_on_trigger_entered)
	slam_zone.body_entered.connect(_on_trigger_entered)
	_apply()

func _physics_process(delta: float) -> void:
	match _state:
		State.SLAMMING:
			_extend += down_velocity * delta
			if _extend >= move_distance:
				_extend = move_distance
				_state = State.RETRACTING
		State.RETRACTING:
			_extend -= up_velocity * delta
			if _extend <= 0.0:
				_extend = 0.0
				_state = State.IDLE
		State.IDLE:
			return  # nothing to move
	_apply()

# Either trigger zone starts a slam, but only from rest so a cycle isn't cut short.
func _on_trigger_entered(body: Node2D) -> void:
	if _state == State.IDLE and body.is_in_group("player"):
		_state = State.SLAMMING

# Head sits `_extend` below the anchor; the pole fills the gap above it, showing
# the slice of texture just above the slab so the seam with the head stays hidden.
func _apply() -> void:
	head.position.y = _extend
	var pole_len: float = clampf(_extend, 0.0, pole_texture_height)
	pole.visible = pole_len > 0.0
	pole.region_rect = Rect2(0.0, pole_texture_height - pole_len, _tex_width, pole_len)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var level := get_tree().get_first_node_in_group("level_manager")
		if level and level.has_method("player_died"):
			level.player_died()

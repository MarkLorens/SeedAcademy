extends Camera2D
## Camera state machine for a level:
##  - START_LOCKED: holds its starting position while the player runs.
##  - FOLLOWING: smoothly follows the player once she passes follow_start_x.
##  - END_LOCKED: frozen at the end of the level while the player runs off-screen.
##
## The camera moves in _physics_process, on the same tick as the player,
## otherwise the player visibly jitters against the camera. Rendering between
## physics ticks is smoothed by physics interpolation (project setting).

enum State { START_LOCKED, FOLLOWING, END_LOCKED }

@export var player: CharacterBody2D
## World X the player must reach before the camera starts following her.
@export var follow_start_x: float = 200.0
## Camera offset from the player while following (keeps her left of center).
@export var follow_offset := Vector2(700, -400)
## How quickly the camera catches up to its target (higher = snappier).
@export var catch_up_speed: float = 4.0

var state := State.START_LOCKED
var _start_position: Vector2

func _ready() -> void:
	_start_position = global_position
	# Sample the camera on the physics tick, in lockstep with the player.
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS

func _physics_process(delta: float) -> void:
	match state:
		State.START_LOCKED:
			if player and player.global_position.x >= follow_start_x:
				state = State.FOLLOWING

		State.FOLLOWING:
			var target: Vector2 = player.global_position + follow_offset
			# Frame-rate independent catch-up; safe here because it runs on
			# the fixed physics tick, same as the player's movement.
			global_position = global_position.lerp(target, 1.0 - exp(-catch_up_speed * delta))

		State.END_LOCKED:
			pass # Hold position; the player keeps moving without the camera.

## Called when the end-of-level checkpoint is reached.
func lock_end() -> void:
	state = State.END_LOCKED

## Called on (re)spawn: hold at the level-start position again.
func reset_to_start() -> void:
	state = State.START_LOCKED
	global_position = _start_position
	# Teleport: don't let interpolation draw a streak across the level.
	reset_physics_interpolation()

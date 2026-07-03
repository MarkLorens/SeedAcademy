extends Area2D

@export var isFalling: bool = false
@export var fallSpeed: float = 3000.0
@export var triggerDelay: float = 0.15
## How long a fallen spike rests on the floor before returning to its start.
@export var resetDelay: float = 1.0

const FALLING_TEXTURE := preload("res://assets/ingame art assets/level platform tiles/spikes_up.PNG")

var velocity := Vector2.ZERO
var landed := false
var triggered := false
var original_position: Vector2

@onready var sprite: Sprite2D = $Sprite2D
@onready var kill_shape: CollisionPolygon2D = $CollisionShape2D
@onready var floor_ray: RayCast2D = $FloorRayCast
@onready var trigger_zone: Area2D = $TriggerZone

func _ready() -> void:
	add_to_group("spikes")
	# Save Original Position for resetting
	original_position = global_position

	body_entered.connect(_on_body_entered)
	if isFalling:
		trigger_zone.body_entered.connect(_on_trigger_entered)
		_apply_falling_appearance()
	else:
		trigger_zone.queue_free()

# Swap to the down-pointing art and mirror the kill collision vertically to match.
func _apply_falling_appearance() -> void:
	sprite.texture = FALLING_TEXTURE
	kill_shape.position.y = -kill_shape.position.y
	kill_shape.scale.y = -kill_shape.scale.y

func _on_trigger_entered(body: Node2D) -> void:
	if triggered or not body.is_in_group("player"):
		return
		
	triggered = true
	if triggerDelay > 0.0:
		await get_tree().create_timer(triggerDelay).timeout

func _physics_process(delta: float) -> void:
	if isFalling and triggered and not landed:
		velocity.y += fallSpeed * delta
		position += velocity * delta

		floor_ray.force_raycast_update()
		if floor_ray.is_colliding():
			landed = true
			velocity = Vector2.ZERO
			global_position.y = floor_ray.get_collision_point().y
			# Rest on the floor for a moment, then return to the start.
			_reset_after_delay()

func _reset_after_delay() -> void:
	await get_tree().create_timer(resetDelay).timeout
	# The level may have reset us already (e.g. player died) — don't do it twice.
	if landed:
		reset()

## Put the spike back at its starting position, armed again.
## Also called by the level manager when the player respawns.
func reset() -> void:
	global_position = original_position
	triggered = false
	landed = false
	# Teleport: don't let physics interpolation smear the jump back up.
	reset_physics_interpolation()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("hit") # Please leave the print as is. I am simply trying if the kill zone works
		
		# Here lies the command to start the dying
		var level = get_tree().get_first_node_in_group("level_manager")
		if level:
			level.player_died()

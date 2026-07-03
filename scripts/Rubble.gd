extends RigidBody2D

## A physics chunk of a broken breakable tile. It's launched with a small burst,
## falls under gravity, collides with the ground and other chunks so it piles up,
## then frees itself after a short life. The short life + auto-sleep keep the live
## body count low, which is what makes this affordable on mobile.

## Seconds before the chunk removes itself (piles never accumulate).
@export var lifetime: float = 4.0
## Random sideways launch speed on spawn (px/s).
@export var scatter_x: float = 250.0
## Random upward pop on spawn before gravity takes over (px/s).
@export var pop_up: float = 350.0
## Random initial spin (radians/s).
@export var max_spin: float = 6.0

func _ready() -> void:
	add_to_group("rubble")
	# Debris shares collision layer 1 with the terrain it lands on, which the
	# player is also on — exclude the player so chunks don't shove her around.
	var player := get_tree().get_first_node_in_group("player")
	if player:
		add_collision_exception_with(player)
	linear_velocity = Vector2(randf_range(-scatter_x, scatter_x), -randf_range(0.0, pop_up))
	angular_velocity = randf_range(-max_spin, max_spin)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

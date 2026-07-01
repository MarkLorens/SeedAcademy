extends Area2D
class_name Projectile

## A dart fired by a Turret. Travels in a straight line, frees itself once it has
## covered max_distance (so shots never leak off-screen), and disappears on
## hitting anything — the player (game over) or terrain.

@export var speed: float = 800.0
@export var max_distance: float = 1200.0
@export var direction: Vector2 = Vector2.LEFT

var _traveled := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var step: float = speed * delta
	position += direction.normalized() * step
	_traveled += step
	if _traveled >= max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var level := get_tree().get_first_node_in_group("level_manager")
		if level and level.has_method("player_died"):
			level.player_died()
	queue_free()  # disappear on hitting anything

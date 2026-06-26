extends Area2D

@export var isFalling: bool = false
@export var fallSpeed: float = 3000.0
@export var triggerDelay: float = 0.15

var velocity := Vector2.ZERO
var landed := false
var triggered := false

@onready var floor_ray: RayCast2D = $FloorRayCast
@onready var trigger_zone: Area2D = $TriggerZone

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if isFalling:
		trigger_zone.body_entered.connect(_on_trigger_entered)
	else:
		trigger_zone.queue_free()

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
			position.y = floor_ray.get_collision_point().y

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("hit") # Please leave the print as is. I am simply trying if the kill zone works

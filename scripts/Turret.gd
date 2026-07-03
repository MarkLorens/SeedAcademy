extends Area2D

## Fires darts on a steady rhythm while the player is inside the ShotTriggerZone
## (this Area2D's own shape). Each shot is a fresh Projectile instance spawned at
## the Muzzle, so multiple darts can be in flight at once.

const PROJECTILE_SCENE := preload("res://props/hazards/Projectile.tscn")

@export var fire_cooldown: float = 1.5
@export var is_long_range: bool = false
@export var projectile_speed: float = 800.0
@export var projectile_range: float = 1200.0
@export var fire_direction: Vector2 = Vector2.LEFT

@onready var muzzle: Marker2D = $Muzzle

var _player_in_zone := false
var _cooldown_left := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = false

func _process(delta: float) -> void:
	if not _player_in_zone:
		return
	_cooldown_left -= delta
	if _cooldown_left <= 0.0:
		_fire()
		_cooldown_left = fire_cooldown 

func _fire() -> void:
	var shot: Projectile = PROJECTILE_SCENE.instantiate()
	shot.speed = projectile_speed
	shot.max_distance = projectile_range
	shot.direction = fire_direction
	get_parent().add_child(shot)
	shot.global_position = muzzle.global_position

extends Node

# Exportables
@export var Player: CharacterBody2D
@export var Camera: Camera2D
@export var Background: Node2D
@export var Ground: StaticBody2D

const PLAYER_START_POS := Vector2i(200, 485)
const CAMERA_START_POS := Vector2i(576, 324)
# Score here if needed
	
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
var screen_size : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	new_game()

# Reset everything on new game
func new_game():
	Player.position = PLAYER_START_POS
	Player.velocity = Vector2i(0, 0)
	Camera.position = CAMERA_START_POS
	Ground.position = Vector2i(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed = START_SPEED * 60.0 * delta
	
	Player.position.x += speed
	Camera.position.x += speed
	
	if Camera.position.x - Ground.position.x > screen_size.x * 1.5:
		Ground.position.x += screen_size.x

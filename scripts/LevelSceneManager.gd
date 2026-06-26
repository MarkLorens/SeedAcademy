extends Node

# Exportables
@export var Player: CharacterBody2D
@export var Camera: Camera2D
@export var Background: Node2D

const PLAYER_START_POS := Vector2i(400, 485)
const CAMERA_START_POS := Vector2i(1500, -400)
# Score here if needed
	
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

# Reset everything on new game
func new_game():
	Player.position = PLAYER_START_POS
	Player.velocity = Vector2i(0, 0)
	Camera.position = CAMERA_START_POS

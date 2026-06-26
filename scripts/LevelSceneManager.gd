extends Node

# Exportables
@export var Player: CharacterBody2D
@export var Camera: Camera2D
@export var Background: Node2D
@export var Event_UI_Scene: PackedScene

const PLAYER_START_POS := Vector2i(200, 485)
const CAMERA_START_POS := Vector2i(1700, -400)
# Score here if needed
	
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

# Reset everything on new game
func new_game():
	Camera.position = CAMERA_START_POS
	_show_intro_event()

func _show_intro_event() -> void:
	Player.position = PLAYER_START_POS
	Player.velocity = Vector2i(0, 0)
	Player.can_move = false
	var eventUI: EventUI = Event_UI_Scene.instantiate()
	add_child(eventUI)
	eventUI.dialogue_finished.connect(_on_intro_finished)

func _on_intro_finished() -> void:
	Player.can_move = true
	speed = START_SPEED

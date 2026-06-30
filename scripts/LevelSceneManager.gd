extends Node

# Exportables
@export var Player: CharacterBody2D
@export var Camera: Camera2D
@export var Event_UI_Scene: PackedScene
@export var intro_lines: Array[String] = [
	"\"Hey you.\"",
	"\"You're finally awake.\"",
	"\"Lorem Ipsum and whatnot.\"",
]

const PLAYER_START_POS := Vector2i(150, 350)
const CAMERA_START_POS := Vector2i(700, -400)
# Score here if needed

var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25

@onready var pause_menu = $"LevelUI/CanvasLayer/PauseMenu"
@onready var game_over = $"LevelUI/CanvasLayer/GameOver"
@onready var pause_button = $"LevelUI/CanvasLayer/PauseButton/TextureButton"

func _ready() -> void:
	add_to_group("level_manager")
	
	assert(pause_menu, "CRITICAL: PAUSE MENU is not CONNECTED")
	assert(game_over, "CRITICAL: GAME OVER is not CONNECTED")
	
	assert(pause_button, "CRITICAL: PAUSE BUTTON is not CONNECTED")
	pause_button.pressed.connect(pause_game)

	new_game()
	
func pause_game() -> void:
	pause_menu.show_pause()

# Reset everything on new game
func new_game():
	Camera.position = CAMERA_START_POS
	_show_intro_event()

func _show_intro_event() -> void:
	Player.position = PLAYER_START_POS
	Player.velocity = Vector2i(0, 0)
	var eventUI: EventUI = Event_UI_Scene.instantiate()
	eventUI.lines = intro_lines
	add_child(eventUI)
	eventUI.dialogue_finished.connect(_on_intro_finished)

func player_died() -> void:
	game_over.show_game_over()

func _on_intro_finished() -> void:
	Player.can_move = true
	speed = START_SPEED

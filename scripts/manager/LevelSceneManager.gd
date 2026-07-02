extends Node

# Exportables
@export var attempt_text: Label
@export var Player: CharacterBody2D
@export var Camera: Camera2D
@export var Event_UI_Scene: PackedScene
@export var intro_lines: Array[String] = [
	"\"Hey you.\"",
	"\"You're finally awake.\"",
	"\"Lorem Ipsum and whatnot.\"",
]

const PLAYER_START_POS := Vector2i(150, 280)
const CAMERA_START_POS := Vector2i(700, -400)
var attempts := 1

var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25


@onready var pause_menu = $"LevelUI/CanvasLayer/PauseMenu"
@onready var pause_button = $"LevelUI/CanvasLayer/PauseButton/TextureButton"

func _ready() -> void:
	add_to_group("level_manager")
	
	assert(pause_menu, "CRITICAL: PAUSE MENU is not CONNECTED")
	assert(pause_button, "CRITICAL: PAUSE BUTTON is not CONNECTED")
	pause_button.pressed.connect(pause_game)

	new_game(false)
	
func pause_game() -> void:
	pause_menu.show_pause()

# Reset everything on new game
func new_game(just_died: bool):
	Camera.position = CAMERA_START_POS
	Player.position = PLAYER_START_POS
	
	if not just_died:
		_show_intro_event()
	else:
		attempts += 1
		attempt_text.text = "Attempt %d" % attempts
		attempt_text.get_parent().show()
		
		await get_tree().create_timer(1.0).timeout
		
		attempt_text.get_parent().hide()

func _show_intro_event() -> void:
	Player.velocity = Vector2i(0, 0)
	var eventUI: EventUI = Event_UI_Scene.instantiate()
	eventUI.lines = intro_lines
	add_child(eventUI)
	eventUI.dialogue_finished.connect(_on_intro_finished)

func player_died() -> void:
	if Player.is_shielded:
		return
	
	new_game(true)

func _on_intro_finished() -> void:
	Player.can_move = true
	speed = START_SPEED
	pass

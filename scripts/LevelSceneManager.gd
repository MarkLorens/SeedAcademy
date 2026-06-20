extends Node

const PLAYER_START_POS := Vector2i(150, 485)
const CAMERA_START_POS := Vector2i(576, 324)
#Score here if needed
	
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
	$Fira.position = PLAYER_START_POS
	$Fira.velocity = Vector2i(0, 0)
	$Camera2D.position = CAMERA_START_POS
	$JungleGround.position = Vector2i(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed = START_SPEED * 60.0 * delta
	
	$Fira.position.x += speed
	$Camera2D.position.x += speed
	
	if $Camera2D.position.x - $JungleGround.position.x > screen_size.x * 1.5:
		$JungleGround.position.x += screen_size.x

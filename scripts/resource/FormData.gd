extends Resource
class_name FormData

@export var form_name: String = ""
@export var form_texture: Texture2D
## Walk-cycle frames. Leave empty to just show form_texture (no animation).
@export var walk_frames: Array[Texture2D] = []
## Frames per second for the walk cycle.
@export var walk_fps: float = 10.0
@export var run_speed: float = 0
@export var jump_speed: float = 0
@export var gravity_scale: float = 1.0
@export var action_script: FormAction
@export var min_jump_speed: float = 0
@export var wheel_menu_forms: Array[Texture2D]
@export var new_form_guide: String
@export var action_button: Texture2D
## Sprite(s) shown while the form's ability is active (1 = static, 2+ = animation).
## Leave empty to keep the walk sprite during the ability (e.g. frog).
@export var ability_frames: Array[Texture2D] = []
## Frames per second for the ability animation.
@export var ability_fps: float = 10.0
## Sprite(s) shown while rising (moving upward in the air). 1 = static, 2+ = anim.
@export var jump_frames: Array[Texture2D] = []
@export var jump_fps: float = 10.0
## Sprite(s) shown while falling (airborne and not rising). Also covers walking
## off ledges, not just the jump ability.
@export var falling_frames: Array[Texture2D] = []
@export var falling_fps: float = 10.0

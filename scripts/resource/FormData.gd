extends Resource
class_name FormData

@export var form_name: String = ""
@export var form_texture: Texture2D
## Walk-cycle frames. Leave empty to just show form_texture (no animation).
@export var walk_frames: Array[Texture2D] = []
## Frames per second for the walk cycle.
@export var walk_fps: float = 10.0
@export var run_speed: float = 0
@export var attack_col_enabled: bool = false
@export var shield_col_enabled: bool = false
@export var jump_speed: float = 0
@export var gravity_scale: float = 1.0
@export var action_script: FormAction
@export var min_jump_speed: float = 0
@export var wheel_menu_forms: Array[Texture2D]

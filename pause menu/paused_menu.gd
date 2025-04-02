extends Control
@onready var pause_music = $AudioStreamPlayer
var _is_paused:bool = false:
	set = set_paused
	
func _ready():
	visible = false
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused
	

func set_paused(value:bool) ->void:
	_is_paused = value
	get_tree().paused = _is_paused
	visible = _is_paused
	if _is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		pause_music.play()
		
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		pause_music.stop()

func _on_resume_button_pressed():
	_is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_settings_button_pressed():
	pass


func _on_quit_button_pressed():
	get_tree().quit()

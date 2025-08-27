extends Control
@onready var pause_music = $AudioStreamPlayer
@onready var ip_label = $IpLabel

var _is_paused:bool = false:
	set = set_paused
	
func _ready():
	var ip = get_local_ip()
	ip_label.text = "Host IP: " + ip
	visible = false
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and Global.player == null:
		pass
	else:
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
	NetworkManager.host_quit_to_menu()
	get_tree().quit()


func _on_quit_menu_button_pressed():
	NetworkManager.host_quit_to_menu()
	_is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://Scenes/Worlds/main_menu.tscn")

func get_local_ip() -> String:
	var addresses = IP.get_local_addresses()
	for ip in addresses:
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	# Fallback to first available address if list not empty
	if addresses.size() > 0:
		return addresses[0]
	# Final fallback
	return "127.0.0.1"

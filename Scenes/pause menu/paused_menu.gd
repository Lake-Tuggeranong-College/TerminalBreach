extends Control

@onready var pause_music = $AudioStreamPlayer
@onready var ip_label = $IpLabel
#@onready var reticle = $"../CanvasLayer/HUD/Reticle"
@onready var player = preload("res://Scenes/Player/Player.gd")


@onready var pause_music: AudioStreamPlayer = $AudioStreamPlayer
@onready var ip_label: Label = $IpLabel

var _is_paused: bool = false:
	set = set_paused

func _ready() -> void:
	var ip := get_local_ip()
	if ip_label:
		ip_label.text = "Host IP: " + ip
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	# Keep your original logic: if pause pressed while Global.player == null, ignore
	if event.is_action_pressed("pause") and Global.player == null:
		return
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused

func set_paused(value: bool) -> void:
	_is_paused = value
	visible = _is_paused

	# Optional: actually pause the game tree so physics/scripts stop
	# Comment out the next line if you don't want to pause gameplay.
	get_tree().paused = _is_paused

	if _is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if pause_music and not pause_music.playing:
			pause_music.play()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if pause_music and pause_music.playing:
			pause_music.stop()

func _on_resume_button_pressed() -> void:
	_is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#reticle.show()

func _on_settings_button_pressed() -> void:
	# Open your settings UI here if/when you add it
	pass

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().quit(0)


func _on_quit_menu_button_pressed() -> void:
	# Also routes to main menu and changes scene
	NetworkManager.host_quit_to_menu()
	_is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Worlds/main_menu.tscn")

func _on_quit_desktop_button_pressed() -> void:
	# HTML5 builds cannot close the browser tab
	if OS.has_feature("web"):
		visible = true
		if ip_label:
			ip_label.text = "You can now close this tab."
		return

	# Clean shutdown for desktop builds
	# 1) Close multiplayer if active
	if multiplayer.multiplayer_peer:
		# ENetMultiplayerPeer has close(); other peers may differ but close() is safe if present
		if "close" in multiplayer.multiplayer_peer:
			multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

	# 2) Stop audio
	if pause_music and pause_music.playing:
		pause_music.stop()

	# 3) Ensure cursor is visible
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# 4) Unpause (for safety) and quit
	get_tree().paused = false
	get_tree().quit(0)

func get_local_ip() -> String:
	var addresses := IP.get_local_addresses()
	for ip in addresses:
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	# Fallback to first available address if list not empty
	if addresses.size() > 0:
		return addresses[0]
	# Final fallback
	return "127.0.0.1"

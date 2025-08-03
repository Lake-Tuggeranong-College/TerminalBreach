extends Node

#@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry 
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var music = $NavigationRegion3D/Environment/AudioStreamPlayer2

@onready var Player = preload("res://Scenes/Player/player.tscn")
#@onready var Player = $Player
var tracked = false
var player


func _physics_process(_delta):
	if tracked:
		get_tree().call_group("enemy", "update_target_location", player.global_transform.origin)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("test world"):
		get_tree().change_scene_to_file("res://Scenes/Worlds/spaceshipMap.tscn")
	if Input.is_action_pressed("toggle_fullscreen"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)



func add_player(peer_id):
	player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	tracked = true
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value


func _on_quit_pressed() -> void:
	get_tree().quit()

func _ready():
	Global.hud = $HUD
	hud.show()
	music.play()
	#multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())

func _on_spaceship_pressed():
	get_tree().change_scene_to_file("res://Scenes/Worlds/spaceshipMap.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/options.tscn")

@rpc("authority")
func request_respawn(player_id: int) -> void:
	print("Respawning player %d in 3 seconds..." % player_id)
	
	# Respawn cooldown (wait for 3 seconds)
	await get_tree().create_timer(3.0).timeout
	
	spawn_player(player_id)


func spawn_player(player_id: int) -> void:
	var player_scene = preload("res://Scenes/Player/player.tscn")
	var new_player = player_scene.instantiate()
	
	# Assign a spawn position (replace with your own logic)
	new_player.position = get_spawn_position()
	
	# Add the player to the scene
	add_child(new_player)
	
	# Set multiplayer authority so this player controls their own instance
	new_player.set_multiplayer_authority(player_id)
	
	new_player.name = str(player_id)
	
	print("Player %d respawned!" % player_id)


func get_spawn_position():
	# TODO: Replace with your spawn logic
	# For example, pick a random position or a fixed point
	Global.position = Vector3.ZERO

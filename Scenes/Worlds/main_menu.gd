
extends Control
@onready var scenetransition = $Transition/AnimationPlayer
@onready var menu = $"."
@onready var address_entry = $MarginContainer/VBoxContainer/AddressEntry
@onready var hidden_ip = $MarginContainer/VBoxContainer/hidden_ip




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scenetransition.get_parent().get_node("ColorRect").color.a = 255
	scenetransition.play("fadeout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_single_player_pressed() -> void:
	Global.single_player_mode = true
	print("Single Player Mode - pressed")
	get_tree().change_scene_to_file("res://Scenes/Worlds/spaceshipMap.tscn")

func _on_host_button_pressed():
	Global.single_player_mode = false
	print("Host Mode - pressed")
	get_tree().change_scene_to_file("res://Scenes/Worlds/spaceshipMap.tscn")
	
func _on_join_button_pressed():
	var ip = address_entry.text.strip_edges()
	
	if ip == "":
		show_error("Please enter a valid IP address before joining.")
		return

	Global.single_player_mode = false
	Global.address_server = ip

	# Create the peer
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, Global.PORT)

	if error != OK:
		show_error("Failed to create client.")
		return

	multiplayer.multiplayer_peer = peer

	# Connect signal to check if connection fails
	if multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.disconnect(_on_connection_failed)
	multiplayer.connection_failed.connect(_on_connection_failed)

	if multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	# Start a timer as a fallback in case the signals don't fire
	start_connection_timeout()
	
	print("Trying to connect to:", ip)

func start_connection_timeout():
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.name = "ConnectionTimeout"
	add_child(timer)
	timer.timeout.connect(_on_connection_timeout)
	timer.start()

func _on_connection_timeout():
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		show_error("Connection timed out. Host may be offline or IP is incorrect.")
		multiplayer.multiplayer_peer = null  # Disconnect gracefully

	# Clean up the timer
	if has_node("ConnectionTimeout"):
		get_node("ConnectionTimeout").queue_free()


func _on_connection_failed():
	print("Connection to host failed.")
	show_error("Could not connect to host. Please check the IP address and try again.")

func show_error(message: String):
	var error_label = $ErrorLabel
	var anim = $AnimationPlayer
	
	error_label.text = message
	error_label.visible = true
	error_label.modulate.a = 1.0  # Reset alpha in case it's faded
	
	anim.stop()  # Stop any current animations on it
	anim.play("fade_error")

func _on_connected_to_server():
	print("Successfully connected to host.")
	if has_node("ConnectionTimeout"):
		get_node("ConnectionTimeout").queue_free()
	get_tree().change_scene_to_file("res://Scenes/Worlds/spaceshipMap.tscn")


func _on_options_pressed():
	scenetransition.play("fadein")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/options.tscn")
	


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits/GodotCredits.tscn")

func _on__button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/dont look/node_2d.tscn")


#func _on_multiplayer_spawner_spawned(node):
	#if node.is_multiplayer_authority():
		#node.health_changed.connect(update_health_bar)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(Global.PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
	



func _on_ryan_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/for ryan/for_ryan.tscn")


func _on_join_default_server_pressed() -> void:
	var ip = hidden_ip.text.strip_edges()
	
	if ip == "":
		show_error("Please enter a valid IP address before joining.")
		return

	Global.single_player_mode = false
	Global.address_server = ip

	# Create the peer
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, Global.PORT)

	if error != OK:
		show_error("Failed to create client.")
		return

	multiplayer.multiplayer_peer = peer

	# Connect signal to check if connection fails
	if multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.disconnect(_on_connection_failed)
	multiplayer.connection_failed.connect(_on_connection_failed)

	if multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	# Start a timer as a fallback in case the signals don't fire
	start_connection_timeout()
	
	print("Trying to connect to:", ip)

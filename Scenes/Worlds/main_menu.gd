
extends Control
@onready var scenetransition = $Transition/AnimationPlayer
@onready var menu = $"."
@onready var address_entry = $MarginContainer/VBoxContainer/AddressEntry



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
	Global.single_player_mode = false
	Global.address_server = address_entry.text
	#Global.enet_peer.create_client(address_entry.text, Global.PORT)
	print("Join Mode - pressed")
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

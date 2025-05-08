
extends Control
@onready var scenetransition = $Transition/AnimationPlayer
@onready var menu = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scenetransition.get_parent().get_node("ColorRect").color.a = 255
	scenetransition.play("fadeout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_single_player_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Worlds/spaceshipMap.tscn")
	print("pressed")


func _on_options_pressed():
	scenetransition.play("fadein")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/options.tscn")
	menu.visible == false
	


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits/GodotCredits.tscn")

func _on__button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/dont look/node_2d.tscn")

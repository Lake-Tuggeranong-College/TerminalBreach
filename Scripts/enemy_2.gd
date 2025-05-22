extends CharacterBody3D
@onready var anim = $enemymodel/AnimationPlayer
@onready var gunanim = $AnimationPlayer
@onready var nav_agent = $NavigationAgent3D
@onready var enemy = $enemy
@onready var pistol = $enemymodel/Pistol # Reference the gun node (pistol) in the enemy scene
@onready var player = null #get_node("/root/Player")  
var SPEED = 2
const JUMP_VELOCITY = 4.5
var bullet_scene = preload("res://Scenes/Enemy/enemy_bullet.tscn")
@export var shooting_offset: Vector3 = Vector3(0, 1, 3)  # Adjust where bullets should spawn
var bullet_instance = 0
var shoot_timer: Timer
var bullet_spawn
var health = 100
signal death

#enemy gravity
var speed = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const max_distance = 10.0  # Maximum distance to follow and shoot the player
var player_detected = false

var health_pickup_scene = preload("res://Scenes/health_pickup.tscn")
var health_pickup_spawn

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")




func _ready() -> void:
	bullet_spawn = get_node("enemymodel/Pistol/bullet_spawn")
	health_pickup_spawn = get_node("health_pickup_spawn")

func update_target_location (target_location):
	nav_agent.set_target_position(target_location)

# Check if the player is within the specified range
func is_within_distance(target_location: Vector3) -> bool:
	var current_location = global_transform.origin
	var distance = current_location.distance_to(target_location)
	return distance <= max_distance
	
	
#this is code writtin by AI, It moves the enemy but only in the x and z directions. This means they wont constantly look down.
func _physics_process(_delta):
	# Apply gravity
	velocity.y -= gravity * _delta  # Decrease Y-velocity to simulate gravity
	# Move the enemy with the updated velocity
	move_and_slide()
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	
	# Calculate the direction to look towards (ignoring Y-axis)
	var direction = (next_location - current_location).normalized()
	direction.y = 0  # Ignore vertical direction to prevent looking down or up
	

	
	# If there is a direction to look at, update the rotation
	if direction.length() > 0:
		look_at(current_location + direction, Vector3.UP)  # Rotate only around Y-axis
	
	#print(player_detected)
	#checks whether the player has entered the into the range of the enemy and has not detected the player yet
	if Global.player != null and is_within_distance(Global.player.global_transform.origin) and player_detected == false:
		detected_player()
	

	# Vector Maths for movement
	if Global.player != null and player_detected == true:
		anim.play("Armature_001|mixamo_com|Layer0_001")
		gunanim.play("bob")
		var new_velocity = direction * SPEED
		velocity = new_velocity
		move_and_slide()
	
# Attempt to find the player node if not already found
	if Global.player == null:
		Global.player = get_tree().root.get_node_or_null("root/World/1")
#	print(Global.player)
	#if Global.player:
		#aim_gun_at_player()
	

##This will make the enemy aim at the player
#func aim_gun_at_player():
	#if Global.player != null and player_detected == true:
		## Calculate the direction from the gun to the player
		#var pistol_position = pistol.global_transform.origin
		#var player_position = Global.player.global_transform.origin
	##	print("Player position: ", player_position)  # Debug print
		#var aim_direction = (player_position - pistol_position).normalized()
	##	print("Aim direction: ", aim_direction)  # Debug print
		## Make the gun rotate to face the player
		#pistol.look_at(pistol_position + aim_direction, Vector3.UP)
##	else:
##		print("Player node not found")  # Debug print

func shoot_bullet():
	# Create the bullet instance
	var bullet_instance = bullet_scene.instantiate()
	# Position the bullet in front of the enemy
	enemy.play()
	bullet_instance.global_transform = bullet_spawn.global_transform
	# Add bullet to the scene
	get_tree().current_scene.add_child(bullet_instance)





func _on_timer_timeout():
	if Global.player != null and player_detected == true:
		shoot_bullet()


func take_damageE(damage_amount):
	health -= damage_amount
	if Global.player != null and player_detected == false:
		detected_player()
	if health <=0:
		var health_pickup_instance = health_pickup_scene.instantiate()
		
		health_pickup_instance.global_transform = health_pickup_spawn.global_transform
		
		get_tree().current_scene.add_child(health_pickup_instance)
		
		queue_free()

func detected_player():
	player_detected = true
	#print("player detected")
	#print(player_detected)
	

func die():
	emit_signal("death")
	queue_free()


func _on_death() -> void:
	emit_signal("death")
	queue_free()

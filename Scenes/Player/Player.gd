extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D
@onready var player_anim_player = $Camera3D/man/AnimationPlayer
@onready var muzzle_flash = $Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Pistol/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D
@onready var gunshot = $gunshot
@export var crouch_height : float = 1.5  # Crouched height
@export var standing_height : float = 2.5  # Standing height
@onready var ammo_counter = null
@onready var hitmarker = $CanvasLayer/HUD/Hitmarker  # Adjust path to match your scene
@onready var reticle = $CanvasLayer/HUD/Reticle
@export var max_health: int = 100


#player shooting
var bullet_spawn
var pistol_bullet_scene = preload("res://Scenes/Player/pistol_bullet.tscn")
var rifle_bullet_scene = preload("res://Scenes/Player/rifle_bullet.tscn")
var shoot_cooldown_pistol = 0.2
var shoot_cooldown_rifle = 0.1
var can_shoot = true


var ammo = 12
var ammo_rifle = 32

var reload_time = 3
var is_reloading = false
var is_shooting = true
var weapons = {}
var current_weapon = null


#player health
var current_health: int = 100
var health_regen:float = 1 #amount of health regenerated every second
var health = 100

#player movement
const JUMP_VELOCITY = 10.0
var speed = 5.0
var gravity = 20.0
var is_crouching : bool = false
@onready var weapon_holder = $weapon_holder
@onready var health_bar = $HealthBar

var is_ready = false

var weapon_switch = 0

@rpc("any_peer")
func take_damage(amount: int):
#	current_health = max(current_health - amount, 0)
	health -= 20
	print("damage taken")
	if health <= 0:
		print("Game Over!")
		# Reset the player's health and position
		health = max_health
		position = Vector3.ZERO
		# Emit the health_changed signal with the reset health value
	health_changed.emit(health)

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready():
	Global.player = self
	if not is_multiplayer_authority(): return
	bullet_spawn = get_node("Camera3D/bulletSpawn")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	# Find HUD in the world
	Global.player = self
	#print("Player _ready() called!")

	await get_tree().process_frame  # Wait a frame
	var hud = null
	

	while hud == null:
		hud = get_tree().get_first_node_in_group("hud")
		if hud:
			print("HUD found:", hud)
			hitmarker = hud.get_node_or_null("Hitmarker")

	camera.position.y = standing_height / 1.3

	ammo_counter = get_node("Camera3D/AmmoCounter")
	if ammo_counter:
		update_ammo_counter()
	else:
		is_ready = true
		print("ammo counte rnot foun")
		
	if is_ready and ammo_counter:
		update_ammo_counter()



func update_ammo_counter():
	if ammo_counter:
		if weapon_switch == 0:
			ammo_counter.text = str(ammo) + "/12"
		elif weapon_switch == 1:
			ammo_counter.text = str(ammo_rifle) + "/32"
	else:
		print("no label cuh")
	


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	
	

		

	# Detect the reload key (R key)
	if Input.is_action_just_pressed("reload") and not is_reloading:
		start_reload()
		
	if Input.is_action_just_pressed("shoot") and can_shoot and ammo > 0 and weapon_switch == 0:
		shoot()

	if event is InputEventKey and event.pressed and Input.is_action_just_pressed("weapon_switch") and not is_reloading:
		if weapon_switch == 0: #switch weapon to the rifle
			$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Pistol.hide()
			$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Rifle.show()
			weapon_switch = 1
			update_ammo_counter()
		elif weapon_switch == 1: #switch weapon to the pistol
			$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Pistol.show()
			$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Rifle.hide()
			weapon_switch = 0
			#switch_weapon("rifle")
			#print("Switched weapon")
			update_ammo_counter()


func _physics_process(delta):

	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_pressed("shoot") and can_shoot and ammo_rifle > 0 and weapon_switch == 1 and is_reloading == false:
		shoot()

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if player_anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():

		if weapon_switch == 0:  # Pistol
			player_anim_player.play("move")
		elif weapon_switch == 1:  # Rifle
			player_anim_player.play("riflemove")
	else:
		if weapon_switch == 0:  # Pistol
			player_anim_player.play("idle")
		elif weapon_switch == 1:  # Rifle
			player_anim_player.play("rifleidle")

	move_and_slide()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		#anim_player.play("idle")
		#rifle_anim_player.play("idle")
		player_anim_player.play("idle")
		
# Called every frame
func _process(delta: float):
	
	# Check if the player is holding shift to run
	# Speeds are subject to change
	if Input.is_action_pressed("player_run") and is_crouching == false:
		speed = 12.0
	elif Input.is_action_just_pressed("ui_crouch"): 
		print("Crouch")
		toggle_crouch()
		speed = 3.5
		if is_crouching:
			camera.position.y = crouch_height / 2.0
		else:
			camera.position.y = standing_height / 1.3

	else:
		speed = 5.0
	
	#regenerates health_regen amount every second
	var fps = Engine.get_frames_per_second()
	if health < max_health: #
		health += health_regen/fps
		health_changed.emit(health)
		
		
		
func toggle_crouch():
	is_crouching = !is_crouching

@rpc("any_peer")
func shoot():
	# If ammo is greater than 0, proceed with shooting
	#anim_player.stop()
	#anim_player.play("shoot")
	#rifle_anim_player.play("shoot")
	gunshot.play()
	muzzle_flash.restart()
	muzzle_flash.emitting = true
	can_shoot = false
	#and anim_player.current_animation != "shoot":
	if weapon_switch ==0:
		player_anim_player.play("shoot")
		await get_tree().create_timer(shoot_cooldown_pistol).timeout
	elif weapon_switch ==1:
		player_anim_player.play("rifleshoot")
		await get_tree().create_timer(shoot_cooldown_rifle).timeout
	can_shoot = true
	
	if ammo > 0 and weapon_switch == 0:
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.take_damage.rpc_id(hit_player.get_multiplayer_authority()) 
		var pistol_bullet = pistol_bullet_scene.instantiate()
		get_node("MultiplayerSynchronizer").add_child(pistol_bullet)

		get_tree().add_child(pistol_bullet)

		pistol_bullet.global_transform = bullet_spawn.global_transform
		pistol_bullet.scale = Vector3(0.1, 0.1, 0.1)
		

		# Connect bullet collision to hitmarker function
		pistol_bullet.connect("enemy_hit", Callable(self, "show_hitmarker"))

		# Decrease ammo by 1
		ammo -= 1
	elif ammo_rifle > 0 and weapon_switch == 1:
		var rifle_bullet = rifle_bullet_scene.instantiate()
		get_tree().root.add_child(rifle_bullet)
		rifle_bullet.global_transform = bullet_spawn.global_transform
		rifle_bullet.scale = Vector3(0.1, 0.1, 0.1)
		

		# Connect bullet collision to hitmarker function
		rifle_bullet.connect("enemy_hit", Callable(self, "show_hitmarker"))

		# Decrease ammo_rifle by 1
		ammo_rifle -= 1

	# Update the ammo counter
	update_ammo_counter()

func start_reload():
	is_reloading = true
	if ammo_counter:
		ammo_counter.text = "RELOADING"  # Display reloading text
	# Play reload animation if applicable
	# anim_player.play("reload")

	await get_tree().create_timer(reload_time).timeout  # Wait for reload time
	if weapon_switch == 0:
		ammo = 12  # Reset ammo after reload
	elif weapon_switch == 1:
		ammo_rifle = 32  # Reset ammo after reload
	update_ammo_counter()  # Update the counter after reload
	is_reloading = false

func show_hitmarker():
	if hitmarker:
		if reticle:
			reticle.visible = false  # Hide reticle when hitmarker appears
#
		#print("Showing hitmarker!")
		hitmarker.visible = true
		await get_tree().create_timer(0.2).timeout  # Keep hitmarker for 0.2s
		hitmarker.visible = false
		
		if reticle:
			reticle.visible = true  # Show reticle again after hitmarker disappears
			
		#print("Hiding hitmarker!")
	#else:
		#print("ERROR: Hitmarker is NULL!")

func health_pickup(pickup_health_percent):
	health += max_health * pickup_health_percent
	health_changed.emit(health)

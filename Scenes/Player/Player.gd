extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D
#@onready var anim_player = $AnimationPlayer
#@onready var rifle_anim_player = $Camera3D/Rifle/RifleAnimationPlayer
@onready var player_anim_player = $Camera3D/man/AnimationPlayer
@onready var muzzle_flash = $Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Pistol/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D
@onready var gunshot = $gunshot
@export var crouch_height : float = 1.5  # Crouched height
@export var standing_height : float = 2.5  # Standing height
@onready var ammo_counter = null
@onready var hitmarker = $/root/SpaceshipMap/CanvasLayer/HUD/Hitmarker  # Adjust path to match your scene
@onready var reticle = $/root/SpaceshipMap/CanvasLayer/HUD/Reticle
@export var max_health: int = 100
@export var pistol_damage: int = 20
@export var rifle_damage: int = 5
@onready var weapon_holder = $weapon_holder
@onready var deathanimplayer = $DeathAnim
@onready var healthbar = $/root/SpaceshipMap/CanvasLayer/HUD/HealthBar
@onready var dontwannadie = $DeathAnim/Idontwannadie
@onready var deathsound = $DeathAnim/deathsound
@onready var model_anim_player = $Camera3D/MutiplayerModel/AnimationPlayer
@onready var multiplayermodel = $Camera3D/MutiplayerModel
@onready var playerarms = $Camera3D/man/Armature
@onready var stoprotatingplease =$Camera3D/MutiplayerModel/Armature_005/Skeleton3D/Ch35
#player shooting
var bullet_spawn
var pistol_bullet_scene = preload("res://Scenes/Player/pistol_bullet.tscn")
var rifle_bullet_scene = preload("res://Scenes/Player/rifle_bullet.tscn")
var shoot_cooldown_pistol = 0.2
var shoot_cooldown_rifle = 0.1
var can_shoot = true

var ammo = 12 #active ammo
var ammo_rifle = 32 #active ammoo

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


var is_ready = false
var enemies_highlighted = false
var weapon_switch = 0

@rpc("any_peer")
func take_damage(amount: int):
	if not is_multiplayer_authority(): return  # Prevent clients from modifying health
	health -= amount
	print("%s took damage. Remaining: %d" % [name, health]) 
	if health <= 0:
		print("Game Over for %s!" % name)
		global_position = Vector3(100,100,100)
		#var death_anims = ["DeathAnim1", "DeathAnim2", "DeathAnim3", "DeathAnim4", "DeathAnim5"] #Index for death animations
		#var chosen_anim = death_anims[randi() % death_anims.size()] # picks random death animation
		deathanimplayer.play("DeathAnim1") 
		deathsound.play() 
		healthbar.hide() 
		await get_tree().create_timer(4.59).timeout #respawn timer
		healthbar.show()
		health = max_health
		var spawner = get_node("/root/SpaceshipMap/Spawner")
		spawner.respawn_player(self)
		#position = Vector3.ZERO
		ammo = 12
		ammo_rifle = 32
		update_ammo_counter()
	health_changed.emit(health)

@rpc("authority") #balls
func die():
	await get_tree().create_timer(3).timeout
	queue_free()
	var player_id = multiplayer.get_unique_id()
	rpc_id(1, "request_respawn", player_id)
	
	
@rpc("authority", "reliable")
func spawn_bullet(is_rifle: bool, transform: Transform3D, shooter_peer: int):
	var bullet_scene = rifle_bullet_scene if is_rifle else pistol_bullet_scene
	var bullet = bullet_scene.instantiate()
	bullet.global_transform = transform
	bullet.damage = rifle_damage if is_rifle else pistol_damage

	# 🔥 Assign the shooter so the bullet can ignore them
	bullet.shooter = self

	get_tree().current_scene.add_child(bullet)

	# ✅ Only connect hitmarker if this peer is the shooter
	if multiplayer.get_unique_id() == shooter_peer:
		bullet.connect("enemy_hit", Callable(self, "show_hitmarker"))


func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready(): 
	# Hide death UI/effects/MPmodel for everyone on spawn (host + clients)
	dontwannadie.hide()
	deathanimplayer.stop()
	deathsound.stop()
	healthbar.show()
	Global.player = self
	if is_multiplayer_authority():
		multiplayermodel.hide()
		playerarms.show()
	else:
		multiplayermodel.show()
		playerarms.hide()

	# From here on, only do local-authority setup
	if not is_multiplayer_authority():
		return

	bullet_spawn = get_node("Camera3D/bulletSpawn")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

	await get_tree().process_frame  # Wait for HUD to be ready

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hitmarker = hud.get_node_or_null("Hitmarker")
		reticle = hud.get_node_or_null("Reticle")

	camera.position.y = standing_height / 1.3

	ammo_counter = get_node("Camera3D/AmmoCounter")
	if ammo_counter:
		update_ammo_counter()
	else:
		is_ready = true
		print("ammo counter not found")

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
	$Camera3D/ammo_counter_all/pistol_ammo/active_ammo.text = str(ammo) + "/12"
	$Camera3D/ammo_counter_all/rifle_ammo/active_ammo.text = str(ammo_rifle) + "/32"
	


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	#if Input.is_action_just_pressed("esp"):
		#enemies_highlighted = !enemies_highlighted
		#toggle_enemy_highlights(enemies_highlighted)
	if Input.is_action_just_pressed("pause"): 
		reticle.hide()
	
		
	# Detect the reload key (R key)
	if Input.is_action_just_pressed("reload") and not is_reloading:
		start_reload()
			
	if Input.is_action_just_pressed("shoot") and can_shoot and ammo > 0 and weapon_switch == 0:
		shoot()
	if event is InputEventKey and event.pressed and Input.is_action_just_pressed("weapon_switch") and not is_reloading:
		if weapon_switch == 0:  # switch to rifle
			$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Pistol.hide()
			$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Rifle.show()
			weapon_switch = 1
			set_weapon_visibility(weapon_switch)
			set_weapon_visibility.rpc(weapon_switch)
			update_ammo_counter()
		elif weapon_switch == 1:  # switch to pistol
			$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Pistol.show()
			$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Rifle.hide()
			weapon_switch = 0
			set_weapon_visibility(weapon_switch)
			set_weapon_visibility.rpc(weapon_switch)
			update_ammo_counter()

func _physics_process(delta):

	reticle.show()



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
			play_remote_anim.rpc("PistolRunning")
			model_anim_player.play("PistolRunning")
		elif weapon_switch == 1:  # Rifle
			player_anim_player.play("RifleRunning")
			model_anim_player.play("RifleRunning")
	else:
		if weapon_switch == 0:  # Pistol
			player_anim_player.play("idle")
			play_remote_anim.rpc("PistolIdle")
			model_anim_player.play("PistolIdle")
		elif weapon_switch == 1:  # Rifle
			player_anim_player.play("rifleidle")
			play_remote_anim.rpc("RifleIdle")
			model_anim_player.play("RifleIdle")
				
	move_and_slide()
	


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		#anim_player.play("idle")
		#rifle_anim_player.play("idle")
		player_anim_player.play("idle")
		model_anim_player.play("PistolIdle")
		play_remote_anim.rpc("PistolIdle")
		
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
	
	if not is_multiplayer_authority():
		camera.rotation_degrees.x = 0
		camera.rotation_degrees.z = 0
	
func toggle_crouch():
	is_crouching = !is_crouching

@rpc("any_peer")
func shoot():
	if not can_shoot:
		return

	can_shoot = false

	# Determine weapon stats
	var is_rifle = weapon_switch == 1
	var damage = rifle_damage if is_rifle else pistol_damage
	var cooldown = shoot_cooldown_rifle if is_rifle else shoot_cooldown_pistol

	# Play local effects
	gunshot.play()
	muzzle_flash.restart()
	muzzle_flash.emitting = true

	# Play local and remote animation
	var anim_name = "rifleshoot" if is_rifle else "shoot"
	player_anim_player.play(anim_name)
	play_remote_anim.rpc("RifleShooting")
	model_anim_player.play("RifleShooting")

	# Raycast instant damage
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target.has_method("take_damage"):
			var authority_id = target.get_multiplayer_authority()
			target.take_damage.rpc_id(authority_id, damage)

	# Spawn bullet across network
	var shooter_id = multiplayer.get_unique_id()
	var spawn_transform = bullet_spawn.global_transform

	if is_rifle and ammo_rifle > 0:
		spawn_bullet(true, spawn_transform, shooter_id)
		spawn_bullet.rpc(true, spawn_transform, shooter_id)
		ammo_rifle -= 1
	elif not is_rifle and ammo > 0:
		spawn_bullet(false, spawn_transform, shooter_id)
		spawn_bullet.rpc(false, spawn_transform, shooter_id)
		ammo -= 1


	update_ammo_counter()

	await get_tree().create_timer(cooldown).timeout
	can_shoot = true






func start_reload():
	is_reloading = true
	if ammo_counter:
		ammo_counter.text = "RELOADING"  # Display reloading text
	# Play reload animation if applicable
	# anim_player.play("reload")

	await get_tree().create_timer(reload_time).timeout  # Wait for reload time
	if weapon_switch == 0:
		ammo = 12
	elif weapon_switch == 1:
		ammo_rifle = 32  # Reset ammo after reload
	update_ammo_counter()  # Update the counter after reload
	is_reloading = false

func show_hitmarker():
		hitmarker.visible = true
		hitmarker.modulate = Color(1, 1, 1, 1)  # Fully opaque white
		hitmarker.size_flags_horizontal = Control.SIZE_FILL
		hitmarker.size_flags_vertical = Control.SIZE_FILL
		hitmarker.z_index = 1000  # Bring to front if using Control node

		await get_tree().create_timer(0.2).timeout
		hitmarker.visible = false




@rpc("call_remote")
func play_remote_anim(anim_name: String):
	if model_anim_player.has_animation(anim_name):
		model_anim_player.play(anim_name)
		
@rpc("call_remote")
func set_weapon_visibility(weapon_index: int):
	if weapon_index == 0:
		$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Pistol.show()
		$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Rifle.hide()
		$Camera3D/MutiplayerModel/Armature_005/Skeleton3D/BoneAttachment3D/riflecomplete.hide()
		$Camera3D/MutiplayerModel/Armature_005/Skeleton3D/BoneAttachment3D/Pistol.show()
	elif weapon_index == 1:
		$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Pistol.hide()
		$Camera3D/man/Armature/Skeleton3D/BoneAttachment3D/Rifle.show()
		$Camera3D/MutiplayerModel/Armature_005/Skeleton3D/BoneAttachment3D/riflecomplete.show()
		$Camera3D/MutiplayerModel/Armature_005/Skeleton3D/BoneAttachment3D/Pistol.hide()

func world_border():
	global_position = Vector3.ZERO

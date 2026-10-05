extends Node

@export var mob_scene: PackedScene
@export var pu_scene: PackedScene

var score
var mobSpeedBoost = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HUD/TimersLabel.text = "Timers\nStart: " + timeToText($StartTimer) \
		+ "\nMob: " + timeToText($MobTimer) \
		+ "\nScore: " + timeToText($ScoreTimer) \
		+ "\nMessage: " + timeToText($HUD/MessageTimer) \
		+ "\nPower Up: " + timeToText($PowerUpTimer) 

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$PowerUpTimer.stop()
	$HUD.show_game_over()
	$Music.stop()

func new_game():
	# remove any mobs left over the previous game.
	get_tree().call_group("mobs", "queue_free")
	
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	velocity *= mobSpeedBoost
	print(velocity)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_power_up_timer_timeout() -> void:
	var pu = pu_scene.instantiate()
	
	# Choose a random location on Path2D.
	var pu_spawn_location = $MobPath/MobSpawnLocation
	pu_spawn_location.progress_ratio = randf()

	# Set the pu's position to the random location.
	pu.position = pu_spawn_location.position
	# Set the pu's direction perpendicular to the path direction.
	var direction = pu_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	pu.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	pu.linear_velocity = velocity.rotated(direction)
	
	add_child(pu)

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)
	# each time score goes up by 5 speed up mod timer or mob speed
	if score != 0 and score % 5 == 0:
		# new wait time may be <= 0  so use a tmp (timers ignore being set to <=0)
		var newWait = $MobTimer.wait_time - 0.5
		# if mobs are already being relased fast enough then speed them up
		if newWait < 0.5:
			newWait = 0.5
			mobSpeedBoost += 0.1
		$MobTimer.wait_time = newWait
			

func _on_start_timer_timeout():
	$MobTimer.start()
	$PowerUpTimer.start()
	$ScoreTimer.start()
	
func timeToText(timer: Timer) -> String: 
	if timer.is_stopped() :
		return "Stopped"
	#var value = timer.time_left / timer.wait_time
	#var count = roundi(clamp(value, 0.0, 1.0) * 30.0) + 1
	#return "|".repeat(count)
	return "|".repeat(roundi(timer.time_left*10))
	

extends Area2D

signal hit

@export var explosion_scene: PackedScene
@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0


func _on_body_entered(_body):
	if _body.is_in_group("mobs"):
		var ex = explosion_scene.instantiate()
		if $Shield100.visible:
			_body.queue_free()
			$Shield100.hide()
			$ShieldsAt50.play()
			ex.position = _body.position
		elif $Shield50.visible:
			_body.queue_free()
			$Shield50.hide()
			$ShieldsDown.play()
			ex.position = _body.position
		else:
			hide() # Player disappears after being hit.
			hit.emit()
			# Must be deferred as we can't change physics properties on a physics callback.
			$CollisionShape2D.set_deferred("disabled", true)
			$DeathSound.play()
			ex.position = position
		get_tree().root.add_child(ex)
	elif _body.is_in_group("power_ups"):
		_body.queue_free()
		if not $Shield100.visible:
			shieldsUp()
			$ShieldsBackUp.play()
	else:
		print("Entered unknown object.")
		
func shieldsUp():
	$Shield100.show()
	$Shield50.show()

func start(pos):
	position = pos
	$Shield100.hide()
	$Shield50.hide()
	$RedAlert.play() # will call shieldsUp() when finished.
	show()
	$CollisionShape2D.disabled = false
	

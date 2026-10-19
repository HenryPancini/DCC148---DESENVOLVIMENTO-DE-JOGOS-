extends CharacterBody2D
@export var tilemap: TileMapLayer
@export var life:int=25
var moving: bool = false
var current_platform: Area2D = null
var invulnerable
var frog_tween: Tween
@export var water: Area2D
var in_water: bool = false
var contador:int=0
@export var sprite_vector1: Array[Texture2D] = []
@export var sprite_vector2: Array[Texture2D] = []
@export var victory_areas: Array[Area2D] = []
var frog_sprite: Sprite2D
var victory_areas_used: Array[Area2D] = []
var accepting_commands: bool = false
func _physics_process(delta: float) -> void:
	if moving or not accepting_commands:
		return
	var direction = Vector2i.ZERO
	if Input.is_action_just_pressed("move_down"):
		direction = Vector2i.DOWN
	if Input.is_action_just_pressed("move_left"):
		direction = Vector2i.LEFT
	if Input.is_action_just_pressed("move_right"):
		direction = Vector2i.RIGHT
	if Input.is_action_just_pressed("move_up"):
		direction = Vector2i.UP
	if direction != Vector2i.ZERO:
		move_one_cell(direction)


func move_one_cell(direction: Vector2i) -> void:
	if is_instance_valid(current_platform):
		if current_platform.moving_platform.is_connected(_on_platform_moving):
			current_platform.moving_platform.disconnect(_on_platform_moving)
	moving = true
	var local_position = tilemap.to_local(global_position)
	var current_cell = tilemap.local_to_map(local_position)
	var target_cell = current_cell + direction
	target_cell.x = clampi(target_cell.x, -7, 6)
	target_cell.y = clampi(target_cell.y, -4, 9)
	var target_position = tilemap.map_to_local(target_cell)
	var target_global = tilemap.to_global(target_position)
	frog_tween = create_tween()
	frog_tween.tween_property(self, "global_position", target_global, 0.15)
	await frog_tween.finished
	moving = false
	await get_tree().physics_frame
	update_current_platform()
	check_hazard()

func _on_platform_moving(delta_position: Vector2) -> void:
	if current_platform == null:
		return

	global_position += delta_position

	var screen_rect = get_viewport().get_visible_rect()
	var screen_position = get_global_transform_with_canvas() * Vector2.ZERO

	if not screen_rect.has_point(screen_position):
		take_damage()
func take_damage() -> void:
	if invulnerable:
		return
	invulnerable = true
	life -= 1
	moving = false
	if frog_tween and frog_tween.is_running():
		frog_tween.kill()
	global_position = tilemap.to_global(
		tilemap.map_to_local(Vector2i(-1, 8))
	)
	await get_tree().create_timer(1.0).timeout
	invulnerable = false
func _on_water_body_entered(body: Node2D) -> void:
	print("Entrou na água: ", body.name)
	if body == self:
		in_water = true
		print("RÃ DETECTADA NA ÁGUA")

func _on_water_body_exited(body: Node2D) -> void:
	print("Saiu da água: ", body.name)
	if body == self:
		in_water = false


func is_in_water() -> bool:
	if not is_instance_valid(water):
		return false

	var shape_node = water.get_node("CollisionShape2D")
	var rectangle = shape_node.shape as RectangleShape2D

	if rectangle == null:
		return false

	var local_position = shape_node.to_local(global_position)
	var half_size = rectangle.size / 2.0

	return abs(local_position.x) <= half_size.x and abs(local_position.y) <= half_size.y

func check_hazard() -> void:
	var water_now = is_in_water()
	var log_now = is_on_log()

	print("Água: ", water_now, " | Tronco: ", log_now)

	if water_now and not log_now:
		take_damage()
func find_log_under_frog() -> Area2D:
	var frog_shape = $CollisionShape2D

	if frog_shape.shape == null:
		return null

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = frog_shape.shape
	query.transform = frog_shape.global_transform
	query.collision_mask = 0xFFFFFFFF
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = [get_rid()]

	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query, 32)

	for result in results:
		var collider = result["collider"]

		if collider is Area2D and collider.has_signal("moving_platform"):
			return collider

	return null


func update_current_platform() -> void:
	var old_platform = current_platform
	var new_platform = find_log_under_frog()

	if old_platform != new_platform and is_instance_valid(old_platform):
		if old_platform.has_signal("moving_platform"):
			if old_platform.moving_platform.is_connected(_on_platform_moving):
				old_platform.moving_platform.disconnect(_on_platform_moving)

	current_platform = new_platform

	if is_instance_valid(current_platform):
		if not current_platform.moving_platform.is_connected(_on_platform_moving):
			current_platform.moving_platform.connect(_on_platform_moving)


func is_on_log() -> bool:
	return is_instance_valid(find_log_under_frog())
func _ready() -> void:
	frog_sprite=$Sprite2D
	for area in victory_areas:
		if is_instance_valid(area):
			area.body_entered.connect(
				_on_victory_area_body_entered.bind(area)
			)
	await get_tree().create_timer(5.0).timeout
	accepting_commands = true
func _on_victory_area_body_entered(body: Node2D, victory_area: Area2D) -> void:
	if body != self:
		return

	if victory_area in victory_areas_used:
		return

	var sprite_index = contador

	# Altera o sprite do próprio sapo usando sprite_vector1.
	if is_instance_valid(frog_sprite):
		if not sprite_vector1.is_empty():
			frog_sprite.texture = sprite_vector1[
				sprite_index % sprite_vector1.size()
			]
	else:
		push_warning("Atribua o Sprite2D do sapo à variável frog_sprite.")

	# Cria o sprite permanente da área usando sprite_vector2.
	if not sprite_vector2.is_empty():
		var shape_node = victory_area.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D

		var sprite = Sprite2D.new()
		sprite.texture = sprite_vector2[
			sprite_index % sprite_vector2.size()
		]
		sprite.scale = Vector2(0.5, 0.5)
		sprite.z_index = 100

		victory_area.add_child(sprite)

		if shape_node != null:
			sprite.position = shape_node.position
		else:
			sprite.position = Vector2.ZERO
	else:
		push_warning("O vetor sprite_vector2 está vazio.")

	contador += 1
	victory_areas_used.append(victory_area)

	# Interrompe o salto atual, se houver.
	if frog_tween != null and frog_tween.is_running():
		frog_tween.kill()

	moving = false

	# Desconecta o sapo da plataforma anterior.
	if is_instance_valid(current_platform):
		if current_platform.moving_platform.is_connected(
			_on_platform_moving
		):
			current_platform.moving_platform.disconnect(
				_on_platform_moving
			)

	current_platform = null

	# Teleporta o sapo para a posição inicial.
	global_position = tilemap.to_global(
		tilemap.map_to_local(Vector2i(-1, 8))
	)

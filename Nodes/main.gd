extends Node

@export var ball_scene : PackedScene # 打包球的场景 之后方便例化
var cue_ball
const Start_position = Vector2(890,340) # 白球初始位置
const BALL_BOUNCE = 0.9
var ball_images := [] # 存放球的png名字的数组
# Called when the node enters the scene tree for the first time.
const MAX_POWER = 20.0

var taking_shot : bool # 判断是否发射了 发射一次之后要重置

var cue_ball_potted : bool # 检测白球是否入袋
var potted := [] #　存放入袋的球的数组

var score = 0

func _ready() -> void:
	
	new_game()
	
func new_game():
	clear_balls() # 先清理球
	score = 0 
	update_score()
	set_balls()
	set_pockets() # 设置口袋信息
	generate_balls_1()
	set_cue()
	set_bounce(0.9)
	$HUD.hide()
	get_tree().paused = false
	# 实际需要考虑的问题有 线性阻尼 摩擦力 弹力
	


func set_balls():
	for i in range(1,17):
		var ball_image = load(str("res://assets/ball_",i,".png")) # 更具i 调整名字
		ball_images.append(ball_image)

func set_pockets():
	$Table/Pockets.body_entered.connect(potted_ball) # 将口袋 area连接到函数 potted_ball
	
func potted_ball(body):
	# 首先需要检查是否是白球入袋
	if body == cue_ball: # 如果是白球
		cue_ball_potted = true # 设置白球进袋
		remove_cue_ball()
		score -= 1
		
	else: # 正常入洞 显示球的图 需要将节点替换成sprite
		var b = Sprite2D.new()
		add_child(b)
		b.texture = body.get_node("Sprite2D").texture
		potted.append(b) # 传入图像至数组
		b.position = Vector2(50 * potted.size(), 750)
		body.queue_free()
		score += 1
		update_score()
		if potted.size() == 15: # 游戏结束的条件
			game_over()
		
func generate_balls_1():
	var rows = 5 
	var dia = 36 # 每个球的直径像素
	var count = 0
	for col in range (5):
		for row in range (rows):
			var temp_ball = ball_scene.instantiate() # 生成一个球的场景
			temp_ball.position = Vector2(250+col*dia , 267+row*dia+col*dia/2)
			temp_ball.get_node("Sprite2D").texture = ball_images[count]
			count += 1
			add_child(temp_ball)
			
		rows -= 1
		
	reset_cue_ball()

func clear_balls():
	get_tree().call_group("balls","queue_free")
	
	for b in potted :
		potted.erase(b)
		b.queue_free()
	#potted.clear() # 最后将数组清空
	
func remove_cue_ball():
	"""var old = cue_ball
	remove_child(old)
	old.queue_free()"""
	cue_ball.queue_free()
	$Cue.cueball_position = Start_position
	
func reset_cue_ball():
	cue_ball = ball_scene.instantiate()
	cue_ball.position = Start_position
	cue_ball.get_node("Sprite2D").texture = ball_images[15] # 设置白球的图像
	
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = BALL_BOUNCE   # 根据需要调整弹性
	cue_ball.physics_material_override = physics_material
	
	add_child(cue_ball)
	taking_shot = false # 初始设置为没有发射
	
func set_cue():
	$Cue.position = cue_ball.position
	#$Cue.rotation_degrees = 180
	$Cue.set_process(true)
	$Cue.show()
	
func hide_cue():
	$Cue.hide()
	# 同时需要真正禁用球杆
	$Cue.set_process(false)
	
func set_bounce(k): # 将弹力值k传给球 
	for ball in get_tree().get_nodes_in_group("balls"):
		var physics_material = PhysicsMaterial.new()
		# 设置物理材料的属性，例如摩擦力和弹性
		#physics_material.friction = 0.5  # 根据需要调整摩擦力
		physics_material.bounce = BALL_BOUNCE   # 根据需要调整弹性
		
		ball.physics_material_override = physics_material
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	# 时时刻刻给杆传球的位置
	
	
	var is_moving = false
	#接下来需要访问所有的球判断是否都停下 但是由于它们没有存在数组中难以直接访问，所以接下来到ball场景中建立group
	for b in get_tree().get_nodes_in_group("balls"):
		if b.linear_velocity.length() >= 5:
			is_moving = true
			
	#接下来判断停和不停的情况
	if is_moving:
		if taking_shot: # 且正在进行射击 就取消射击 并且不显示球杆
			taking_shot = false 
			hide_cue()
	else:
		if cue_ball_potted:
			reset_cue_ball()
			cue_ball_potted = false
			
		if not taking_shot:
			taking_shot = true 
			set_cue()
		# 同时 需要检查白球是否进洞

			
	if cue_ball != null and cue_ball.position != null :
		$Cue.cueball_position = cue_ball.position
	
	
	
	
	
func _on_cue_shoot(power) -> void:
	cue_ball.apply_central_impulse(power) # 利用白球是rigidbody的特性，施加力量
 
func update_score():
	$Score.text= "score: " + str(score)
	$PlayerUI/Panel/Label2.text = "score: " + str(score)

func game_over():
	# 首先隐藏球杆等
	hide_cue()
	get_tree().paused = true # 暂停
	$HUD.show()
	


func _on_restart_button_pressed():
	new_game()

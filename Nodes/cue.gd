extends Sprite2D
var power = 0 # 力度
var operate_type = 1# 球杆的操作方式
# 在这个脚本中实现对球杆的控制
# Called when the node enters the scene tree for the first time.

var cueball_position = Vector2(890,340) #白球的位置
var dir # 发射的方向
var power_dir = 1
var MAXPOWER
signal shoot
func _ready() -> void:
	global_position = cueball_position
	MAXPOWER = get_parent().MAX_POWER
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position() # 获取鼠标位置
	dir =  mouse_pos - cueball_position
	
	if operate_type == 0:
		look_at(mouse_pos) # 旋转cue使其指向鼠标的位置
	elif operate_type == 1: # 指向鼠标和白球的连线 
		var angle = atan2(dir.x , dir.y)
		var angle_degrees = rad_to_deg(angle)
		rotation_degrees = -90 - angle_degrees
		
	# 力量是增长还是变小
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) : #按下 左键
		if power >= MAXPOWER: #  大于限制
			power_dir = -1 # 状态为-
		elif power <= 0 : # 状态为+
			power_dir = 1
		
		power += 0.1 * power_dir
		print(power)
	else :
		if power>0:
			
			shoot.emit(power * -dir) # 发射信号 传出二维向量
			power = 0
			power_dir = 1
	

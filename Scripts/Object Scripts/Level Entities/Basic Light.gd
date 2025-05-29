extends Entity

const args_list : Dictionary = {}

func MapArgs(args : Dictionary) -> int:
	var clr = args[1]
	if clr: self.color = clr
	
	var lum = args[2]
	if lum: self.energy = lum
	
	var height = args[3]
	if height: self.height = height
	
	var scl = args[4]
	if scl: self.texture_scale = scl
	
	return 0

func GetArgs() -> Dictionary:
	return {
		1:self.color,
		2:self.energy,
		3:self.height,
		4:self.texture_scale
	}

extends Entity

const args_list : Dictionary = {}

func MapArgs(args : Dictionary) -> int:
	var clr = args["clr"]
	if clr: self.color = clr
	
	var lum = args["lum"]
	if lum: self.energy = lum
	
	var height = args["height"]
	if height: self.height = height
	
	var scl = args["scl"]
	if scl: self.texture_scale = scl
	
	return 0

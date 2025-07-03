extends Entity

const args_list : Dictionary = {}

func MapArgs(args : Dictionary) -> int:
	var clr = args["clr"]
	if clr: self.color = clr
	
	var lum = args["lum"]
	if lum: self.energy = lum
	
	var vrt = args["vrt"]
	if vrt: self.height = vrt
	
	var scl = args["scl"]
	if scl: self.texture_scale = scl
	
	return 0

func GetArgs() -> Dictionary:
	return {
		"clr":self.color,
		"lum":self.energy,
		"vrt":self.height,
		"scl":self.texture_scale
	}

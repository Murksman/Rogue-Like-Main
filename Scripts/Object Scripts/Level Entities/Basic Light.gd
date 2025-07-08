extends Entity

const args_list : Dictionary = {}

func MapArgs(args : Dictionary) -> int:
	var clr = args["color"]
	if clr: self.color = clr
	
	var lum = args["energy"]
	if lum: self.energy = lum
	
	var vrt = args["height"]
	if vrt: self.height = vrt
	
	var scl = args["scale"]
	if scl: self.texture_scale = scl
	
	return 0

func GetArgs() -> Dictionary:
	return {
		"color":self.color,
		"energy":self.energy,
		"height":self.height,
		"scale":self.texture_scale
	}

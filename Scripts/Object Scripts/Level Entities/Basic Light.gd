extends Entity

const args_list : Dictionary = {}

func MapArgs(args : Dictionary) -> int:
	var clr = args.get("clr")
	if clr: self.color = clr
	
	var lum = args.get("lum")
	if lum: self.energy = lum
	
	var height = args.get("height")
	if height: self.height = height
	
	var scl = args.get("scl")
	if scl: self.texture_scale = scl
	
	return 0

func GetArgs() -> Dictionary:
	return {
		"clr":self.color,
		"lum":self.energy,
		"height":self.height,
		"scl":self.texture_scale
	}

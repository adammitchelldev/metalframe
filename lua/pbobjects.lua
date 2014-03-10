function _pb.createObject(index, parent, name)
	if type(parent) == "table" then
		OBJECTS[index] = _pb.deepcopy(parent)
	elseif type(OBJECTS[parent]) == "table" then
		OBJECTS[index] = _pb.deepcopy(OBJECTS[parent])
	else
		OBJECTS[index] = {}
	end
	OBJECTS[index].index = index
	OBJECTS[index].id = index
	OBJECTS[index].name = name or index
	return OBJECTS[index]
end
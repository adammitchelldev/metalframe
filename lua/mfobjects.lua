function _mf.createObject(index, parent, name)
	if type(parent) == "table" then
		OBJECTS[index] = _mf.deepcopy(parent)
	elseif type(OBJECTS[parent]) == "table" then
		OBJECTS[index] = _mf.deepcopy(OBJECTS[parent])
	else
		OBJECTS[index] = {}
	end
	OBJECTS[index].index = index
	OBJECTS[index].id = index
	OBJECTS[index].name = name or index
	return OBJECTS[index]
end
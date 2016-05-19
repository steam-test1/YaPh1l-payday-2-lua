PropertyManager = PropertyManager or class()
function PropertyManager:init()
	self._properties = {}
end
function PropertyManager:add_property(prop, value)
	self._properties[prop] = value
end
function PropertyManager:get_property(prop)
	return self._properties[prop]
end
function PropertyManager:has_property(prop)
	if self._properties[prop] then
		return true
	end
	return false
end

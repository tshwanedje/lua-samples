-- TshwaneLua Filter script for TLex or tlTerm.
-- Return true if entry has empty cross-reference nodes.

local function CheckForEmptyReferences(NODE)
	-- Check if NODE is a special cross-references node? (tcReferences)
	if NODE:IsKindOfClass(NODE_REFERENCES) then
		-- Typecast 'NODE' to a tcReferences
		local Reference = tolua.cast(NODE, "tcReferences");
		if Reference:GetNumRefEntries() == 0 then
			return 1;
		end
	end

	-- Recurse through child nodes
	local NUM = NODE:GetNumChildren();
	if NUM > 0 then
		local i;
		for i=0,NUM-1,1 do
			local EmptyRefsOnDescendants = CheckForEmptyReferences(NODE:GetChild(i));
			if EmptyRefsOnDescendants > 0 then
				return 1;
			end
		end
	end
	return 0;
end


local HasEmptyRefs = CheckForEmptyReferences(gCurrentEntry);
if HasEmptyRefs > 0 then
	return 1;
end
return 0;

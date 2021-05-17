-- TshwaneLua Filter script for TLex or tlTerm

-- Return true if entry has modified flag set
if gCurrentEntry:HasChanged() then
	return 1;
end
return 0;

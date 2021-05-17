-- TshwaneLua Filter script for TLex/tlTerm/tlDatabase
-- Filter for only those entries that are visible (not masked out) in the current styleset
local Document = tApp():GetCurrentDoc();
local Styles = Document:GetCurrentStyles();
if tIsMasked(gCurrentEntry,Styles) then
	return 0;
end
return 1;

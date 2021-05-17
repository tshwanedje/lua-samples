local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end
tMoveAllToGrandparent(DOC, "definition", "TE");
tMoveAllToGrandparent(DOC, "definition", "example");

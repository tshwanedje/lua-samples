local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end
tReplaceElementInPlace(DOC, "combination", "Combination");

local DOC = tApp():GetCurrentDoc();
local DTD = DOC:GetDTD();
local L = DTD:FindElementByName("Lemma");
local P = L:FindAttributeByName("PartOfSpeech");
local list = DTD:FindListByName("Part of speech");
P:SetList(nil);


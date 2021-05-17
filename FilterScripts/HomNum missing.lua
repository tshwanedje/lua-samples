-- TLex "Filter Plugin" script to help find cases where the TLex automatic HomNum has somehow gone missing
-- (this doesn't usually happen, but may in some unusual circumstances)

-- Find entries that look like they 'should be' homonyms, but aren't
local LANG = tGetNodeSection(gCurrentEntry);
local LS=gCurrentEntry:GetLemmaSign();
local i=gCurrentEntry:FindOurIndex();
if (i>0) then
 if (LANG:GetEntry(i-1):GetLemmaSign()==LS and gCurrentEntry:GetHomNum()==0) then
  return 1;
 end
end

if (i<LANG:GetNumEntries()-1) then
 if (LANG:GetEntry(i+1):GetLemmaSign()==LS and gCurrentEntry:GetHomNum()==0) then
  return 1;
 end
end

return 0;

-- Check homonym numbers are correct [dj2018-02]

-- We need to find:
	-- Cases where there should be a homnum but isn't
	-- Cases where there shouldn't be a homnum but is
	-- Cases where the homnum ordering is wrong

local LANG = tGetNodeSection(gCurrentEntry);
local n = gCurrentEntry:FindOurIndex();
local LSp=''--LemmaSign previous
local np=0;--HomNum previous
if (n>0) then
	LSp = LANG:GetEntry(n-1):GetLemmaSign();
	np = LANG:GetEntry(n-1):GetHomNum();
end

-- If current entry lemmasign same as previous, then our homnum must be 1 greater than the previous entry's.
if gCurrentEntry:GetLemmaSign()==LSp then
	if gCurrentEntry:GetHomNum()~=np+1 then
		return 1;
	else
		return 0;
	end
else
	local LSn='';--LemmaSign next
	local nn=0;--HomNum next
	if (n<LANG:GetNumEntries()-1) then
		LSn = LANG:GetEntry(n+1):GetLemmaSign();
		nn = LANG:GetEntry(n+1):GetHomNum();
	end

	--Previous entry's lemmasign different to previous.
	--In this case, our HomNum must either be 0 if (NEXT lemmasign
	--different also to ours), or 1 (if NEXT lemmasign same as ours)
	if gCurrentEntry:GetLemmaSign()~=LSn then
		if gCurrentEntry:GetHomNum()~=0 then
			return 1;
		else
			return 0;
		end
	else
		if gCurrentEntry:GetHomNum()~=1 then
			return 1;
		else
			return 0;
		end
	end
end

return 0;

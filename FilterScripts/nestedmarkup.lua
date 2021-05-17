-- GLOBAL
Stack = {}
-- Create a Table with stack functions
function Stack:Create()
  -- stack table
  local t = {}
  -- entry table
  t._et = {}
  -- push a value on to the stack
  function t:push(x)
    if x then
        table.insert(self._et, x)
    end
  end
  function t:top()
	if table.getn(self._et) ~= 0 then
		return self._et[table.getn(self._et)]
	end
	return nil;
  end
  -- pop a value from the stack
  function t:pop(num)
    -- get num values from stack
    local num = num or 1
    -- return table
    local entries = {}
    -- get values into entries
    for i = 1, num do
      -- get last entry
      if table.getn(self._et) ~= 0 then
        table.insert(entries, self._et[table.getn(self._et)])
        -- remove last value
        table.remove(self._et)
      else
        break
      end
    end
    -- return unpacked entries
    return unpack(entries)
  end
  -- get number of entries
  function t:getn()
    return table.getn(self._et)
  end
    return t;
end


function ValidateBracketSyntax(String)
	-- create stack
		local stack = Stack:Create()
		while stack:getn() > 0 do
			stack:pop(1);
		end

	for i=0,string.len(String),1 do
		if string.sub(String,i,i) == '%' then
			if i == string.len(String) then
				--return 1;
			else
				if string.sub(String,i+1,i+1) == '%' then
				elseif string.sub(String,i+1,i+1) == 'n' then
				elseif string.sub(String,i+1,i+1) == 'b' then
					if stack:top() == "b" then
						stack:pop(1);
					else
						stack:push("b");
					end
				elseif string.sub(String,i+1,i+1) == 'B' then
					if stack:top()== "B" then
						stack:pop(1);
					else
						stack:push("B");
					end
				elseif string.sub(String,i+1,i+1) == 'i' then
					if stack:top()== "i" then
						stack:pop(1);
					else
						stack:push("i");
					end
				elseif string.sub(String,i+1,i+1) == 'I' then
					if stack:top()== "I" then
						stack:pop(1);
					else
						stack:push("I");
					end
				elseif string.sub(String,i+1,i+1) == 'u' then
					if stack:top()== "u" then
						stack:pop(1);
					else
						stack:push("u");
					end
				elseif string.sub(String,i+1,i+1) == 'r' then
					if stack:top()== "r" then
						stack:pop(1);
					else
						stack:push("r");
					end
				elseif string.sub(String,i+1,i+1) == 'l' then
					if stack:top()== "l" then
						stack:pop(1);
					else
						stack:push("l");
					end
				elseif string.sub(String,i+1,i+1)== 'k' then
					if stack:top()== "k" then
						stack:pop(1);
					else
						stack:push("k");
					end
				elseif string.sub(String,i+1,i+1) == 's' then
					if stack:top()== "s" then
						stack:pop(1);
					else
						stack:push("s");
					end
				else
					--comment this line out if you are only interested in markup that will break XML export.
					--the below will filter all occurances of "%" instead of "%%" which are not technically harmful to an export...
					--return 1;
				end
			end
		end
	end
	if stack:getn() > 0 then
		return 1;
	end
	return 0;
end


function ErrorCheck(Node)
	if Node:IsClass(NODE_TEXTNODE) then
		local s = tolua.cast(Node, "tcText")
		local Val = "";
		Val = s:GetText();
		if ValidateBracketSyntax(Val) == 1 then
			return 1;
		end
	else
		for i = 0,Node:GetNumAttributes()-1,1 do
			local Attribute = Node:GetAttributeDescriptor(i);
			local Val = "";
			if Attribute:GetType() == ATTR_CDATA then
				Val = Node:GetAttributeDisplayAsString(Attribute);
				if ValidateBracketSyntax(Val) == 1 then
					return 1;
				end
			end
		end
	end
	for i = 0,Node:GetNumChildren()-1,1 do
		if ErrorCheck(Node:GetChild(i)) == 1 then
			return 1;
		end
	end
	return 0;
end

return ErrorCheck(gCurrentEntry);

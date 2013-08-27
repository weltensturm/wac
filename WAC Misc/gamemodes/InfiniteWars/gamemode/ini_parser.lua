
--[[
	INI-Parser to parse .ini files and read out the data
	Copyright (C) 2007-2009  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

--##### string this part is taken from lib.lua
if StarGate then return end
StarGate={String={}}
local function explode(s,sep)
	if(not s) then return s end; -- Fixes issues when giving nil-values
	local sep = sep or " "; -- Fixes issues when giving nil-values
	local t = {};
	if(sep == "") then -- Stops infinite loops
		for i=1,s:len() do
			table.insert(t,s:sub(i,i));
		end
	else
	 	local pos = 0;
		for k,v in function() return s:find(sep,pos,true) end do -- for each divider found
			table.insert(t,s:sub(pos,k-1)); -- Attach chars left of current divider
			pos = v + 1;-- Jump past current divider
		end
		table.insert(t,s:sub(pos)) -- Attach chars right of last divider
	end
	return t;
end
string.explode = explode; -- Our function, which can be run as MyString:explode()
string.Explode = function(sep,s) return explode(s,sep) end; -- Enhances garry's explode function

function StarGate.String.TrimExplode(s,sep)
	if(sep and s:find(sep)) then
		if(type(s) == "string") then
			s=s:gsub("^[%s]+","");
		end
		local r = explode(s,sep);
		for k,v in pairs(r) do
			if(type(v) == "string") then
				r[k] = v:Trim();
			end
		end
		return r;
	else
		return {s};
	end
end
string.TrimExplode = StarGate.String.TrimExplode; --##### string end

INIParser = {};
-- ############## Loads an ini file (object) @ aVoN
function INIParser:new(file_,no_autotrim)
	local obj = {};
	setmetatable(obj,self);
	self.__index = function(t,n)
		local nodes = rawget(t,"nodes");
		if(nodes) then
			if(nodes[n]) then
				return nodes[n];
			end
		end
		return self[n]; -- Returns self or the nodes if directly indexed
	end
	if(file.Exists(file_)) then
		obj.file = file_;
		obj.notrim = no_autotrim;
		obj.content = file.Read(file_); -- Saves raw content of the file
		obj.nodes = {}; -- Stores all nodes of the ini
	else
		Msg("INIParser:new - File "..file_.." does not exist!\n");
		return;
	end
	obj:parse();
	return obj;
end

-- ############## Strips comments from a line(string) @ aVoN
function INIParser:StripComment(line)
	local found_comment = line:find("[;#]");
	if(found_comment) then
		line = line:sub(1,found_comment-1):Trim(); -- Removes any non neccessayry stuff
	end
	return line;
end

-- ############## Strips quotes from a string (when an idiot added them...) (string) @ aVoN
function INIParser:StripQuotes(s)
	-- Replaces accidently added quotes from alphanumerical strings
	return s:gsub("^[\"'](.+)[\"']$","%1"); --" <-- needed, to make my NotePad++ to show the functions below
end

-- ############## Parses the inifile to a table (void) @ aVoN
function INIParser:parse()
	local exploded = string.Explode("\n",self.content);
	local nodes = {};
	local cur_node = "";
	local cur_node_index = 1;
	for k,v in pairs(exploded) do
		local line = self:StripComment(v):gsub("\n","");
		if(line ~= "") then -- Only add lines with contents (no commented lines)
			if(line:sub(1,1) == "[") then -- Holy shit, it's a node
				local node_end = line:find("%]");
				if(node_end) then
					local node = line:sub(2,node_end-1); -- Get single node name
					nodes[node] = nodes[node] or {};
					cur_node = node;
					cur_node_index = table.getn(nodes[node])+1;
				else
					Msg("INIParser:parse - Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": Expected node!\n");
					self = nil;
					return;
				end
			else
				if(cur_node == "") then
					Msg("INIParser:parse - Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": No node specified!\n");
					self = nil;
					return;
				else
					local data = string.Explode("=",line);
					-- This is needed, because garry missed to add a limit to string.Explode
					local table_count = table.getn(data);
					if(table_count > 2) then
						for k=3,table_count do
							data[2] = data[2].."="..data[k];
							data[k] = nil;
						end
					end
					if(table_count == 2) then
						local key = ""
						local value = ""
						if(self.notrim) then
							key = self:StripQuotes(data[1]);
							value = self:StripQuotes(data[2]);
						else
							key = self:StripQuotes(data[1]):Trim();
							value = self:StripQuotes(data[2]):Trim();
						end
						nodes[cur_node][cur_node_index] = nodes[cur_node][cur_node_index] or {};
						nodes[cur_node][cur_node_index][key] = value;
					else
						Msg("INIParser:parse - Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": No datablock specified!\n");
						self = nil;
						return;
					end
				end
			end
		end
	end
	self.nodes = nodes;
	Msg("INIParser:parse - File "..self.file.. " successfully parsed\n");
end

-- ############## Either you index the object directly, when you know, which value to index, or you simply get the full INI content (table) @ aVoN
function INIParser:get()
	return self.nodes;
end

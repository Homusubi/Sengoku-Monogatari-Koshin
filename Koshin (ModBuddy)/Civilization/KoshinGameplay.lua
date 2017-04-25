include("Civ6Common");
include("SupportFunctions");

-- // -----------------------------------------------
-- // Constants
-- // -----------------------------------------------
local KOSHIN_CIVILIZATION:string = "CIVILIZATION_KOSHIN";
local KOSHIN_ADJACENT_HEAL_AMOUNT:number = 5;

-- // -----------------------------------------------
-- // Variables
-- // -----------------------------------------------
local m_LocalPlayer:table;
local m_LocalPlayerID:number;
local m_PlayerUnitLocations:table = {};

-- // -----------------------------------------------
-- // MilitaryUnit object
-- // -----------------------------------------------
local PlayerUnit:table = 
{
	Player={},
	Unit={},
	X=0,
	Y=0
};

function PlayerUnit:new(obj)

	obj = obj or {};
	setmetatable(obj, self);
	self.__index = self;

	return obj;
end

-- // -----------------------------------------------
-- // Functions
-- // -----------------------------------------------
function PopulatePlayerUnitLocations(player:table)

	m_PlayerUnitLocations = {};

	for u, unit in player:GetUnits():Members() do
		print("unit name=" .. unit:GetName());
		print("unit X=" .. unit:GetX());
		print("unit Y=" .. unit:GetY()); 
	
		table.insert(m_PlayerUnitLocations, PlayerUnit:new
		{
			Player=player, 
			Unit=unit, 
			X=unit:GetX(), 
			Y=unit:GetY()
		});
	end
	
	if (m_PlayerUnitLocations ~= nil) then
		print("units in collection=" .. #m_PlayerUnitLocations);
	else
		print("units in collection=0");
	end

end

function HealUnits(player:table)

	for u, unit in player:GetUnits():Members() do
		
		-- check if the unit is currently damaged
		if (unit:GetDamage() > 0) then
		
			-- get the number of units adjacent to this unit and calculate the heal amount
			local numberOfUnits:number = GetNumberOfAdjacentUnits(player, unit:GetX(), unit:GetY());
			local healAmount:number = numberOfUnits * KOSHIN_ADJACENT_HEAL_AMOUNT;

			if (healAmount > 0) then
				unit:SetDamage(unit:GetDamage() - healAmount);
			end

		end
	end

end

function GetNumberOfAdjacentUnits(player:table, x:number, y:number)

	local numberOfUnits:number = 0;

	-- check the 6 tiles around the specified plot location for friendly military units
	-- we move around the unit in a clockwise rotation, starting at top right
	
	-- the coordinates change based on the centre plot's x and y
	if (math.fmod(y, 2) == 0) then
		-- even numbered row
		if (IsUnitInPlot(player, x, y+1)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x+1, y)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x, y-1)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x-1, y-1)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x-1, y)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x-1, y+1)) then numberOfUnits = numberOfUnits + 1; end
	else
		-- odd numbered row
		if (IsUnitInPlot(player, x+1, y+1)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x+1, y)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x+1, y-1)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x, y-1)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x-1, y)) then numberOfUnits = numberOfUnits + 1; end
		if (IsUnitInPlot(player, x, y+1)) then numberOfUnits = numberOfUnits + 1; end
	end

	return numberOfUnits;
end

function IsUnitInPlot(player:table, x:number, y:number)

	local result:boolean = false;
	
	-- ensure that the tile exists based on the x and y
	if (x >= 0 and y >= 0) then
	
		for u, unit in ipairs(m_PlayerUnitLocations) do
			if (unit.X == x and unit.Y == y) then
				result = true;
				break;
			end
		end
		
	end

	return result;
end

-- // -----------------------------------------------
-- // Event Handlers
-- // -----------------------------------------------
function OnLocalPlayerTurnBegin()

	for p, player in ipairs(PlayerManager:GetAliveMajors()) do
		if (player:GetID() == m_LocalPlayerID) then
			local playerConfig:table = PlayerConfigurations[player:GetID()];
	
			if (playerConfig:GetCivilizationTypeName() == KOSHIN_CIVILIZATION) then
				PopulatePlayerUnitLocations(player);
				HealUnits(player);
			end	
		end
	end

end

-- // -----------------------------------------------
-- // Init
-- // -----------------------------------------------
function Initialize()

	m_LocalPlayer = Players[Game.GetLocalPlayer()];
	m_LocalPlayerID = m_LocalPlayer:GetID();

	Events.LocalPlayerTurnBegin.Add(OnLocalPlayerTurnBegin);
	print("KoshinGameplay.lua initialized!");
	
end
Initialize();
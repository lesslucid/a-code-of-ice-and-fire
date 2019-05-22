--lua starter package


math.randomseed(os.time())

-- ** Global data governing game state ** 


--not currently relevant
mineSpotTable = {}


--1 gold, 2 income, 3 opponentGold, 4 opponentIncome 
financialsTable = {}


mapTable = {}


--owner, buildingType, x, y [2 entries]
buildingsTable = {}


--owner, unitId, level, x, y
--0 is owned, 1 is enemy
unitsTable = {}

ordersGlobal = "WAIT; MSG no orders given;"


--helper functions   


function countMyUnits()
   count = 0 
   
   for k,v in ipairs(unitsTable) do
       if v[1] == 0 then
          count = count + 1 
       end
   end
   
   return count
end


function moveAllDiagonal()
   --owner, unitId, level, x, y
   for k,v in ipairs(unitsTable) do
      if v[1] == 0 then
         ordersGlobal = ordersGlobal .. "MOVE " .. unitsTable[k][2]
         ordersGlobal = ordersGlobal .. " " .. unitsTable[k][4]+1 .. " "
         ordersGlobal = ordersGlobal .. unitsTable[k][5]+1 .. ";"
         
      end
   end
end

function randomWalkAll()
    --owner, unitId, level, x, y
    for k,v in ipairs(unitsTable) do
       if v[1] == 0 then
          ordersGlobal = ordersGlobal .. "MOVE " .. unitsTable[k][2]
          local xadd = threeOptions()
          if xadd + unitsTable[k][4] < 0 then
              xadd = 1
          end
          ordersGlobal = ordersGlobal .. " " .. unitsTable[k][4]+xadd .. " "
          local yadd = threeOptions() 
          if yadd + unitsTable[k][5] < 0 then
              yadd = 1
          end
          ordersGlobal = ordersGlobal .. unitsTable[k][5]+yadd .. ";"
       end
    end
    
end


function threeOptions()
   rval = 0 
   roll = math.random(3)
   rval = rval + roll - 2
   return rval
end


function basicTraining()
    --owner, buildingType, x, y
    for k, v in ipairs(buildingsTable) do
        if v[1] == 0 and v[2] == 0 then
            buildNear(buildingsTable[k][3], buildingsTable[k][4])
        end
    end
        
end


function buildNear(x, y)
   if x == 0 and y == 0 then 
       ordersGlobal = ordersGlobal .. "TRAIN 1 0 1;"
   elseif x == 11 and y == 11 then 
       ordersGlobal = ordersGlobal .. "TRAIN 1 11 10;"
   elseif x == 0 and y == 11 then 
       ordersGlobal = ordersGlobal .. "TRAIN 1 1 11;"
   elseif x == 11 and y == 0 then
       ordersGlobal = ordersGlobal .. "TRAIN 1 11 1;"
   else
       ordersGlobal = ordersGlobal .. "TRAIN " .. string(x+1) .. " " .. string(y) .. ";"
   end
end


function analyseGameState()
  
  ordersGlobal = ""
  
  if financialsTable[1] > 14 and financialsTable[2] > 0 then
    --ordersGlobal = "TRAIN 1 0 1;"
    basicTraining()
  else
    --ordersGlobal = ""  
  end
  
  if countMyUnits() > 0 then
     --moveAllDiagonal() 
     randomWalkAll()
  end
  
  
end


function giveOrders()

  orders = ""  

  orders = ordersGlobal
  
  if orders[#orders-1] == ";" then
    orders = orders:sub(1, #orders-1)
  end


  if orders == "" or orders == ";" then
    orders = "WAIT; MSG no orders received"
  end
  
  print(orders)
  
  ordersGlobal = ""
  
end




--initialization loop  

numberMineSpots = tonumber(io.read())
for i=1,numberMineSpots do
    next_token = string.gmatch(io.read(), "[^%s]+")
    x = tonumber(next_token())
    y = tonumber(next_token())
    mineSpotTable[i] = {x, y}
end

-- game loop
while true do
    gold = tonumber(io.read())
    income = tonumber(io.read())
    opponentGold = tonumber(io.read())
    opponentIncome = tonumber(io.read())
    
    financialsTable = {gold, income, opponentGold, opponentIncome}
    
    for i=1,12 do
        line = io.read()
	mapTable[i] = line
    end
    
    buildingCount = tonumber(io.read())
    
    for i=1,buildingCount do
        next_token = string.gmatch(io.read(), "[^%s]+")
        owner = tonumber(next_token())
        buildingType = tonumber(next_token())
        x = tonumber(next_token())
        y = tonumber(next_token())
	
        buildingsTable[i] = {owner, buildingType, x, y}
	
    end
    
    unitCount = tonumber(io.read())
    
    for i=1,unitCount do
        next_token = string.gmatch(io.read(), "[^%s]+")
        owner = tonumber(next_token())
        io.stderr:write(owner)
        unitId = tonumber(next_token())
        level = tonumber(next_token())
        x = tonumber(next_token())
        y = tonumber(next_token())
	--owner, unitId, level, x, y
	
	   unitsTable[i] = {owner, unitId, level, x, y}
--	io.stderr:write("unitID" .. string(unitsTable[i][2]) .. "\n")
    end
    
    -- Write an action using print()
    -- To debug: io.stderr:write("Debug message\n")

--    io.stderr:write(string(unitsTable[1][1]) .. "debugging\n")
    
    analyseGameState()
    giveOrders()
    
    
    
end








--[[

instructions from the site:  

Game Input
Initialization input

Line 1: one integer numberMineSpots: the number of mine spots on the map. Mine spots will be used from Wood1 league onwards.
Next numberMineSpots lines: two integers

    x and y: coordinates of the mine spot.

Game turn input

Line 1: an integer gold, the player's amount of gold.

Line 2: an integer income, the player's income.

Line 3: an integer opponentGold, the opponent's amount of gold.

Line 4: an integer opponentIncome: the opponent's income.

Next 12 lines: 12 characters, on for each cell:

    #: void
    .: neutral
    O: owned and active cell
    o: owned and inactive
    X: active opponent cell
    x: inactive opponent cell

Next line: buildingCount: the amount of buildings on the map.

Next buildingCount lines: four integers

    owner
        0: Owned
        1: Enemy
    buildingType: the type of building
        0: HQ
    x and y: the building's coordinates.

Next line:unitCount: the amount of units on the map.

Next unitCount lines: five integers

    owner
        0: Owned
        1: Enemy
    unitId: this unit's unique id
    level: always 1 (only in this league).
    x and y: the unit's coordinates.

Output
A single line being a combination of these commands separated by ;

    MOVE id x y
    TRAIN level x y where level can only be 1
    WAIT to do nothing.

You can add a message to display in the viewer by appending the command MSG my message.
Example: "MOVE 1 2 3; TRAIN 3 3 3; MOVE 2 3 1; MSG Team Fire"
Constraints
Allotted response time to output is <= 50ms.
Allotted response time to output on the first turn is <= 1000ms. 






]]



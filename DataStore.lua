local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remote = ReplicatedStorage:WaitForChild('Remotes')
local Module = ReplicatedStorage:WaitForChild('Module')
local AutoSave = {}

local MainKey = 'BetaTest'
local ClientKey = 'BetaTest'
local DataStore2 = require(game.ServerScriptService.DataStore2)

local Data = {}

Data.PlayerData = {}

function Data.new(Player)
    local PData = {}

    PData.BaseSettings = {
        --- table
    }

    Data.PlayerData[Player.Name] = PData
    return Data
end

function Data:DataCheckWorking(Player)
    if RunService:IsServer() then
        return Data.PlayerData[Player.Name]
    else
        return Remote.GetDataSave:InvokeServer()
    end
end

function LoadData(Client)
    local PData = Data.new(Client)
    local DataStorage = DataStore2(ClientKey, Client):GetTable(PData)
    --PrintData(Client)
    DataStore2.Combine(MainKey,ClientKey)
    PData = GetDataTableFromDataStorage(Client,DataStorage)
    AutoSave[Client.Name] = Client
end

function GetDataTableFromDataStorage(Client, DataStorage)
    local PData = Data:Get(Client)

    for i, v in pairs(DataStorage.BaseSettings) do
        PData.BaseSettings[i] = DataStorage.BaseSettings[i]
    end
end

function SaveData(Client, PData)
    DataStore2(ClientKey, Client):Set(PData)
    PrintData(Client)
end

function PrintData(Client)
    local PData = Data:Get(Client)
    print(PData)
end
do
    Players.PlayerAdded:Connect(LoadData)

    Players.PlayerRemoving:Connect(function(Client)
        SaveData(Client, Data:Get(Client))
        AutoSave[Client.Name] = nil
        PrintData(Client)
    end)

    Remote.GetDataSave.onServerInvoke = function(Client)
        local PData = Data:Get(Client)
        return PData
    end
end

local TotalDelta = 0
task.spawn(function()
    while task.wait(1) do
        TotalDelta += 1
        if TotalDelta > 3 then
            TotalDelta = 0
            for _, Plr in pairs(AutoSave) do
                local PData = Data:Get(Plr)
                SaveData(Plr, PData)
            end
        end
    end
end)


return Data
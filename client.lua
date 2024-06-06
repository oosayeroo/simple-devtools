local QBCore = exports['qb-core']:GetCoreObject()
local CurObject = {
    ID = nil,
    Alpha = 255,
    OnGround = false,
    OnBone = false,
}
local TestSpawn = {
    ID = nil,
}
local Coords = {
    x = 0.0,
    y = 0.0,
    z = 0.0,
}
local Rotation = {
    x = 0.0,
    y = 0.0,
    z = 0.0,
}
local Tolerance = 3
local SayerDevMode = false
local EntityViewEnabled  = false
local EntityFreeAim = false
local FreeAimEntity = nil

local function GetGroundMaterial()
    local ped = PlayerPedId()

    local playerCoord = GetEntityCoords(ped)
    local target = GetOffsetFromEntityInWorldCoords(ped, vector3(0,2,-3))
    local testRay = StartShapeTestRay(playerCoord, target, 17, ped, 7) -- This 7 is entirely cargo cult. No idea what it does.
    local _, hit, hitLocation, surfaceNormal, material, _ = GetShapeTestResultEx(testRay)

    print("hit: "..hit)
    if hit == 1 then
        print('Material: '..material)
        -- print('Hit location: '..hitLocation)
        -- print('Surface normal: '..surfaceNormal)
        
    end
end

local RotationToDirection = function(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

local RayCastGamePlayCamera = function(distance)
    -- Checks to see if the Gameplay Cam is Rendering or another is rendering (no clip functionality)
    local currentRenderingCam = false
    if not IsGameplayCamRendering() then
        currentRenderingCam = GetRenderingCam()
    end

    local cameraRotation = not currentRenderingCam and GetGameplayCamRot() or GetCamRot(currentRenderingCam, 2)
    local cameraCoord = not currentRenderingCam and GetGameplayCamCoord() or GetCamCoord(currentRenderingCam)
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, b, c, _, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

StartEntityView = function()
    GroundCam = true
    CreateThread(function()
        while GroundCam do
            Wait(0)
            local playerPed    = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            if EntityFreeAim then
                local color = { r = 0, g = 0, b = 255, a = 200 }
                local position = GetEntityCoords(playerPed)
                local hit, coords, entity = RayCastGamePlayCamera(1000.0)
                -- If entity is found then verify entity
                if IsControlJustReleased(0, 38) then -- Copy Coords
                    local x = QBCore.Shared.Round(coords.x, 2)
                    local y = QBCore.Shared.Round(coords.y, 2)
                    local z = QBCore.Shared.Round(coords.z, 2)
                    print("SAYER DEV TOOLS");
                    print("Location = X: " .. x .. " Y: " .. y .. " Z: " .. z)
                    print("Heading = X: " .. Rotation.x)
                    -- SendNUIMessage({
                    --     string = string.format('vector3(%s, %s, %s)', x, y, z)
                    -- })
                end
                if CurObject.ID ~= nil then
                    if DoesEntityExist(CurObject.ID) then
                        local x = QBCore.Shared.Round(coords.x, 2)
                        local y = QBCore.Shared.Round(coords.y, 2)
                        local z = QBCore.Shared.Round(coords.z, 2)
                        Coords.x = x
                        Coords.y = y
                        Coords.z = z
                        changeCoords()
                    end
                end

                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false, false)
            end

            if EntityFreeAim == false then
                GroundCam = false
            end
        end
    end)
end

local Bones = {
    ["SKEL_ROOT"] = 0,
    ["FB_R_Brow_Out_000"] = 1356,
    ["SKEL_L_Toe0"] = 2108,
    ["MH_R_Elbow"] = 2992,
    ["SKEL_L_Finger01"] = 4089,
    ["SKEL_L_Finger02"] = 4090,
    ["SKEL_L_Finger31"] = 4137,
    ["SKEL_L_Finger32"] = 4138,
    ["SKEL_L_Finger41"] = 4153,
    ["SKEL_L_Finger42"] = 4154,
    ["SKEL_L_Finger11"] = 4169,
    ["SKEL_L_Finger12"] = 4170,
    ["SKEL_L_Finger21"] = 4185,
    ["SKEL_L_Finger22"] = 4186,
    ["RB_L_ArmRoll"] = 5232,
    ["IK_R_Hand"] = 6286,
    ["RB_R_ThighRoll"] = 6442,
    ["SKEL_R_Clavicle"] = 10706,
    ["FB_R_Lip_Corner_000"] = 11174,
    ["SKEL_Pelvis"] = 11816,
    ["IK_Head"] = 12844,
    ["SKEL_L_Foot"] = 14201,
    ["MH_R_Knee"] = 16335,
    ["FB_LowerLipRoot_000"] = 17188,
    ["FB_R_Lip_Top_000"] = 17719,
    ["SKEL_L_Hand"] = 18905,
    ["FB_R_CheekBone_000"] = 19336,
    ["FB_UpperLipRoot_000"] = 20178,
    ["FB_L_Lip_Top_000"] = 20279,
    ["FB_LowerLip_000"] = 20623,
    ["SKEL_R_Toe0"] = 20781,
    ["FB_L_CheekBone_000"] = 21550,
    ["MH_L_Elbow"] = 22711,
    ["SKEL_Spine0"] = 23553,
    ["RB_L_ThighRoll"] = 23639,
    ["PH_R_Foot"] = 24806,
    ["SKEL_Spine1"] = 24816,
    ["SKEL_Spine2"] = 24817,
    ["SKEL_Spine3"] = 24818,
    ["FB_L_Eye_000"] = 25260,
    ["SKEL_L_Finger00"] = 26610,
    ["SKEL_L_Finger10"] = 26611,
    ["SKEL_L_Finger20"] = 26612,
    ["SKEL_L_Finger30"] = 26613,
    ["SKEL_L_Finger40"] = 26614,
    ["FB_R_Eye_000"] = 27474,
    ["SKEL_R_Forearm"] = 28252,
    ["PH_R_Hand"] = 28422,
    ["FB_L_Lip_Corner_000"] = 29868,
    ["SKEL_Head"] = 31086,
    ["IK_R_Foot"] = 35502,
    ["RB_Neck_1"] = 35731,
    ["IK_L_Hand"] = 36029,
    ["SKEL_R_Calf"] = 36864,
    ["RB_R_ArmRoll"] = 37119,
    ["FB_Brow_Centre_000"] = 37193,
    ["SKEL_Neck_1"] = 39317,
    ["SKEL_R_UpperArm"] = 40269,
    ["FB_R_Lid_Upper_000"] = 43536,
    ["RB_R_ForeArmRoll"] = 43810,
    ["SKEL_L_UpperArm"] = 45509,
    ["FB_L_Lid_Upper_000"] = 45750,
    ["MH_L_Knee"] = 46078,
    ["FB_Jaw_000"] = 46240,
    ["FB_L_Lip_Bot_000"] = 47419,
    ["FB_Tongue_000"] = 47495,
    ["FB_R_Lip_Bot_000"] = 49979,
    ["SKEL_R_Thigh"] = 51826,
    ["SKEL_R_Foot"] = 52301,
    ["IK_Root"] = 56604,
    ["SKEL_R_Hand"] = 57005,
    ["SKEL_Spine_Root"] = 57597,
    ["PH_L_Foot"] = 57717,
    ["SKEL_L_Thigh"] = 58271,
    ["FB_L_Brow_Out_000"] = 58331,
    ["SKEL_R_Finger00"] = 58866,
    ["SKEL_R_Finger10"] = 58867,
    ["SKEL_R_Finger20"] = 58868,
    ["SKEL_R_Finger30"] = 58869,
    ["SKEL_R_Finger40"] = 58870,
    ["PH_L_Hand"] = 60309,
    ["RB_L_ForeArmRoll"] = 61007,
    ["SKEL_L_Forearm"] = 61163,
    ["FB_UpperLip_000"] = 61839,
    ["SKEL_L_Calf"] = 63931,
    ["SKEL_R_Finger01"] = 64016,
    ["SKEL_R_Finger02"] = 64017,
    ["SKEL_R_Finger31"] = 64064,
    ["SKEL_R_Finger32"] = 64065,
    ["SKEL_R_Finger41"] = 64080,
    ["SKEL_R_Finger42"] = 64081,
    ["SKEL_R_Finger11"] = 64096,
    ["SKEL_R_Finger12"] = 64097,
    ["SKEL_R_Finger21"] = 64112,
    ["SKEL_R_Finger22"] = 64113,
    ["SKEL_L_Clavicle"] = 64729,
    ["FACIAL_facialRoot"] = 65068,
    ["IK_L_Foot"] = 65245
}

RegisterCommand("devtools", function(source, args, rawCommand)
    OpenDevTools()
end, false)

RegisterKeyMapping("devtools", "Open Dev Tools",'keyboard',Config.OpenMenuKey)

function OpenDevTools()
    local columns = {
        {
            header = "> SAYER DEV TOOLS <",
            isMenuHeader = true,
        }, 
    }
    for k,v in ipairs(Config.DevMenu) do
        local item = {}
        item.header = v.Header
        item.params = {
            event = v.Event,
            args = {}
        }
        table.insert(columns, item)
    end

    exports['qb-menu']:openMenu(columns)
end

RegisterCommand("devtoolsanim", function(source, args, rawCommand)
    OpenAnimMenu()
end, false)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

-- PROPS --

RegisterNetEvent('sayer-devtools:TriggerPropMenu', function()
    local delmenu = nil
    local propcolumns = {}
    local bonecolumns = {}
    for k,v in pairs(Config.Props) do
        local option = {}
        option.value = v.propname
        option.text = string.upper(v.propname)
        table.insert(propcolumns, option)
    end
    for k,v in pairs(Bones) do
        local option = {}
        option.value = k
        option.text = k
        table.insert(bonecolumns, option)
    end
    delmenu = exports['qb-input']:ShowInput({
        header = "> SAYER DEV TOOLS <",
        submitText = "Create Prop",
        inputs = {
            {
                text = "Props",    
                name = "prop",    
                type = "select",    
                isRequired = true,
                options = propcolumns,
            },
            {
                text = "Attach to Bone?",    
                name = "attachbone",    
                type = "radio",    
                isRequired = true,
                options = {
                    {value = "true", text = "True"},
                    {value = "false", text = "False"},
                },
            },
            {
                text = "Bones",    
                name = "bone",    
                type = "select",    
                isRequired = false,
                options = bonecolumns,
            },
            {
                text = "Stick To Ground?",    
                name = "ground",    
                type = "radio",    
                isRequired = true,
                options = {
                    {value = "true", text = "True"},
                    {value = "false", text = "False"},
                },
            },
            {
                text = "Set Transparent?",    
                name = "transparent",    
                type = "radio",    
                isRequired = true,
                options = {
                    {value = "true", text = "True"},
                    {value = "false", text = "False"},
                },
            },
        }
    })
    if delmenu ~= nil then
        if delmenu.prop == nil then return end
        if delmenu.attachbone == nil then return end
        if delmenu.ground == nil then return end

        if delmenu.attachbone == "true" and delmenu.bone ~= nil then
            MakePropAttach(delmenu.prop, delmenu.bone, delmenu.transparent)
        elseif delmenu.ground == "true" then
            MakePropGround(delmenu.prop, delmenu.transparent)
        end
        --ExecuteCommand("devmakeprop "..delmenu.prop.." "..delmenu.bone)
    end
end)

function MakePropAttach(prop,bone,alpha)
    SayerDevMode = true
    local objectName = prop
    CurObject.OnBone = bone

    local ped = PlayerPedId()

    local hash = GetHashKey(objectName)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(100)
    end

    CurObject.ID = CreateObject(hash, 1.0, 1.0, 1.0, true, true, false)

    AttachEntityToEntity(CurObject.ID, ped, GetPedBoneIndex(ped, Bones[bone]), Coords.x,Coords.y,Coords.z,Rotation.x,Rotation.y,Rotation.z,1, 1, 0, 0, 2, 1)

    if alpha == "true" then
        SetEntityAlpha(CurObject.ID,102,false)
        CurObject.Alpha = 102
    end

end

function MakePropGround(prop,alpha)
    SayerDevMode = true
    local objectName = prop
    CurObject.OnGround = true

    local ped = PlayerPedId()

    RequestModel(objectName)
    while not HasModelLoaded(objectName) do
        Wait(0)
    end

    local head = GetEntityHeading(ped)
    local coords    = GetEntityCoords(ped)
    local forward   = GetEntityForwardVector(ped)
    local x, y, z   = table.unpack(coords + forward * 1.0)

    CurObject.ID = CreateObject(objectName, x, y, z, true, true, false)
    PlaceObjectOnGroundProperly(CurObject.ID)
    SetEntityHeading(CurObject.ID, head)
        
    Coords.x = x
    Coords.y = y
    Coords.z = z
    Rotation.x = head
    if alpha == "true" then
        SetEntityAlpha(CurObject.ID,102,false)
        CurObject.Alpha = 102
    end
    EntityFreeAim = true
    GroundCam = true
    StartEntityView()
end

RegisterNetEvent('sayer-devtools:RemoveAll', function()
    GroundCam = false
    EntityFreeAim = false
    DetachEntity(CurObject.ID,true,false)
    ClearPedTasks(PlayerPedId())
    DeleteObject(CurObject.ID)
    Coords = {
        x = 0.0,
        y = 0.0,
        z = 0.0,
    }
    Rotation = {
        x = 0.0,
        y = 0.0,
        z = 0.0,
    }
    Heading = 0.0
    Tolerance = 3
    CurObject.OnBone = false
    CurObject.OnGround = false
    CurObject.Alpha = 255
    CurObject.ID = nil
end)

RegisterCommand("propprintcoords", function(source,args,rawCommand)
    print("SAYER DEV TOOLS");
    print("Location = X: " .. x .. " Y: " .. y .. " Z: " .. z)
    print("Rotation = X: " .. px .. " Y: " .. py .. " Z: " .. pz)
    print("Bone: " .. bone .. " Bone Index: " .. Bones[bone])
end)

RegisterNetEvent('sayer-devtools:SetTolerance', function()
    local delmenu = nil
    
    delmenu = exports['qb-input']:ShowInput({
        header = "> SAYER DEV TOOLS <",
        submitText = "Set Tolerance",
        inputs = {
            {
                text = "(#)Tolerance",    
                name = "tolerance",    
                type = "text",    
                isRequired = true,
            },
        }
    })
    if delmenu ~= nil then
        if delmenu.tolerance == nil then return end
        SetTolerance(delmenu.tolerance)
    end
end)

function SetTolerance(value)
    Tolerance = tonumber(value)
    SendNotify("Tolerance is now: "..tostring(Tolerance), 'success')
end

RegisterNetEvent('sayer-devtools:SetAlpha', function()
    local delmenu = nil
    
    delmenu = exports['qb-input']:ShowInput({
        header = "> SAYER DEV TOOLS <",
        submitText = "Set Alpha",
        inputs = {
            {
                text = "(#)Alpha",    
                name = "alpha",    
                type = "text",    
                isRequired = true,
            },
        }
    })
    if delmenu ~= nil then
        if delmenu.alpha == nil then return end
        SetTolerance(delmenu.alpha)
    end
end)

function SetAlpha(value)
    CurObject.Alpha = tonumber(value)
    SendNotify("Alpha is now: "..tostring(CurObject.Alpha), 'success')
end

RegisterNetEvent('sayer-devtools:TestSpawn', function()
    local delmenu = nil
    local propcolumns = {}
    for k,v in pairs(Config.Props) do
        local option = {}
        option.value = v.propname
        option.text = string.upper(v.propname)
        table.insert(propcolumns, option)
    end
    delmenu = exports['qb-input']:ShowInput({
        header = "> SAYER DEV TOOLS <",
        submitText = "Spawn",
        inputs = {
            {
                text = "Props",    
                name = "prop",    
                type = "select",    
                isRequired = true,
                options = propcolumns,
            },
            {
                text = "X",    
                name = "x",    
                type = "text",    
                isRequired = true,
            },
            {
                text = "Y",    
                name = "y",    
                type = "text",    
                isRequired = true,
            },
            {
                text = "Z",    
                name = "z",    
                type = "text",    
                isRequired = true,
            },
            {
                text = "Heading",    
                name = "head",    
                type = "text",    
                isRequired = true,
            },
        }
    })
    if delmenu ~= nil then
        if delmenu.prop == nil then return end
        if delmenu.x == nil then return end
        if delmenu.y == nil then return end
        if delmenu.z == nil then return end
        if delmenu.head == nil then return end
        TestSpawnProp(delmenu.prop,tonumber(delmenu.x),tonumber(delmenu.y),tonumber(delmenu.z),tonumber(delmenu.head))
    end
end)

function TestSpawnProp(prop,x,y,z,heading)
    local objectName = prop

    local ped = PlayerPedId()

    RequestModel(objectName)
    while not HasModelLoaded(objectName) do
        Wait(0)
    end

    TestSpawn.ID = CreateObject(objectName, x, y, z, true, true, false)
    PlaceObjectOnGroundProperly(TestSpawn.ID)
    SetEntityHeading(TestSpawn.ID, heading)
    Wait(60000)
    DeleteObject(TestSpawn.ID)
    TestSpawn.ID = nil
end

-- COORDS --

local function changeCoord(axis, direction, rotate)
    if SayerDevMode then
        if rotate then
            Rotation[axis] = Rotation[axis] + Tolerance * direction
        else
            Coords[axis] = Coords[axis] + Tolerance * direction
        end
        changeCoords()
    end
end

for k,v in pairs(Config.Commands) do
    RegisterKeyMapping(k, v.Label,'keyboard',v.Control)
end 

RegisterCommand("loczup",   function() changeCoord("z", 1, false) end, false)
RegisterCommand("loczdown", function() changeCoord("z", -1, false) end, false)
RegisterCommand("locyup",   function() changeCoord("y", 1, false) end, false)
RegisterCommand("locydown", function() changeCoord("y", -1, false) end, false)
RegisterCommand("locxup",   function() changeCoord("x", 1, false) end, false)
RegisterCommand("locxdown", function() changeCoord("x", -1, false) end, false)

RegisterCommand("rotzup",   function() changeCoord("z", 1, true) end, false)
RegisterCommand("rotzdown", function() changeCoord("z", -1, true) end, false)
RegisterCommand("rotyup",   function() changeCoord("y", 1, true) end, false)
RegisterCommand("rotydown", function() changeCoord("y", -1, true) end, false)
RegisterCommand("rotxup",   function() changeCoord("x", 1, true) end, false)
RegisterCommand("rotxdown", function() changeCoord("x", -1, true) end, false)

RegisterCommand("zomp", function() SendZombie('primary') end, false)
RegisterCommand("zoms", function() SendZombie('success', "You Completed Something") end, false)
RegisterCommand("zome", function() SendZombie('error', "Oops Error") end, false)
RegisterCommand("zomi", function() SendZombie('info', "Hmmm Info") end, false)
RegisterCommand("zomc", function() SendZombie('cook', "You Cooked A Worm") end, false)
RegisterCommand("zomss", function() SendZombie('search', "You Found a Book") end, false)
RegisterCommand("ground",   function() GetGroundMaterial() end, false)

function SendZombie(Type, Text)
    if not Text then Text = "You are Being chased By Zombies" end
    local type = Type
    local length = 10000
    exports['z-notify']:Notify(Text, type, length)
end

--- CHANGE COORDS ---

function changeCoords()

    local playerPed = PlayerPedId()
    if CurObject.OnBone then
        DetachEntity(CurObject.ID,true,false)
        AttachEntityToEntity(CurObject.ID, playerPed, GetPedBoneIndex(playerPed, Bones[CurObject.OnBone]), Coords.x,Coords.y,Coords.z,Rotation.x,Rotation.y,Rotation.z,1, 1, 0, 0, 2, 1)
    end
    if CurObject.OnGround then
        SetEntityCoords(CurObject.ID,Coords.x,Coords.y,Coords.z,false,false,false,false)
        SetEntityHeading(CurObject.ID,Rotation.x)
        PlaceObjectOnGroundProperly(CurObject.ID)
    end
    SetEntityCollision(CurObject.ID,false,true)
    SetEntityAlpha(CurObject.ID,CurObject.Alpha)
end

-- ANIMATIONS --

RegisterNetEvent('sayer-devtools:TriggerAnimMenu', function()
    local delmenu = nil
    local animcolumns = {}
    for k,v in pairs(Config.Animations) do
        local option = {}
        option.value = k
        option.text = string.upper(k)
        table.insert(animcolumns, option)
    end
    delmenu = exports['qb-input']:ShowInput({
        header = "> SAYER DEV TOOLS <",
        submitText = "Search Anim Dict",
        inputs = {
            {
                text = "AnimDict",    
                name = "animdict",    
                type = "select",    
                isRequired = true,
                options = animcolumns,
            },
        }
    })
    if delmenu ~= nil then
        if delmenu.animdict == nil then return end
        OpenFinalAnimMenu(delmenu.animdict)
    end
end)

function OpenFinalAnimMenu(dict)
    local delmenu = nil
    local animcolumns = {}
    for k,v in pairs(Config.Animations[dict]) do
        local option = {}
        option.value = v.anim
        option.text = string.upper(v.anim)
        table.insert(animcolumns, option)
    end
    delmenu = exports['qb-input']:ShowInput({
        header = "> SAYER DEV TOOLS <",
        submitText = "Start Animation",
        inputs = {
            {
                text = "Animation",    
                name = "anim",    
                type = "select",    
                isRequired = true,
                options = animcolumns,
            },
        }
    })
    if delmenu ~= nil then
        if delmenu.anim == nil then return end
        TriggerAnim(dict, delmenu.anim)
    end
end

function TriggerAnim(dict,anim)
    ClearPedTasks(PlayerPedId())
    loadAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict ,anim, 5.0, -1, -1, 50, 0, false, false, false)
end

--notify configuration
function SendNotify(msg,type,time,title)
    if not title then title = "Dev Tools" end
    if not time then time = 5000 end
    if not type then type = 'success' end
    if not msg then print("SendNotify Client Triggered With No Message") return end
    if Config.NotifyScript == 'qb' then
        QBCore.Functions.Notify(msg,type,time)
    elseif Config.NotifyScript == 'okok' then
        exports['okokNotify']:Alert(title, msg, time, type, false)
    elseif Config.NotifyScript == 'qs' then
        exports['qs-notify']:Alert(msg, time, type)
    elseif Config.NotifyScript == 'other' then
        -- add your notify here
        exports['yournotifyscript']:Notify(msg,time,type)
    end
end
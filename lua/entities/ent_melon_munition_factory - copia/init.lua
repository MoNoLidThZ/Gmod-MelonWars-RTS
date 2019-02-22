AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	Defaults ( self )

	--print("Changing stats")
	
	self.modelString = "models/props_wasteland/laundry_basket001.mdl"
	self.moveType = MOVETYPE_NONE
	self.Angles = Angle(0,0,180)
	self.canMove = false
	self.canShoot = false
	self.maxHP = 100
	
	self.slowThinkTimer = 60
	
	self.population = 5
	
	self.deathSound = "ambient/explosions/explode_9.wav"
	self.deathEffect = "Explosion"

	self.melons = {}
	--print("Finished changing stats")
	Setup ( self )
	
	--print("Finished Initialize")
	self:SetPos(self:GetPos()+Vector(0,0,15))
end

function ENT:SlowThink(ent)
	local count = 0

	for k, v in pairs( ent.melons ) do
		if (IsValid(v)) then
			count = count + 1
		else
			table.remove(ent.melons, k)
		end
	end
	
	if (count < 3 and teamUnits[ent:GetNWInt("melonTeam", 0)] < cvars.Number("mw_admin_max_units")) then
		
		local newMarine = ents.Create( "ent_melon_bomb" )
		if ( !IsValid( newMarine ) ) then return end -- Check whether we successfully made an entity, if not - bail
		newMarine:SetPos( ent:GetPos() + Vector(0,0,10))
		
		sound.Play( "ambient/misc/hammer1.wav", ent:GetPos(), 75, 100, 1 )
		
		melonTeam = ent:GetNWInt("melonTeam", 0)
		
		newMarine:Spawn()
		newMarine:SetNWInt("melonTeam", ent:GetNWInt("melonTeam", 0))
		
		if (ent.targetPos == ent:GetPos()) then
			newMarine:SetVar('targetPos', ent:GetPos()+Vector(100,0,0))
			newMarine:SetNWVector('targetPos', ent:GetPos()+Vector(100,0,0))
		else
			newMarine:SetVar('targetPos', ent.targetPos)
			newMarine:SetNWVector('targetPos', ent.targetPos)
		end
		newMarine:SetVar('moving', true)
	
		table.insert(ent.melons, newMarine)
		undo.Create("Melon Marine")
		 undo.AddEntity( newMarine )
		 undo.SetPlayer( ent:GetOwner())
		undo.Finish()
	end
end

function ENT:Shoot ( ent )
	--DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	DefaultDeathEffect ( ent )
end
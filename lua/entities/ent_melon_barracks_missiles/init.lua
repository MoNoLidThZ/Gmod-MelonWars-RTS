AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	MW_Defaults ( self )

	self.unit = 6
	self.modelString = "models/props_interiors/VendingMachineSoda01a.mdl"
	self.maxHP = 120
	//self.Angles = Angle(-45,0,45)
	//self:SetPos(self:GetPos()+Vector(0,0,10))
	//self:SetAngles(self:GetAngles()+self.Angles)

	--print("Changing stats")
	
	self:BarrackInitialize()
	self.population = 1
	self:SetNWInt("maxunits", 4)
	--print("Finished changing stats")

	MW_Setup ( self )
	
	--print("Finished Initialize")
end

function ENT:Think(ent)

	self:SetNWInt("count", 0)

	self:BarrackSlowThink()

	self:NextThink(CurTime()+0.2)
	return true
end

function ENT:Shoot ( ent )
	--MW_DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end
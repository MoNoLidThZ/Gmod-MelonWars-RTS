AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")

	MW_Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/Roller.mdl"
	self.moveType = MOVETYPE_VPHYSICS
	self.speed = 80
	self.spread = 10
	self.damageDeal = 2
	self.maxHP = 30
	self.range = 300
	
	self.population = 2
	self.buildingDamageMultiplier = 0.8

	self.sphereRadius = 9
	
	self.shotSound = "weapons/ar1/ar1_dist2.wav"
	self.tracer = "AR2Tracer"
	
	self.slowThinkTimer = 1
	self.spinup = 3
	self.maxspinup = 3
	self.minspinup = 0.6
	
	--print("Finished changing stats")
	
	MW_Setup ( self )
	
	--print("Finished Initialize")
	
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r/1.5, self:GetColor().g/1.5, self:GetColor().b/1.5, 255))
end

function ENT:SlowThink ( ent )
	self.slowThinkTimer = self.spinup
	if (self.spinup < self.maxspinup) then
		self.spinup = self.spinup + 0.2
		if (self.spinup > self.maxspinup) then
			self.spinup = self.maxspinup
		end
	end
	MW_UnitDefaultThink ( ent )
end

function ENT:Shoot ( ent )
	MW_DefaultShoot ( ent )
	for i = 1, 2 do
		timer.Simple( i*self.spinup/3, function()
			if (IsValid(ent)) then
				MW_DefaultShoot ( ent )
			end
		end)
	end
	if (self.spinup > self.minspinup) then
		self.spinup = self.spinup - 0.6
		if (self.spinup < self.minspinup) then
			self.spinup = self.minspinup
		end
	end
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end
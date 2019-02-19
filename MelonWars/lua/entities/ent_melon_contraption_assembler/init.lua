AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	Defaults ( self )

	self.modelString = "models/props_phx/construct/metal_plate4x4.mdl"
	self.maxHP = 100
	self.Angles = Angle(0,0,0)
	self:SetPos(self:GetPos()+Vector(0,0,-5))
	--self:SetPos(self:GetPos()+Vector(0,0,10))
	self.moveType = MOVETYPE_NONE
	self.connections = {}

	self.population = 0
	--self:SetNWInt("energy", 0)
	--self:SetNWInt("maxenergy", 100)
	--self:SetNWVector("energyPos", Vector(0,0,0))
	--print("Finished changing stats")
	self:BarrackInitialize()
	self.population = 3

	Setup ( self )

	self:SetNWBool("active", false)
	--InciteConnections(self)
	--CalculateConnections(self)
	--self:SetNWBool("canGive", false)
	--print("Finished Initialize")
end

function ENT:Think(ent)
	--local energy = math.Round(self:GetNWInt("energy", 0))
	--local max = self:GetNWInt("maxenergy", 0)
	--self:SetNWString("message", "OverClock: "..energy.." / "..max)
	--PullEnergy(self)
	local NST = self:GetNWFloat("nextSlowThink", 0)
	if (self:GetNWBool("active", false)) then
		--if (energy > 20) then
		--	self:SetNWFloat("overdrive", self:GetNWFloat("overdrive", 0)+0.125)
		--	self:SetNWInt("energy", self:GetNWInt("energy", 0)-20)
		--end
		print(self:GetNWFloat("overdrive", 0))
		if (NST < CurTime()+self:GetNWFloat("overdrive", 0)) then
			self:SetNWFloat("overdrive", 0)
			self:SetNWFloat("nextSlowThink", CurTime())
			print("Requesting... File: "..self.file..", Player: "..self.player:GetName())
			self:SetNWBool("active", false)
			net.Start("RequestContraptionLoadToClient")
				net.WriteString(self.file)
				net.WriteEntity(self)
			net.Send(self.player)
		end
	end
end

function ENT:SlowThink(ent)

end

function ENT:Shoot ( ent )

end

function ENT:DeathEffect ( ent )
	DefaultDeathEffect ( ent )
end

function ENT:BarrackSlowThink()

end
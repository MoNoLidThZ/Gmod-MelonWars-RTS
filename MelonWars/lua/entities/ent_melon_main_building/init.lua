AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

debri_props	 = {
"models/props_combine/combine_light002a.mdl",
"models/props_combine/tprotato2_chunk01.mdl",
"models/props_combine/tprotato2_chunk03.mdl",
"models/props_combine/combine_barricade_bracket02b.mdl",
"models/props_combine/combine_lock01.mdl",
"models/props_combine/combine_barricade_bracket01b.mdl",
"models/props_combine/combine_barricade_bracket01a.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl"
}

function ENT:Initialize()

	Defaults ( self )
		
	self.slowThinkTimer = 1
	self.nextSlowThink = 0
	self.modelString = "models/props_combine/CombineThumper002.mdl"
	self.Angles = Angle(0,0,0)
	self.shotOffset = Vector(0,-20,30)
	self:SetPos(self:GetPos()+Vector(0,0,1))
	self.materialString = "models/shiny"
	
	self.canMove = false
	self.canBeSelected = false
	
	self.maxHP = 500
	self.dead = false
	
	self.population = 0
	
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.moveType = MOVETYPE_NONE 
	--local weld = constraint.Weld( self, game.GetWorld(), 0, 0, 0, true , false )
	
	self:SetNWInt("energy", 0)
	self:SetNWFloat("state", 0) --0 = neutral, 1 = dar, -1 = necesitar
	self:SetNWInt("maxenergy", 50)
	self:SetNWVector("energyPos", Vector(0,0,100))

	Setup ( self )
	
	self.zone = ents.Create( "ent_melon_zone" )
		self.zone:SetModel("models/hunter/tubes/circle2x2.mdl")
		self.zone:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		
		self.zone:SetPos(self:GetPos())
		self.zone:Spawn()
		self.zone:SetPos(self:GetPos()+Vector(0,0,-12))
		self.zone:SetMoveType( MOVETYPE_NONE )
		self.zone:SetModelScale( 16.8, 0 )
		self.zone:SetMaterial( "models/debug/debugwhite" )
		self.zone:SetNWInt("zoneTeam", melonTeam)
		
		self:DeleteOnRemove( self.zone )

	CalculateConnections(self)
end

function ENT:CreateAlert (pos, _team)
	local alert = ents.Create( "ent_melon_HUD_alert" )
	alert:SetPos(pos)
	alert:Spawn()
	alert:SetNWInt("drawTeam", _team)
end

function ENT:Shoot ( ent )
	--DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	if (ent.dead == false) then
		sound.Play( "ambient/explosions/explode_2.wav", ent:GetPos() )
		sound.Play( "ambient/explosions/citadel_end_explosion2.wav", ent:GetPos() )
		for i = 1, 10 do
			timer.Simple(i/4, function()
				local randomVector = Vector(math.random(-100,100), math.random(-100,100), math.random(0,200))
				local effectdata = EffectData()
				effectdata:SetOrigin( ent:GetPos() + randomVector )
				effectdata:SetScale( 100 )
				util.Effect( "Explosion", effectdata )
			end)
		end
		timer.Simple(11/4, function()
			for i = 1, 10 do
				local effectdata = EffectData()
				effectdata:SetOrigin( ent:GetPos() + Vector(0,0,20*i) )
				effectdata:SetScale( 100 )
				util.Effect( "Explosion", effectdata )
			end
			
			local count = table.Count(debri_props)
			
			for i = 1, count do
				local debris = ents.Create( "prop_physics" )
				debris:SetModel(debri_props[i])
				debris:Ignite( 60 )
				debris:SetPos(ent:GetPos() + Vector(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
				debris:Spawn()
				local debrisPhys = debris:GetPhysicsObject()
				debrisPhys:ApplyForceCenter(Vector(math.random(-10000,10000), math.random(-10000,10000), math.random(10000,70000)))
			end
			
			ent:Remove()
		end)
		------------------------
		sound.Play( "ambient/explosions/explode_2.wav", ent:GetPos() )
		sound.Play( "ambient/explosions/citadel_end_explosion2.wav", ent:GetPos() )
		ent.dead = true
	end
end

function ENT:OnTakeDamage( damage )
	if ((damage:GetAttacker():GetNWInt("melonTeam", 0) ~= self:GetNWInt("melonTeam", 0) or not damage:GetAttacker():GetVar('careForFriendlyFire')) and not damage:GetAttacker():IsPlayer()) then 
		for k, v in pairs( player.GetAll() ) do
			if (tostring(v:GetInfoNum("mw_team", 0)) == tostring(self:GetNWInt("melonTeam", 0))) then
				sound.Play( "ambient/alarms/doomsday_lift_alarm.wav", v:GetPos()+Vector(0,0,45), 40, 100, 1)
				self.HP = self.HP - damage:GetDamage()
				if (self.HP > 0) then
					v:PrintMessage( HUD_PRINTCENTER, "Main building under attack! "..tostring(math.ceil((self.HP)/5)).."% left!" )
					self:CreateAlert(self:GetPos()+Vector(0,0,350), self:GetNWInt("melonTeam", 0))
				else
					v:PrintMessage( HUD_PRINTCENTER, "The Main Building has been destroyed!" )
				end
			end
		end
		if (self.HP <= 0) then
			Die (self)
		end
	end
end

function ENT:SlowThink()
	if (cvars.Bool("mw_admin_cutscene")) then return end
	if (self:GetNWInt("melonTeam", 0) ~= 0) then
		teamCredits[self:GetNWInt("melonTeam", 0)] = teamCredits[self:GetNWInt("melonTeam", 0)]+25
		for k, v in pairs( player.GetAll() ) do
			if (v:GetInfo("mw_team") == tostring(self:GetNWInt("melonTeam", 0))) then
				net.Start("TeamCredits")
					net.WriteInt(teamCredits[self:GetNWInt("melonTeam", 0)] ,16)
				net.Send(v)
			end
		end
		--local effectdata = EffectData()
		--effectdata:SetOrigin( self:GetPos() + Vector(0,0,100))
		--effectdata:SetScale(10)
		--util.Effect( "watersplash", effectdata )
	end

	local energy = self:GetNWInt("energy", 0)
	local max = self:GetNWInt("maxenergy", 0)
	energy = math.min(max, energy+1)
	self:SetNWInt("energy", energy)

	self:SetNWFloat("state", energy/max)

	ExchangeEnergy(self)
end
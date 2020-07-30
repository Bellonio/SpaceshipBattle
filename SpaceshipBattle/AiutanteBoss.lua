AiutanteBoss = Class{}

local sprite_width = 75
local sprite_height = 84

local VELOCITA_SPOSTAMENTO = 8

function AiutanteBoss:init(livello, qualeAiutante, vita)
	
	self.image = love.graphics.newImage("/spaceships/unPo_di_spaceShips.png")
	spaceship = love.graphics.newQuad(0, (sprite_height*9), sprite_width, sprite_height, self.image:getDimensions())
	
	self.livello = livello
	self.qualeAiutante = qualeAiutante
	
	local x
	local y
	if self.qualeAiutante == 1 then
		
		x = 80
		y = self.livello.boss.padre.y + self.livello.boss.height + 10 
		
	else
		
		x = love.graphics.getWidth()-80
		y = love.graphics.getHeight()-80
		
	end
	
	self.padre = ClassePadreNavicella(
		x, y, vita, 
		love.graphics.getWidth()/2-(30*vita)/2, love.graphics.getHeight()-60)
	
	self.width = sprite_width
	self.height = sprite_height
	
	self.timer = 0
	self.destinazione = self.qualeAiutante == 1 and love.graphics.getHeight()-80 or self.livello.boss.padre.y + self.livello.boss.height + 10
	
end


function AiutanteBoss:update(dt)
	
		--controllo, se l'aiutante ha raggiunto la destinazione allora lo faccio andare verso la destinazione opposta	
	if self.padre.y > self.destinazione-20 and self.padre.y < self.destinazione+20 then

		if self.destinazione > self.livello.boss.padre.y + self.livello.boss.height + 10 then
			self.destinazione = self.livello.boss.padre.y + self.livello.boss.height + 10
		else
			self.destinazione = love.graphics.getHeight()-80
		end

	end

		--ogni tot sec si sposta
	self.timer = self.timer + dt
	if self.timer > 3/100 then
		
		self.timer = 0
		
		if self.destinazione > self.livello.boss.padre.y + self.livello.boss.height + 10 then
			self.padre.y = self.padre.y + VELOCITA_SPOSTAMENTO
		else
			self.padre.y = self.padre.y - VELOCITA_SPOSTAMENTO
		end
		
	end
	
end


function AiutanteBoss:render()

	if self.qualeAiutante == 1 then
		love.graphics.draw(self.image, spaceship, self.padre.x, self.padre.y, math.rad(90))
	else
		love.graphics.draw(self.image, spaceship, self.padre.x, self.padre.y, math.rad(-90))
	end
	
end

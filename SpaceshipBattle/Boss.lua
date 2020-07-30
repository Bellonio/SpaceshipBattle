Boss = Class{}

local VELOCITA_SPOSTAMENTO

function Boss:init(vita, cheBoss)
		
		--velocita di spostamento diverse con boss diversi
	if cheBoss == 1 then
		VELOCITA_SPOSTAMENTO = 7
	elseif cheBoss == 2 then
		VELOCITA_SPOSTAMENTO = 11
	elseif cheBoss == 3 then
		VELOCITA_SPOSTAMENTO = 14
	end
	
	local y
	if cheBoss == 1 then
		
		self.image = love.graphics.newImage("/spaceships/prima.png")
		self.cheBoss = cheBoss
		y = 80
		
	else
		
		self.image = love.graphics.newImage("/spaceships/seconda.png")
		self.cheBoss = cheBoss
		y = 50
		
	end
	
	self.padre = ClassePadreNavicella(
		love.graphics.getWidth()/2-self.image:getWidth()/2, y,
		vita, 
		love.graphics.getWidth()/2-(30*vita)/2, 5)
	
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	
	
	math.randomseed(os.time())
	self.destinazione = math.random(1, 2) == 1 and (100-self.image:getWidth()/2) or love.graphics.getWidth()-100-self.image:getWidth()/2
	
	self.timer = 0

end


function Boss:update(dt)
	
		--controllo, se il boss ha raggiunto la destinazione allora lo faccio andare verso la destinazione opposta
	if self.padre.x > self.destinazione-20 and self.padre.x < self.destinazione+20 then

		if self.destinazione > 100 then
			self.destinazione = (100-self.image:getWidth()/2)
		else
			self.destinazione = love.graphics.getWidth()-100-self.image:getWidth()/2
		end

	end
	
		--ogni tot sec si sposta
	self.timer = self.timer + dt

	if self.timer > 3/100 then

		self.timer = 0
		
		if self.destinazione > 100 then
			self.padre.x = self.padre.x + VELOCITA_SPOSTAMENTO
		else
			self.padre.x = self.padre.x - VELOCITA_SPOSTAMENTO
		end
		
	end	
	
end


function Boss:render()
		
		--------disegno la barra della vita---------
	love.graphics.rectangle("line", self.padre.pos_x_barraVita, self.padre.pos_y_barraVita, 30*self.padre.vitaIniziale, 30)	
	love.graphics.setColor(1,0,0,1)
	
	love.graphics.rectangle("fill", self.padre.pos_x_barraVita, self.padre.pos_y_barraVita, 30*self.padre.vita, 30)
	love.graphics.setColor(1,1,1,1)
	
	
	love.graphics.setFont(fontScrittaVita)
	
	love.graphics.print("VITA DEL BOSS", self.padre.pos_x_barraVita + (30*self.padre.vitaIniziale)/2 - 50, self.padre.pos_y_barraVita + 5)
	
	love.graphics.setFont(normalFont)
		--------------------------------------------
	
	love.graphics.draw(self.image, self.padre.x, self.padre.y)
end

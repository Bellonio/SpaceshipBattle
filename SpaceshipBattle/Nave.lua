Nave = Class{}

local sprite_width = 75
local sprite_height = 84

function Nave:init(vita)
	
	self.image = love.graphics.newImage("/spaceships/unPo_di_spaceShips.png")
	spaceshipQuads = dividiSpritesheets(self.image, sprite_width, sprite_height, 9)
	
	self.padre = ClassePadreNavicella(
		love.graphics.getWidth()/2-sprite_width/2, love.graphics.getHeight()-sprite_height-70,
		vita, 
		love.graphics.getWidth()/2-(30*vita)/2, love.graphics.getHeight()-60)
	
	self.width = sprite_width
	self.height = sprite_height
	
end


function Nave:render(flagSpostamento)
	
		------------disegno barra della vita-----------------
	love.graphics.rectangle("line", self.padre.pos_x_barraVita, self.padre.pos_y_barraVita, 30*self.padre.vitaIniziale, 30)	
	love.graphics.setColor(0,1,0,1)
	
	love.graphics.rectangle("fill", self.padre.pos_x_barraVita, self.padre.pos_y_barraVita, 30*self.padre.vita, 30)
	love.graphics.setColor(1,1,1,1)
	
	
	love.graphics.setFont(fontScrittaVita)
	
	love.graphics.print("VITA DELLA NAVE", self.padre.pos_x_barraVita + (30*self.padre.vitaIniziale)/2 - 60, self.padre.pos_y_barraVita + 5)
	
	love.graphics.setFont(normalFont)
		----------------------------------------------
	
	if statoDelGioco == "partito" and flagSpostamento == true then
		
		if love.mouse.isVisible() == true and love.mouse.isGrabbed() == false then

				--sposta il mouse appena sopra la navicella
			love.mouse.setX(love.graphics.getWidth()/2-sprite_width/2+sprite_width/2)
			love.mouse.setY(self.padre.y)

			love.mouse.setVisible(false)		--rende il mouse invisibile
			love.mouse.setGrabbed(true)			--blocca il mouse all'interno della finestra di gioco
			
		end
			
			--sposta le coordinate della navicella rispetto a dove si trova il mouse
		self.padre.x = love.mouse.getX()-(sprite_width/2)
		self.padre.y = love.mouse.getY()
		
		love.graphics.draw(self.image, spaceshipQuads[spaceshipScelta], self.padre.x, self.padre.y)
		
	else
		love.graphics.draw(self.image, spaceshipQuads[spaceshipScelta], self.padre.x, self.padre.y)
	end
	
end

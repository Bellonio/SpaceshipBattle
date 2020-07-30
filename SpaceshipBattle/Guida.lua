Guida = Class{}

function Guida:init()
	
	self.imagePotenziamenti = love.graphics.newImage("/altreImmagini/potenziamenti.png")
	
	
	self.sprite_width = 75
	
	local sprite_height = 84
	
	self.imageSpaceship = love.graphics.newImage("/spaceships/unPo_di_spaceShips.png")
	
	self.quadSpaceships = dividiSpritesheets(self.imageSpaceship, self.sprite_width, sprite_height, 8)
	
end


function Guida:render()
	love.graphics.rectangle("line", 100, 100, love.graphics.getWidth()-250, love.graphics.getHeight()-120)
	
	love.graphics.print("- La tua nave sparera' in automatico, non ce nulla da cliccare ;", 110, 150)
	
	love.graphics.print("- Guida la tua nave con il mouse ;", 110, 190)
	
	love.graphics.print("- Premi 'esc' in qualsiasi momento per uscire ;", 110, 230)
	
	love.graphics.print("- Ricordati di prendere questi potenziamenti (casuali)\n\tpassandoci sopra con la nave ;", 110, 270)
	
	love.graphics.draw(self.imagePotenziamenti, 600, 320)
	
	love.graphics.print("=> Scegli la tua nave con le freccie e\n\tpremi 'invio' per cominciare la partita <=", 250, love.graphics.getHeight()-170)
	
	
	love.graphics.draw(self.imageSpaceship, self.quadSpaceships[spaceshipScelta], love.graphics.getWidth()/2-self.sprite_width, love.graphics.getHeight()-100)
	
		--vado a mostrare le freccie solo se e' possibile "andare in quella direzione" per la scelta della navicella
	if spaceshipScelta > 1 then
		love.graphics.print("<=", love.graphics.getWidth()/2-self.sprite_width - 50, love.graphics.getHeight()-60)
	end
	
	if spaceshipScelta < 8 then
		love.graphics.print("=>", love.graphics.getWidth()/2 + 30, love.graphics.getHeight()-60)
	end
	
end

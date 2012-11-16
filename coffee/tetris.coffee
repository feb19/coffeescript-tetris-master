shapes = [
	[1,1,1,1]
	[1,1,1,0,1]
	[1,1,1,0,0,0,1]
	[1,1,0,0,1,1]
	[1,1,0,0,0,1,1]
	[0,1,1,0,1,1]
	[0,1,0,0,1,1,1]
]
colors = [
	"cyan"
	"orange"
	"blue"
	"yellow"
	"red"
	"green"
	"purple"
]
canvases = document.getElementsByTagName "canvas"
canvas = canvases[0]
context = canvas.getContext("2d")
w = 300
h = 600
cols = 10
rows = 20
blockWidth = w / cols
blockHeight = h / rows
board = []
current = []
currentX = 0
currentY = 0

drawBlock = (x, y) ->
	context.fillRect blockWidth * x, blockHeight * y, blockWidth - 1, blockHeight - 1
	context.strokeRect blockWidth * x, blockHeight * y, blockWidth - 1, blockHeight - 1
	return

render =->
	context.clearRect(0, 0, w, h)
	context.strokeStyle = "black"
	for x in [0..9]
		for y in [0..19]
			if (board[y][x])
				context.fillStyle = colors[board[y][x] - 1]
				drawBlock x, y

	context.fillStyle = "red"
	context.strokeStyle = "black"

	for y in [0..3]
		for x in [0..3]
			if (current[y][x])
				context.fillStyle = colors[current[y][x]-1]
				drawBlock currentX + x, currentY + y
	return

newShape = ->
	id = Math.floor(Math.random() * shapes.length)
	shape = shapes[id]
	current = []
	for y in [0..3]
		current[y] = []
		for x in [0..3]
			i = 4 * y + x
			if (typeof shape[i] != "undefined" && shape[i])
				current[y][x] = id + 1
			else
				current[y][x] = 0
	currentX = 5
	currentY = 0
	return

init = ->
	for y in [0..rows-1]
		board[y] = []
		for x in [0..cols-1]
			board[y][x] = 0

tick = ->
	if (valid(0, 1))
		# console.log "valid"
		++currentY
	else
		# console.log "invalid"
		freeze()
		clearLines()
		newShape()
	return

freeze = ->
	for y in [0..3]
		for x in [0..3]
			if (current[y][x])
				board[y+currentY][x+currentX]= current[y][x]
	return

rotate = (current) ->
	newCurrent = []
	for y in [0..3]
		newCurrent[y] = []
		for x in [0..3]
			newCurrent[y][x] = current[3 - x][y]

	return newCurrent

clearLines = ->
	for y in [rows-1..1]
		row = true
		for x in [0..cols-1]
			if (board[y][x] == 0)
				row = false
				break
		if (row)
			for yy in [y..1]
				for x in [0..cols-1]
					board[yy][x] = board[yy-1][x]
			++y
	return

keyPress = (key) ->
	switch key
		when "left"
			if (valid(-1))
				--currentX
			break
		when "right"
			if (valid(1))
				++currentX
			break
		when "down"
			if (valid(0,1))
				++currentY
			break
		when "rotate"
			rotated = rotate(current)
			if (valid(0,0,rotated))
				current = rotated
			break 
	return

valid = (offsetX, offsetY, newCurrent) ->
	offsetX = offsetX || 0
	offsetY = offsetY || 0
	offsetX = currentX + offsetX
	offsetY = currentY + offsetY
	newCurrent = newCurrent || current
	for y in [0..3]
		for x in [0..3]
			if (newCurrent[y][x])
				# console.log newCurrent[y][x]
				# console.log board[y + offsetY][x + offsetX]
				if (typeof board[y + offsetY] == "undefined" ||
					typeof board[y + offsetY][x + offsetX] == "undefined" ||
					board[y + offsetY][x + offsetX] ||
					x + offsetX < 0 ||
					y + offsetY >= rows ||
					x + offsetX >= cols)
						# console.log false
						return false

	return true

document.body.onkeydown = (e) ->
	@keys =
		37 : "left"
		39 : "right"
		40 : "down"
		38 : "rotate"

	# check
	if (typeof @keys[e.keyCode] != 'undefined') 
	 	# console.log @keys[e.keyCode]
	 	keyPress @keys[e.keyCode]
	 	render

	return

init()
newShape()
setInterval tick, 250
setInterval render, 30


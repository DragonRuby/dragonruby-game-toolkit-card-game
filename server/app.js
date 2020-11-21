const express = require('express')
const app = express()
const port = 3000

var bodyParser = require('body-parser')
var state = null

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// Export state
app.get('/state', function(req, res) {
	console.log('Sending state.')
	res.send(state)
	console.log('Done')
})

// Import state
app.post('/state', function(req, res) {
	console.log('Receiving state')
	console.log(req.body.data)
	state = req.body.data
	res.status(204).send()
	console.log('Done')
})

app.listen(port, () => {
	console.log(`Listening for state requests at http://localhost:${port}`)
})

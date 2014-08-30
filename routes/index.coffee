express = require 'express'
router = express.Router()

twilioController = require('../controllers/twilio')
# GET home page.
router.get '/', (req, res) ->
  res.render 'index', { title: 'Express' }

router.post '/uhoh', (req ,res) ->
	twilioController(req ,res)


router.get '/uhoh', (req ,res) ->
	res.json {error: "use POST request"}

module.exports = router

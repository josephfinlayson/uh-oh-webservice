express = require 'express'
router = express.Router()

mongoose = require('mongoose');
# mongoose.connect('mongodb://localhost/my_database');

twilioSchema = new mongoose.Schema({
	uniqId: String
	gpsCoords: Array
	date: { type: Date, default: Date.now },
})

twilModel = mongoose.model('twilModel', twilioSchema);



twilioController = require('../controllers/twilio')
# GET home page.
router.get '/', (req, res) ->
  res.render 'index'

router.post '/uhoh', (req ,res) ->
	twilioController(req ,res)

router.get '/uhoh', (req ,res) ->
	res.json {error: "use POST request"}


router.get '/uhohDetails', (req ,res) ->
	twilModel.find({}, (err, results)->
		res.send(200, results)
	)

module.exports = router

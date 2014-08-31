try
	config = require './config'
catch e
	console.log e

if (typeof config == 'undefined')
	config = {}
	config.authToken = process.env.AUTH_TOKEN #heroku env var
	config.accountSid = process.env.ACCOUNT_SID #heroku env var

config.endMessage = " Please come quickly, or call the police"

mongoose = require('mongoose');
if !process.env.MONGOLAB_URI
	mongostring = 'mongodb://localhost/my_database'
else
	mongostring = 'mongodb://heroku_app29051557:n6e57l53hl14oa1385b5ev1lnd@ds049858.mongolab.com:49858/heroku_app29051557'

mongoose.connect(mongostring);

twilioSchema = new mongoose.Schema({
	mode: String
	uniqId: String
	gpsCoords: Array
	date: { type: Date, default: Date.now },
})

twilModel = mongoose.model('twilModel');
client = require('twilio')(config.accountSid, config.authToken);

saveDetails = (params) ->
	# saveDetails
	twilDetails = new twilModel(		{
		uniqId: params.from.num
		gpsCoords: params.gpsCoords,
		mode: params.mode
	});
	twilDetails.save((err, docs) ->
	  console.log(err,docs)
	);
getGoogleMapsLink = (params) ->
	"https://www.google.co.uk/maps/@#{params[0]},#{params[1]},17z"

getMessage = (params) ->
	console.log(params);
	"Hi #{params.name}, it's #{params.from.name}. I really need your help, you can find me here"

createBody = (params) ->
	mapsLink = getGoogleMapsLink([params.gpsCoords[0], params.gpsCoords[1]])
	message = getMessage(params)
	messageBody = "#{message} #{mapsLink}. #{config.endMessage}"

sendTheText = (params, cb) ->
	console.log("sendingText")
	console.log createBody(params)

	client.messages.create({
		body : createBody(params)
		to: params.number
		from: "+1 786-565-3629"
	}, (err, msg) ->
		console.log(err, msg)
		cb({success: "text message successfully sent"})
	)

textFriends = (params, cb) ->
	console.log(params.numbersToCall)
	params.numbersToCall.forEach((obj) ->
		params.number = obj.num
		params.name = obj.name

		sendTheText(params, cb)
	)

main = (req, res) ->
	cb = (message) ->
		res.send(200, message)

	console.log(req.body);

	# if req.body.mode == 'emergency'
	textFriends(req.body, cb)
	saveDetails(req.body)

module.exports = main
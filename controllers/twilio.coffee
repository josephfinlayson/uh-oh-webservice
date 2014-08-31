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
request = require 'request-json';
client = request.newClient('http://mapster-panickster.herokuapp.com/');


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
	"Hi #{params.name}, it's #{params.from.name}. I really need your help, you can find me here"


getOkMessage = (params) ->
	"Hi #{params.name}, it's #{params.from.name}.I'm OK now! Thanks for your help"


createBody = (params) ->
	mapsLink = getGoogleMapsLink([params.gpsCoords[0], params.gpsCoords[1]])
	message = getMessage(params)
	messageBody = "#{message} #{mapsLink}. #{config.endMessage}"


createOKBody = (params) ->
	message = getOkMessage(params)
	messageBody = "#{message}"

sendTheText = (params, cb,ressendIt) ->
	console.log("sendingText")
	if params.mode == "ok"
		message = createOKBody(params)
	else
		message = createBody(params)
	try
		client.messages.create({
			body : message
			to: params.number
			from: "+1 786-565-3629"
		}, (err, msg) ->
			console.log(err)
			if (ressendIt)
				cb({success: "text message successfully sent"})
		)
	catch e

textFriends = (params, cb) ->
	params.numbersToCall.forEach((obj, index) ->
		params.number = obj.num
		params.name = obj.name
		if (index+1 == params.numbersToCall.length)
			console.log("last item of array")
			ressendIt = true
		sendTheText(params, cb, ressendIt)
	)

main = (req, res) ->
	cb = (message) ->

		res.send(200, message)
	# if req.body.mode == 'emergency'
	textFriends(req.body, cb)
	saveDetails(req.body)
	panicksterReport(req.body)


panicksterReport = (params) ->
	obj  = {
		lat: params.gpsCoords[0]
		lng: params.gpsCoords[1]
		message: "Automated #{params.mode} report from uh-oh"
	}

	client.post('/incidents/report.json', obj, (err,msg)->
		console.log(err,msg)
	)


module.exports = main
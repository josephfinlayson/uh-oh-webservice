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


twilModel = mongoose.model('twilModel');
client = require('twilio')(config.accountSid, config.authToken);
request = require 'request-json';
mapsterClient = request.newClient('http://mapster-panickster.herokuapp.com/');


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
	"Sent using the Uh-Oh app: Hi #{params.name}. This is #{params.from.name}, I'm feeling a bit worried about my safety and wanted to let you know where I am. If you don't receive a message shortly saying I'm safe please call me or alert someone. Thanks "

getOkMessage = (params) ->
	"Sent using the Uh-Oh app: Hi #{params.name}. It's #{params.from.name}, I'm feeling safe again now. Thanks for watching out for me - you can download the Uh-Oh app for iOS or Android and I'll watch out for you too!"

createBody = (params) ->
	mapsLink = getGoogleMapsLink([params.gpsCoords[0], params.gpsCoords[1]])
	message = getMessage(params)
	messageBody = "#{message} #{mapsLink}."


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
		)
	catch e
		console.log e
	if (ressendIt)
		cb({success: "text message successfully sent"})
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
	console.log(req.body)
	console.log("req.body")

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

	mapsterClient.post('/incidents/report.json', obj, (err,msg)->
		# console.log(err,msg)
	)


module.exports = main
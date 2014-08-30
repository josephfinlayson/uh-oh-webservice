try
	config = require './config'
catch e
	console.log e

config.message = "Hi, I need some help, you can find me here "
config.endMessage = " Please come quickly, or call the police"

client = require('twilio')

saveDetails = (params) ->
	# saveDetails

getGoogleMapsLink = (params) ->
	"https://www.google.co.uk/maps/@#{params[0]},#{params[1]},17z"

createBody = (params) ->
	mapsLink = getGoogleMapsLink([params.gpsCoords[0], params.gpsCoords[1]])
	messageBody = "#{config.message}  #{mapsLink} #{config.endMessage}"

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
	params.numbersToCall.forEach((number) ->
		params.number = number
		sendTheText(params, cb)
	)

main = (req, res) ->
	cb = (message) ->
		res.send(200, message)

	console.log(req.body);

	if req.body.mode == 'emergency'
		textFriends(req.body, cb)

	saveDetails(req.body)

module.exports = main
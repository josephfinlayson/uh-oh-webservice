
config = require './config'

config.message = "Hi, I need some help, you can find me here "
config.endMessage = " Please come quickly, or call the police"

client = require('twilio')(config.accountSid, config.authToken);


saveDetails = (params) ->
	# saveDetails

getGoogleMapsLink = (params) ->
	"https://www.google.co.uk/maps/@#{param[0]},#{param[1]},17z"

createBody = (params) ->
	console.log("createBody");
	messageBody = "#{config.message}  #{getGoogleMapsLink(params.gpsCoords[0], params.gpsCoords[1])} #{config.endMessage}"
	console.log(messageBody)

sendTheText = (params) ->
	console.log("sendingText")
	client.messages.create({
		body : createBody(params)
		to: params.number
		from: "+1 786-565-3629"
	}, (err, msg) ->
		console.log(err, msg)
		res.send({success: "text message successfully sent"})
	)


textFriends = (params) ->
	console.log(params.numbersToCall)
	params.numbersToCall.forEach((number) ->
		params.number = number
		sendTheText(params)
	)

main = (req, res) ->
	console.log(req.body);
	if req.body.mode == 'emergency'
		textFriends(req.body)

	saveDetails(req.body)

module.exports = main
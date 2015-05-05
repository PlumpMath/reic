Customer = new Mongo.Collection("customer")
Payments = new Mongo.Collection("payments")

if Meteor.isClient
	
	# counter starts at 0
	Session.setDefault "counter", 0
	Template.hello.helpers counter: ->
		Session.get "counter"

	Template.hello.events "click button": ->
		
		# increment the counter when button is clicked
		Session.set "counter", Session.get("counter") + 1

		chargeAmount = 5000
		userName = 'Bob Johnson'
		StripeCheckout.open(
			key: 'pk_test_G6F7bXvkbxt9kERSp4UXAw4Y'
			amount: chargeAmount
			name: 'The Store'
			description: 'A whole bag of awesome ($50.00)'
			panelLabel: 'Pay Now'
			zipCode: true
			token: (res) ->
				console.info(res);
				Meteor.call('chargeCard', res.id, res.email, userName, chargeAmount)
		)
		return

	Meteor.startup ->

if Meteor.isServer
	Meteor.methods(
		'chargeCard': (stripeToken, email, userName, chargeAmount) ->
			Stripe = StripeAPI(Meteor.settings.stripe_sk)
			Stripe.customers.create({
				source: stripeToken
				description: userName
				email: email
			})
				.then (customer) ->
					console.log customer
					return Stripe.charges.create(
						amount: chargeAmount
						currency: 'usd'
						customer: customer.id
					)
				.then (charge) ->
					#saveStripeCustomerId
					console.log charge
					console.log "==="
					console.log email
	)

	Meteor.startup ->


# code to run on server at startup

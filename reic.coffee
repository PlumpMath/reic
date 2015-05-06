
if Meteor.isClient

	setMemberNumber = () ->
		Meteor.call("getMemberNumber", (err, response) ->
			Session.set("memberNumber", response)
		)

	Template.info.helpers
		"memberNumber": ->
			if(! Session.get "memberNumber")
				setMemberNumber()
			return Session.get "memberNumber" || []

	Template.signup.helpers
		"memberInfo": ->
			console.log Session.get "memberInfo" || {} 
			return Session.get "memberInfo" || {} 

	Template.signup.events
		"click button#email-submit": ->
			event.preventDefault();

			# button doesn't do anything if form is invalid
			if(! document.getElementById("member-signup").checkValidity())
				return
			# button doesn't do anything if we don't have the customer number (id) yet
			if(! Session.get "memberNumber")
				return

			firstName = $("#member-first-name").val()
			lastName = $("#member-last-name").val()
			memberEmail = $("#member-email").val()
			chargeAmount = 1000
			memberNumber = Session.get("memberNumber")  + 1
			memberDescription = "##" + memberNumber + "||" + firstName + '||' + lastName

			StripeCheckout.open(
				key: 'pk_test_G6F7bXvkbxt9kERSp4UXAw4Y'
				amount: chargeAmount
				email: memberEmail
				name: 'REIC MEMBERSHIP'
				description: 'YOUR NAME: ' + firstName + " " + lastName
				panelLabel: 'JOIN:'
				zipCode: true
				token: (res) ->
					Meteor.call('chargeCard', res.id, res.email, memberDescription, chargeAmount)
					# yay success
					Session.set("memberInfo", 
						firstName: firstName
						lastName: lastName
						memberEmail: memberEmail
						memberNumber: memberNumber
					)
					$("#signup-card").flip(true, { trigger: 'manual', speed: 1000 })
			)
			return

	Meteor.startup ->
		$("#signup-card").flip({
			axis: "y"
			reverse: false
			trigger: "manual"
			speed: 1000
		});

if Meteor.isServer
	Meteor.methods(
		'chargeCard': (stripeToken, email, memberDescription, chargeAmount) ->
			Stripe = StripeAPI(Meteor.settings.stripe_sk)
			Stripe.customers.create({
				source: stripeToken
				description: memberDescription
				email: email
			})
				.then (customer) ->
					#console.log customer
					return Stripe.charges.create(
						amount: chargeAmount
						currency: 'usd'
						customer: customer.id
					)
				.then (charge) ->
					#saveStripeMemberId
					#console.log charge
					#console.log email

		'getMemberNumber': (callback) ->
			Stripe = StripeAPI(Meteor.settings.stripe_sk)
			list = Meteor.wrapAsync(Stripe.customers.list, Stripe.customers)
			result = list(
				"include[]": "total_count" 
			)
			console.log result
			return result.total_count
	)

	Meteor.startup ->



Feature: An application for asset management
	In order for different people to use TransAM
	The users
	Should be able to Log in and out with correct credentials

	Background:
		Given A user with email "jsoloski@catabus.com"

Scenario: Login
	When "jsoloski@catabus.com" logs in using valid user data
	Then I will see "Dashboard"

Scenario: Forgot your password
	When I start the app
	Then I will see "Forgot Your Password?"
	# TODO:Finish scenario
	#Then show me the page

Scenario: Log in with incorrect credentials
	When "jsoloski@catabus.com" logs in using invalid user data
	Then I will see "Sign in"

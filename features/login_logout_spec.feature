Feature: An application for asset management
	In order for different people to use TransAM
	The users
	Should be able to Log in and out with correct credentials

	Background:
		Given A user with email "jsoloski@catabus.com"

Scenario: Login
	When "jsoloski@catabus.com" logs in using valid user data
	Then I will see "Asset Summary"

Scenario: Forgot your password
	When I start the app
		And I press the link "Forgot Your Password?"
		And I fill out the forgotten password form with "jsoloski@catabus.com"
	Then I will see "Please sign in"
	# TODO: finish

Scenario: Log in with incorrect credentials
	When "jsoloski@catabus.com" logs in using invalid user data
	Then I will see "Please sign in"

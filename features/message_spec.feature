Feature: Messaging Feature
  In order for different people to message each other within TransAM
  The users
  Should be able to send and receive messages

Background:
  Given A user with email "jsoloski@catabus.com"
    And "jsoloski@catabus.com" logs in using valid user data

Scenario: Creating a new message
  When I am at the "New Message" page
    And I create a [message] with {:to_user_id => "joe normal", :subject => "Test Subject", :body => "Hi, This is a test email."}
  Then I will see "New Messages (1)"
  #Then show me the page

Feature: Messaging Feature
  In order for different people to message each other within TransAM
  The users
  Should be able to send and receive messages

Scenario: Creating a new message
  Given A user with email "jsoloski@catabus.com"
    And a [message] exists for "jsoloski@catabus.com"
    And "jsoloski@catabus.com" logs in using valid user data
  When I am at My Messages page for "jsoloski@catabus.com"
  Then I will see "Test Email Subject"

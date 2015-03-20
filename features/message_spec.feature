Feature: Messaging Feature
  In order for different people to message each other within TransAM
  The users
  Should be able to send and receive messages

Scenario: Creating a new message
  Given A user with email "jsoloski@catabus.com"
    And a [message] exists for "jsoloski@catabus.com"
    And "jsoloski@catabus.com" logs in using valid user data
  Then I will see "Test Email Subject"

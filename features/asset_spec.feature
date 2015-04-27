Feature: Users can manage an [asset]
     In order to make corrections or updates to an asset
     The website user
     Should be able to view, edit, and perform updates on asset

Background:
  Given A user with email "jsoloski@catabus.com"
    And "jsoloski@catabus.com" logs in using valid user data
    And an [equipment] exists
    And I am at the [equipment] detail page

Scenario: Updating the master record for an [equipment]
  When I press the link "Update the master record"
    And I update an [equipment] with {'external_id' => "EXTERNALID TEST 1"}
  Then I am at the [equipment] detail page
    And I will see "EXTERNALID TEST 1"

Scenario: Updating the condition event
  When I press the link "Update the condition"
    And I create an [condition_update_event] with {:assessed_rating => "4.0"}
  Then I will see "Good"

Scenario: Updating the service status
  When I press the link "Update the service status"
    And I create an [service_status_update_event] with {:service_status_type_id => "In Service"}
  Then I will see "In Service"

Scenario: Recording final disposition
  When I press the link "Record final disposition"
    And I create an [disposition_update_event] with {:disposition_type_id => "Public Sale", :sales_proceeds => "5000"}
  Then I will see "Public Sale"

Scenario: Deleting an asset
  When I press the link "Remove this asset"
  Then I will not see "equipment test"

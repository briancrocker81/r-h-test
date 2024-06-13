require "application_system_test_case"

class MeetingsTest < ApplicationSystemTestCase
  setup do
    @event = meetings(:one)
  end

  test "visiting the index" do
    visit events_url
    assert_selector "h1", text: "Meetings"
  end

  test "creating a Event" do
    visit events_url
    click_on "New Event"

    fill_in "Name", with: @event.name
    fill_in "Start time", with: @event.start_time
    click_on "Create Event"

    assert_text "Event was successfully created"
    click_on "Back"
  end

  test "updating a Event" do
    visit events_url
    click_on "Edit", match: :first

    fill_in "Name", with: @event.name
    fill_in "Start time", with: @event.start_time
    click_on "Update Event"

    assert_text "Event was successfully updated"
    click_on "Back"
  end

  test "destroying a Event" do
    visit events_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Event was successfully destroyed"
  end
end

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  context '#send_event_email' do
    setup do
      @automation_mail = ManageAutomationMail.create!(mail_type: 'Event Mailer', automation: true, mail_methods: ['send_event_mail_to_tenat'])
      landlord = Landlord.create!(
        contact_name: 'Barry',
        email: 'barry@test.com',
        partnership_format: 'Complete Partner'
      )
      property_one = Property.create!(
        landlord: landlord,
        street: 'Barry Street',
        postcode: 'BA1 RRY'
      )
      room_one = Room.create!(property: property_one, number: 1)
      tenancy_one = Tenancy.create!(
        room: room_one,
        email: 'tenancy1@test.com',
        year: '21/22',
        first_name: 'Tenancy',
        surname: '1',
        tenancy_start: 7.days.ago,
        tenancy_end: 7.days.from_now
      )

      room_two = Room.create!(property: property_one, number: 2)
      tenancy_two = Tenancy.create!(
        room: room_two,
        email: 'tenancy2@test.com',
        year: '21/22',
        first_name: 'Tenancy',
        surname: '2',
        tenancy_start: 7.days.ago,
        tenancy_end: 6.days.ago
      )

      property_two = Property.create!(
        landlord: landlord,
        street: 'Barry Road',
        postcode: 'BA2 RRY'
      )
      room_three = Room.create!(property: property_two, number: 1)
      tenancy_three = Tenancy.create!(
        room: room_three,
        email: 'tenancy3@test.com',
        year: '21/22',
        first_name: 'Tenancy',
        surname: '3',
        tenancy_start: 7.days.ago,
        tenancy_end: 7.days.from_now
      )

      room_four = Room.create!(property: property_two, number: 1)
      tenancy_four = Tenancy.create!(
        room: room_four,
        email: 'tenancy4@test.com',
        year: '21/22',
        first_name: 'Tenancy',
        surname: '4',
        tenancy_start: 7.days.ago,
        tenancy_end: 7.days.from_now
      )

      room_five = Room.create!(property: property_two, number: 5)
      tenancy_five = Tenancy.create!(
        room: room_five,
        email: 'tenancy4@test.com',
        year: '21/22',
        first_name: 'Tenancy',
        surname: '4',
        tenancy_start: 7.days.ago,
        tenancy_end: 7.days.from_now
      )
      [tenancy_one, tenancy_two, tenancy_three, tenancy_four].each do |tenancy|
        tenancy.update!(booking_status: 'complete')
      end

      @properties = [property_one, property_two]
      ActionMailer::Base.deliveries = []
    end

    should 'do nothing if manage automation mail is disabled' do
      @automation_mail.update!(automation: false)

      event = Event.create!(
        client_email: 'client@test.com',
        start: 12.hours.from_now,
        end: 13.hours.from_now,
        event_type: 'test',
        client_contact_number: '07777777777',
        budget_per_month: '0',
        budget_per_week: '0',
        properties: @properties
      )
      assert_no_difference('ActionMailer::Base.deliveries.size') do
        event.send_event_email
      end
    end

    should 'do nothing if manage automation mail is not set' do
      @automation_mail.destroy!

      event = Event.create!(
        client_email: 'client@test.com',
        start: 12.hours.from_now,
        end: 13.hours.from_now,
        event_type: 'test',
        client_contact_number: '07777777777',
        budget_per_month: '0',
        budget_per_week: '0',
        properties: @properties
      )
      assert_no_difference('ActionMailer::Base.deliveries.size') do
        event.send_event_email
      end
    end

    should 'send only tenant mails if there is no client_email' do
      event = Event.create!(
        client_email: nil,
        start: 12.hours.from_now,
        end: 13.hours.from_now,
        event_type: 'test',
        client_contact_number: '07777777777',
        budget_per_month: '0',
        budget_per_week: '0',
        properties: @properties
      )
      assert_difference('ActionMailer::Base.deliveries.size', 3) do
        event.send_event_email
      end
      email_addresses = ActionMailer::Base.deliveries.map(&:to).flatten
      assert_equal %w[tenancy1@test.com tenancy3@test.com tenancy4@test.com], email_addresses
    end

    should 'send emails if date is somehow in the past' do
      event = Event.create!(
        client_email: 'client@test.com',
        start: 26.hours.ago,
        end: 25.hours.ago,
        event_type: 'test',
        client_contact_number: '07777777777',
        budget_per_month: '0',
        budget_per_week: '0',
        properties: @properties
      )
      assert_difference('ActionMailer::Base.deliveries.size', 4) do
        event.send_event_email
      end
    end

    should 'do nothing if date is over 25 hours from now' do
      event = Event.create!(
        client_email: 'client@test.com',
        start: 25.hours.from_now + 2.seconds,
        end: 26.hours.from_now,
        event_type: 'test',
        client_contact_number: '07777777777',
        budget_per_month: '0',
        budget_per_week: '0',
        properties: @properties
      )
      assert_no_difference('ActionMailer::Base.deliveries.size') do
        event.send_event_email
      end
    end

    context 'when the date is within 25 hours' do
      setup do 
        @event = Event.create!(
          client_email: 'client@test.com',
          start: 25.hours.from_now - 2.seconds,
          end: 26.hours.from_now,
          event_type: 'test',
          client_contact_number: '07777777777',
          budget_per_month: '0',
          budget_per_week: '0',
          properties: @properties
        )
      end

      should 'send an email to the "client"' do
        @event.send_event_email
        client_mail = ActionMailer::Base.deliveries.first
        assert_equal ['client@test.com'], client_mail.to
        assert_equal 'Appointment Scheduled', client_mail.subject
      end

      should 'send an email to each tenant in each room right now' do
        @event.send_event_email
        assert_equal 4, ActionMailer::Base.deliveries.size

        tenant_mails = ActionMailer::Base.deliveries[1..]

        assert_equal ['tenancy1@test.com'], tenant_mails[0].to
        assert_equal 'Appointment Scheduled', tenant_mails[0].subject

        # No Tenant 2 as they are a past tenant

        assert_equal ['tenancy3@test.com'], tenant_mails[1].to
        assert_equal 'Appointment Scheduled', tenant_mails[1].subject

        assert_equal ['tenancy4@test.com'], tenant_mails[2].to
        assert_equal 'Appointment Scheduled', tenant_mails[2].subject
      end

      should 'set mail sent values' do
        refute @event.mail_sent
        assert_nil @event.mail_sent_at
        @event.send_event_email
        assert @event.reload.mail_sent
        assert_not_nil @event.mail_sent_at
      end
    end
  end
end

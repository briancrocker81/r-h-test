$(document).on('turbolinks:load', function() {
  // Function to handle form inputs b
  // ased on the selected option

  if ($('body').hasClass('events')) {

      function formInputs(option) {
      var $fieldType = $('.field-type');
      var $viewingInfoView = $('.viewing-info-view');
      var $notesView = $('.notes-view');
      var $eventInfoView = $('.event-info-view');
      var $propertiesView = $('.properties-view');

      $fieldType.show();

      switch (option) {
        case '1':
        case '2':
          $viewingInfoView.show();
          $notesView.show();
          $eventInfoView.show();
          $propertiesView.show();
          break;
        case '3':
        case '4':
        case '5':
          $viewingInfoView.hide();
          $eventInfoView.show();
          $propertiesView.show();
          $notesView.show();
          break;
        case '6':
          $propertiesView.hide();
          $viewingInfoView.hide();
          $eventInfoView.show();
          $notesView.show();
          break;
        default:
          $fieldType.hide();
      }

      console.log('Option: ' + option);
    }

    // Event listener for change in event type
    $(document).on('change', '#event_event_type', function() {
      var option = $(this).val();
      formInputs(option);
    });

    // Initialize form inputs based on the initially selected option
    formInputs($('#event_event_type option:selected').val());

    // Event listener for room button click
    $(document).on('click', '.bt-room', function() {
      $('#property-selection, #view_property_ul').slideDown();
    });

    // Event listener for color picker
    $(document).on('click', '#colour-picker li', function() {
      if (!$(this).hasClass('disabled')) {
        $('#colour-picker li').removeClass('selected');
        $(this).addClass('selected');
        $('#user_colour').val($(this).data('colour-val'));
      }
    });
  }
});

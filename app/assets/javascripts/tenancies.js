$(document).on('ready turbolinks:load', function() {
  if( window.location.pathname.split('/')[2] == 'booking_form'){
    var tenancy_form_id = window.location.pathname.split('/')[3];

    $('#edit_tenancy_'+tenancy_form_id).submit(function(event){
      if(!validate_booking_form()){
        event.preventDefault();
        return false;
      }
    });

    $('#tenancy_first_name').on('keyup', function(){
      $('#first_name_error').text('');
    });

    $('#tenancy_mobile').on('keyup', function(){
      $('#mobile_error').text('');
    });

    $('#tenancy_email').on('keyup', function(){
      $('#email_error').text('');
    });

    $('#tenancy_nationality').on('keyup', function(){
      $('#nationality_error').text('');
    });

    $('#tenancy_year').on('keyup', function(){
      $('#tenancy_year_error').text('');
    });


    $(document).ready(function() {
      if($('select#tenancy_tenancy_is option:checked').val() == 0){
        $('.professional-fields').hide();
        $('.student-fields').show();
      } else {
        $('.student-fields').hide();
        $('.professional-fields').show();
      }
    });


    $('#tenancy_tenancy_is').change(function(){
      if($(this).val() == '0'){
        $('.professional-fields').hide();
        $('.student-fields').show();
      } else {
        $('.student-fields').hide();
        $('.professional-fields').show();
      }
    });

    function validate_booking_form(){
      var first_name = $('#tenancy_first_name').val();
      // var surname = $('#tenancy_surname').val();

      var date = $('#tenancy_dob_3i').val();
      var month = $('#tenancy_dob_2i').val();
      var year = $('#tenancy_dob_1i').val();

      var mobile = $('#tenancy_mobile').val();
      var email = $('#tenancy_email').val();
      var nationality = $('#tenancy_nationality').val();
      var fyear = $('#tenancy_year').val();
      // var criminal_record = $('#criminal-record').is(":checked");
      // var status = $('#status').is(":checked");

      if (first_name == ''){
        $('#first_name_error').text('First name required!');
        return false;
      }

      if ( date == '' || month == '' || year == ''){
        $('#dob_error').text('Date of birth required!');
        return false;
      }

      if ( mobile == ''){
        $('#mobile_error').text('Mobile number required!');
        return false;
      }

      if ( email == ''){
        $('#email_error').text('Email required!');
        return false;
      }

      if ( nationality == ''){
        $('#nationality_error').text('Nationality required!');
        return false;
      }

      if ( fyear == ''){
        $('#tenancy_year_error').text('Year required!');
        return false;
      }
      return true;
    }

    $('#tenancy_criminal_record').click(function() {
      if( $(this).is(':checked')) {
        $("#criminal-record").show();
      } else {
        $("#criminal-record").hide();
      }
    });
  }

  if( window.location.pathname.split('/')[2] == 'agreement_form'){
    $(document).ready(function(){
      var tenancy_form_id = window.location.pathname.split('/')[3];

      $('#edit_tenancy_'+tenancy_form_id).submit(function(event){
        if(!validate_booking_form()){
          event.preventDefault();
          return false;
        }
      });

      $('#tenancy_id_proof_no').on('keyup', function(){
        $('#id_proof_no_error').text('');
      });

      $('#tenancy_id_proof_image').on('click', function(){
        $('#id_proof_image_error').text('');
      });

      $('#tenancy_address').on('keyup', function(){
        $('#address_error').text('');
      });

      $('#tenancy_state').on('keyup', function(){
        $('#state_error').text('');
      });

      $('#tenancy_city').on('keyup', function(){
        $('#city_error').text('');
      });

      $('#tenancy_zip').on('keyup', function(){
        $('#zip_error').text('');
      });

      $('#tenancy_signature').on('click', function(){
        $('#signature_error').text('');
      });

      $('#accept-agreement').on('keyup', function(){
        $('#accept_agreement_error').text('');
      });
      function validate_booking_form(){
        var id_proof_no = $('#tenancy_id_proof_no').val();
        var id_proof_image = $('#tenancy_id_proof_image').val();
        var address = $('#tenancy_address').val();
        var state = $('#tenancy_state').val();
        var city = $('#tenancy_city').val();
        var zip = $('#tenancy_zip').val();
        var signature = $('#tenancy_signature').val();
        var accept_agreement = $('#accept-agreement').is(":checked");

        if (id_proof_no == ''){
          $('#id_proof_no_error').text('Id proof required!');
          return false;
        }

        if ( id_proof_image == ''){
          $('#id_proof_image_error').text('Id proof image/pdf required!');
          return false;
        }

        if ( address == ''){
          $('#address_error').text('Address required!');
          return false;
        }

        if ( state == ''){
          $('#state_error').text('State required!');
          return false;
        }

        if ( city == ''){
          $('#city_error').text('City required!');
          return false;
        }

        if ( zip == ''){
          $('#zip_error').text('Zip required!');
          return false;
        }

        if ( signature == ''){
          $('#signature_error').text('signature image/pdf required!');
          return false;
        }

        if ( accept_agreement == false){
          $('#accept_agreement_error').text('You need to agree!');
          return false;
        }
        return true;
      }
    });
  }

  if( window.location.pathname.split('/')[2] == 'document_confirmation_form'){
    $(document).ready(function(){
      var tenancy_form_id = window.location.pathname.split('/')[3];

      $('#edit_tenancy_'+tenancy_form_id).submit(function(event){
        if(!validate_booking_form()){
          event.preventDefault();
          return false;
        }
      });
      $('#read-doc').on('click', function(){
        $('#read_doc_error').text('');
      });
      function validate_booking_form(){
        var read_agreement = $('#read-doc').is(":checked");

        if ( read_agreement == false){
          $('#read_doc_error').text('You need to agree!');
          return false;
        }
        return true;
      }
    });
  }

  $('.edit_guarantor, .new_guarantor').submit(function(event){
    // console.log($('#guarantor_confirm_guarantor').is('checked'));
    if($('#guarantor_confirm_guarantor').length > 0) {
      if(!$('#guarantor_confirm_guarantor').prop('checked')){
        if($('.guarantor_confirm_guarantor').find('.form-check').find('.invalid-feedback').length > 0){
          $('.guarantor_confirm_guarantor').find('.form-check').find('.invalid-feedback').html("Please agree to confirm");
        } else {
          $('#guarantor_confirm_guarantor').addClass('is-invalid');
          $('.guarantor_confirm_guarantor').find('.form-check').append('<div class="invalid-feedback">Please agree to confirm</div>');
        }
        return false;
      }
    }
  });

  $('#editTenancy').submit(function(event){
    console.log('tetstt');
    // console.log($('#guarantor_confirm_guarantor').is('checked'));
    if($('#tenancy_confirm_tenancy').length > 0 ) {
      if(!$('#tenancy_confirm_tenancy').prop('checked')){
        if($('.tenancy_confirm_tenancy').find('.form-check').find('.invalid-feedback').length > 0){
          $('.tenancy_confirm_tenancy').find('.form-check').find('.invalid-feedback').html("Please agree to confirm");
        } else {
          $('#tenancy_confirm_tenancy').addClass('is-invalid');
          $('.tenancy_confirm_tenancy').find('.form-check').append('<div class="invalid-feedback">Please agree to confirm</div>');
        }
        return false;
      }
    }
    if($('#tenancy_read_doc').length > 0 ) {
      if(!$('#tenancy_read_doc').prop('checked')){
        if($('.tenancy_read_doc').find('.form-check').find('.invalid-feedback').length > 0){
          $('.tenancy_read_doc').find('.form-check').find('.invalid-feedback').html("Please agree to read");
        } else {
          $('#tenancy_read_doc').addClass('is-invalid');
          $('.tenancy_read_doc').find('.form-check').append('<div class="invalid-feedback">Please agree to read</div>');
        }
        return false;
      }
    }
    if($('#tenancy_accept_agreement').length > 0 ) {
      if(!$('#tenancy_accept_agreement').prop('checked')){
        if($('.tenancy_accept_agreement').find('.form-check').find('.invalid-feedback').length > 0){
          $('.tenancy_accept_agreement').find('.form-check').find('.invalid-feedback').html("Please accept the agreement");
        } else {
          $('#tenancy_accept_agreement').addClass('is-invalid');
          $('.tenancy_accept_agreement').find('.form-check').append('<div class="invalid-feedback">Please accept the agreement</div>');
        }
        return false;
      }
    }
  });

  $('.tenancy-id-proof').on('change', function(){
    var id_name = $(this).val();
    var id = $(this).attr('id').split("_")[4];
    if(id_name == 'other'){
      $(this).closest('div').append('<br><input type="text" name="tenancy[tenancy_identifications_attributes]['+id+'][id_proof_name]" >');
    }
  });
  $('#tenancy_identifications').on('cocoon:after-insert', function() {
    $('.tenancy-id-proof').on('change', function(){
      var id_name = $(this).val();
      var id = $(this).attr('id').split("_")[4];
      if(id_name == 'other'){
        $(this).closest('div').append('<br><input type="text" name="tenancy[tenancy_identifications_attributes]['+id+'][id_proof_name]" >');
      }
    });
  });

  $("#tenancy_tenant_type").on('change load', function(){
    var tenant_type = $(this).val();
    if (tenant_type==1 || tenant_type == 2){
      student_tenancy_length();
    }else{
      tenancy_length();
    }
  });
  if ($("#tenancy_tenant_type").val()==1 || $("#tenancy_tenant_type").val()==2){
    student_tenancy_length();
  }else{
    tenancy_length();
  }

  function student_tenancy_length(){
    var d = new Date();
    current_year = d.getFullYear();
    next_year = d.getFullYear()+1;

    //Start tenanct**************
    // $('#tenancy_tenancy_start_1i').val(current_year);
    // $('#tenancy_tenancy_start_2i').val("9");
    // $('#tenancy_tenancy_start_3i').val("1");
    //
    // //End Tenancy****************
    // $('#tenancy_tenancy_end_1i').val(next_year);
    // $('#tenancy_tenancy_end_2i').val("8");
    // $('#tenancy_tenancy_end_3i').val("17");
  }

  function tenancy_length(){

    //Start tenanct**************
    // $("#tenancy_tenancy_start_1i").children('option').remove();
    // $("#tenancy_tenancy_end_1i").children('option').remove();
    // var year = 2019;
    // for (var i = 17 - 1; i >= 0; i--) {
    //   $("#tenancy_tenancy_start_1i").append('<option value="'+year+'">'+year+'</option>');
    //   $("#tenancy_tenancy_end_1i").append('<option value="'+year+'">'+year+'</option>');
    //   year += 1;
    // }
    //
    // $("#tenancy_tenancy_start_2i").children('option').remove();
    // $("#tenancy_tenancy_end_2i").children('option').remove();
    // var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    // for(var i = 0; i < monthNames.length; i++){
    //   $("#tenancy_tenancy_start_2i").append('<option value="'+(i+1)+'">'+monthNames[i]+'</option>');
    //   $("#tenancy_tenancy_end_2i").append('<option value="'+(i+1)+'">'+monthNames[i]+'</option>');
    // }
    //
    // $("#tenancy_tenancy_start_3i").children('option').remove();
    //
    // for (i = 1; i < 32; i++) {
    //   $("#tenancy_tenancy_start_3i").append('<option value="'+i+'">'+i+'</option>');
    //   $("#tenancy_tenancy_end_3i").append('<option value="'+i+'">'+i+'</option>');
    // }
  }

  if ($('#secondary_contact_check').is(':checked')) {
    $("#secondary_contact").css('display','block');
  }

  // Document preview
  DocumentPreview();



  $('.edit_tenancy, .new_tenancy').submit(function(event){
    if($(this).data('valid') == true) {
      if(!validate_card()){
        return false;
      }
    }
  });

  var day, month, year;
  // set_tenancy_number_of_months($('#tenancy_number_of_weeks').val());
  // Get the months
  $('#tenancy_number_of_weeks').on('keyup', function(){
    // set_tenancy_number_of_months($(this).val());
  })

  // Get the weeks
  // $('#tenancy_number_of_months').on('keyup', function(){
  //   day = $('#tenancy_tenancy_start_1i').val();
  //   month = $('#tenancy_tenancy_start_2i').val();
  //   year = $('#tenancy_tenancy_start_3i').val();
  //   var endDate = moment(day + '-' + month + '-' + year).add(parseInt($(this).val()), 'months');
  //   var startDate = moment(day + '-' + month + '-' + year);
  //   var weeks = endDate.diff(startDate, 'weeks');
  //   $('#tenancy_number_of_weeks').val(weeks);
  // })
  //
  // function set_tenancy_number_of_months(weeks){
  //   console.log(weeks);
  //   day = $('#tenancy_tenancy_start_1i').val();
  //   month = $('#tenancy_tenancy_start_2i').val();
  //   year = $('#tenancy_tenancy_start_3i').val();
  //   var endDate = moment(day + '-' + month + '-' + year).add(parseInt(weeks), 'weeks');
  //   var startDate = moment(day +'-' + month + '-' + year);
  //   months = endDate.diff(startDate, 'months');
  //   $('#tenancy_number_of_months').val(months);
  // }

  function validate_card(){
    var status = true
    var expiryMonth = $('#tenancy_payment_card_expiry_2i');
    var expiryYear = $('#tenancy_payment_card_expiry_1i');
    var month = expiryMonth.val();
    var year = expiryYear.val();
    console.log(month, year);
    // Create a date object from month and year, on the first
    // of that month. You could check the end of the month
    // but that would be a little more complicated as you'd need
    // to know how many days are in that month.
    var expiryDate = new Date(year + '-' + month + '-01');

    // You can compare date objects, this says if the expiryDate is
    // less than todays date, i.e. in the past. You could do <= if
    // you want to check whether they're the same date aswell.
    if($('#tenancy_payment_card_pan').val() == ''){
      $('#payment_card_pan_error').html('please add the valid card!');
      status = false;
    } else {
      $('#payment_card_pan_error').html('');
    }
    if($('#tenancy_payment_card_cvc').val() == ''){
      $('#payment_card_cvc_error').html('Please add valid cvv');
      status = false;
    } else {
      $('#payment_card_cvc_error').html('');

    }
    if ((month != undefined && year != undefined) && expiryDate < new Date()) {
      $('#payment_card_expiry_error').html('Please check your card details');
      status = false;
      // Fails validation, show some error message to user
      $('.js-error').css('display','block');
      if ($('.error-list').find('#card-error').length >= 1){
        $('.error-list').find('#card-error').replaceWith('<li id="card-error">Please check your card details</li>')
      }else{
        $('.error-list').append('<li id="card-error">Please check your card details</li>')
      }
      $('#card-expiry-error').text("Please check your card details");
    } else {
      $('#payment_card_expiry_error').html('');
    }
    if(status){
      $('#payment_card_pan_error').html('');
      $('#payment_card_expiry_error').html('');
      $('#payment_card_cvc_error').html('');
      $('.js-error').css('display','none');
    }
    console.log(status);
    return status;
  }

  //Tenancy start and year chnages
  Tenancy();

    // $('#tenancy_tenancy_start_3i')
    // $('#tenancy_tenancy_start_2i')
    // $('#tenancy_tenancy_start_1i')
  // })

  $('#enable-guarantor-dashboard').click(function(){
    $(this).hide();
    $('#guarantor-dashboard-data').fadeIn('slow');
  });

  $('#tenancy_guarantor_attributes_confirm_guarantor, #tenancy_guarantor_attributes_confirm_signed_tenancy').on('change', function() {
    $('#tenancy_guarantor_attributes_complete_guarantor_agreement').prop('checked',false);
  });

  $( ".card-header" ).click(function() {
    $(this).toggleClass('open');
  });

});

// Onload check set property rental type
$( document ).on('turbolinks:load', function() {
  var rental_type = $('input[name="property[rental_type]"]:checked').val();
  show_div(rental_type);
});

$(document).on('click','.property_rental_type',function() {
  var rental_type = $('input[name="property[rental_type]"]:checked').val();
  show_div(rental_type);
});

function show_div(prp) {
  if (prp == 'home' ) {
    $('#home-rental-price').fadeIn();
    $('#add-room-btn').fadeOut();
    $('.number_of_bedrooms').fadeOut();
    $('.room_price').fadeOut();
  }
  else if(prp === undefined) {
    $('#home-rental-price').fadeOut();
    $('#add-room-btn').fadeOut();
    $('.number_of_bedrooms').fadeOut();
    $('.room_price').fadeOut();
  } else{
    $('#home-rental-price').fadeOut();
    $('#add-room-btn').fadeIn();
    $('.number_of_bedrooms').fadeIn();
    $('.room_price').fadeIn();
  }
}

// Property type checks
$(document).on('click','.property_property_type',function() {
  // var stu_rental = $('input[name="property[property_type][]"]:checked', '#pills-tabContent.property-tabs').val();
  // var stu_rental = $('#property_property_type_student');
  // console.log(stu_rental);
  // if (stu_rental) {
  //   console.log('yes');
  // }
});


//Form Validation for property, rooms, address inputs
$(document).ready(function(){
  $('#next-room-form').on('click', function(){
    if(vaildate_property()){
      $('#pills-rooms-tab').trigger('click');
    }
  });
  $('.pills-rooms').on('click', function(){
    if(!vaildate_property()){
      return false;
    }
  });
  $('.edit_property, .new_property').submit(function(event){
    if(!vaildate_property()){
      return false;
    }
  });
  function vaildate_property() {
    var property_landlord_id = $('#property_landlord_id').val();
    if(property_landlord_id == ''){
      $('#property_landlord_id_error').text('You must have to select landlord!');
      return false;
    }
    if($('.property_rental_type').find('input[type=radio]:checked').length == 0){
      $('#property_rental_type_error').text('You must have to select property rental type');
      return false;
    }else{
      if ($('#property_rental_type_home').is(':checked')){
        if($('#property_home_rental_price').val() == '' || $('#property_home_rental_price').val() == 0) {
          $('#property_home_rental_price_error').text('Enter home rental price and must be greater than zero!');
          return false;
        }
      } else{
        if($('#property_rental_type_room').is(':checked')){
          if($('#property_room_rental_price').val() == '' || $('#property_room_rental_price').val() == 0) {
            $('#property_room_rental_price_error').text('Enter room rental price and must be greater than zero!');
            return false;
          }
        }
        if($('#property_number_of_bedrooms').val() == 0 || $('#property_number_of_bedrooms').val() == ''){
          $('#property_number_of_bedrooms_error').text('You must select number of rooms!');
          return false;
        } else if($('#property-room-price').val() == '' || $('#property-room-price').val() == 0){
          $('#room_price_error').text('Room price needed!');
          return false;
        }
      }
    }
    if($('.property_property_type').find('input[type=checkbox]:checked').length == 0){
      $('#property_type_error').text('You must have to select property type');
      return false;
    }
    return true;
  }

  $('#prev-property-form').on('click', function(){
    $('#pills-property-tab').trigger('click');
  });
  $('#prev-room-form').on('click', function(){
    $('#pills-rooms-tab').trigger('click');
  });
  $('#property_landlord_id').on('change', function(){
    var property_landlord_id = $('#property_landlord_id').val();
    if(property_landlord_id == ''){
      $('#property_landlord_id_error').text('You must have to select landlord!');
    }else{
      $('#property_landlord_id_error').text('');
    }
  });
  $('.property_property_type').on('click', function(){
    if($('.property_property_type').find('input[type=checkbox]:checked').length == 0){
      $('#property_type_error').text('You must have to select property type');
    }else{
      $('#property_type_error').text('');
    }
  });

  $('.property_rental_type').on('click', function(){
    if($('.property_rental_type').find('input[type=radio]:checked').length == 0){
      $('#property_rental_type_error').text('You must have to select property rental type');
    }else{
      if ($('#property_rental_type_0').is(':checked')){
        if($('#property_home_rental_price').val() == '' || $('#property_home_rental_price').val() == 0) {
          $('#property_home_rental_price_error').text('Enter home rental price and must be greater than zero!');
        }else{
          $('#property_home_rental_price_error').text('');
        }
      }
      $('#property_rental_type_error').text('');
    }
  });

  $('#property_home_rental_price').on('change', function(){
    if($('#property_home_rental_price').val() > 0){
      $('#property_home_rental_price_error').text('');
    }else{
      $('#property_home_rental_price_error').text('Enter home rental price and must be greater than zero!');
    }
  });

// Validation for rooms
  $('#next-compilance-documents-form').on('click', function(){
    if(validate_rooms()){
      $('#pills-property-document-tab').trigger('click');
    }
  });

  $('.pills-property-documents').on('click', function(){
    if(!validate_rooms()){
      return false;
    }
  });

  function validate_rooms() {
    var property_no_of_bedrooms = $('#property_number_of_bedrooms').val();
    var property_no_of_bathrooms = $('#property_number_of_bathrooms').val();
    if(property_no_of_bedrooms == ''){
      $('#property_number_of_bedrooms_error').text('Please enter number of bedrooms!');
      return false;
    }
    if(property_no_of_bathrooms == ''){
      $('#property_number_of_bathrooms_error').text('Please enter number of bathrooms!');
      return false;
    }
    return true;
  }

  $('#property_number_of_bedrooms').on('change', function(){
    var property_no_of_bedrooms = $('#property_number_of_bedrooms').val();
    if(property_no_of_bedrooms != ''){
      $('#property_number_of_bedrooms_error').text('');
    }
  });
  $('#property_number_of_bathrooms').on('change', function(){
    var property_no_of_bathrooms = $('#property_number_of_bathrooms').val();
    if(property_no_of_bathrooms != ''){
      $('#property_number_of_bathrooms_error').text('');
    }
  });

// Validation for compilance documents
  $('#next-address-form').on('click', function(){
    if(validate_compilance_documents()){
      $('#pills-address-tab').trigger('click');
    }
  });

  $('.pills-address').on('click', function(){
    if(!validate_compilance_documents()){
      return false;
    }
  });

  function validate_compilance_documents() {
    return true;
  }

//Address validation
//   $('.simple_form').submit(function(event){
//     if(!validate_address()){
//       return false;
//     }
//   });
  // function validate_address(){
  //   var property_no = $('#property_number').val();
  //   var property_street = $('#property_street').val();
  //   // var property_address_line_2 = $('#property_address_line_2').val();
  //   // var property_city = $('#city').val();
  //   // var property_county = $('#property_county').val();
  //   // var property_postcode = $('#property_postcode').val();
  //   if(property_no == ''){
  //     $('#property_number_error').text('Number required!');
  //     return false;
  //   }
  //   if(property_street == ''){
  //     $('#property_street_error').text('Street required!');
  //     return false;
  //   }
  //   // if(property_address_line_2 == ''){
  //   //   $('#property_address_line_2_error').text('Address line required!');
  //   //   return false;
  //   // }
  //   // if(property_city == ''){
  //   //   $('#property_city_error').text('City required!');
  //   //   return false;
  //   // }
  //   // if(property_county == ''){
  //   //   $('#property_county_error').text('County required!');
  //   //   return false;
  //   // }
  //   if(property_postcode == ''){
  //     $('#property_postcode_error').text('Postcode required!');
  //     return false;
  //   }
  //   return true;
  // }
  $('#property_number').on('change keyup',function(){
    if($('#property_number').val() != '' ){
      $('#property_number_error').text('');
    }
  });
  $('#property_street').on('change keyup',function(){
    if($('#property_street').val() != '' ){
      $('#property_street_error').text('');
    }
  });
  // $('#property_address_line_2').on('change keyup',function(){
  //   if($('#property_address_line_2').val() != '' ){
  //     $('#property_address_line_2_error').text('');
  //   }
  // });
  // $('#city').on('change keyup',function(){
  //   if($('#property_city').val() != '' ){
  //     $('#property_city_error').text('');
  //   }
  // });
  // $('#property_county').on('change keyup',function(){
  //   if($('#property_county').val() != '' ){
  //     $('#property_county_error').text('');
  //   }
  // });
  $('#property_postcode').on('change keyup',function(){
    if($('#property_postcode').val() != '' ){
      $('#property_postcode_error').text('');
    }
  });
  $( "#room_landlord_id" ).select2();
  $('#property_landlord_id').select2();
  $('#property_rental_type_1').on('click', function(){
    $('#open-room-modal').trigger('click');
  });
  $('#property_rental_type_0').on('click', function(){
    $('.hidden-room-details').find('input').remove();
  })
  $('#add-room').click(function(){
    var room_no = $('#number').val();
    var list_price = $('#list_price').val();
    var description = $('#description').val();
    var ensuite = $('#ensuite').is(':checked') ? 'Yes' : 'No';
    $('.added-room-details').css('display','block');

    $('.hidden-room-details').append('<input type="hidden" name="number" id="input_room_no"><input type="hidden" name="list_price" id="input_list_price"><input type="hidden" name="description" id="input_description">');

    $('#room-details-room-no').text(room_no);
    $('#input_room_no').val(room_no);

    $('#room-details-list-price').text(list_price);
    $('#input_list_price').val(list_price);

    $('#room-details-description').text(description);
    $('#input_description').val(description);

    $('#room-details-ensuite').text(ensuite);
    $('#input_ensuite').val(ensuite);

    $('.close').trigger('click');
  });

  $(function() {
    $('.img-prv').on('click', function() {

      $('.imagepreview').attr('src', $(this).find('img').attr('src'));
      $('#imagemodal').modal('show');
    });
  });

  $('.student-property-type').css('display', 'none');
  if( $('#property_property_type_student').is(':checked') ){
    $('.student-property-type').css('display', 'block');
  }
  $('#property_property_type_student').on('click', function(){
    if ($(this).is(':checked')){
      $('.student-property-type').css('display', 'block');
    }else{
      $('.student-property-type').css('display', 'none');
    }
  });

  $('.graduate-property-type').css('display', 'none');
  if( $('#property_property_type_graduate').is(':checked') ){
    $('.graduate-property-type').css('display', 'block');
  }
  $('#property_property_type_graduate').on('click', function(){
    if ($(this).is(':checked')){
      $('.graduate-property-type').css('display', 'block');
    }else{
      $('.graduate-property-type').css('display', 'none');
    }
  });

  $('.professional-property-type').css('display', 'none');
  if( $('#property_property_type_professional').is(':checked') ){
    $('.professional-property-type').css('display', 'block');
  }
  $('#property_property_type_professional').on('click', function(){
    if ($(this).is(':checked')){
      $('.professional-property-type').css('display', 'block');
    }else{
      $('.professional-property-type').css('display', 'none');
    }
  });

  $('.family-property-type').css('display', 'none');
  if( $('#property_property_type_family').is(':checked') ){
    $('.family-property-type').css('display', 'block');
  }
  $('#property_property_type_family').on('click', function(){
    if ($(this).is(':checked')){
      $('.family-property-type').css('display', 'block');
    }else{
      $('.family-property-type').css('display', 'none');
    }
  });

  //For tenancy year and start date changes
  Tenancy();

    // $('#tenancy_tenancy_start_3i')
    // $('#tenancy_tenancy_start_2i')
    // $('#tenancy_tenancy_start_1i')
  // })
  $ ('#property-listing-details article:even').addClass('even');
  $ ('#property-listing-details article:odd').addClass('odd');
});

function rate_or_fee() {
  $('input[name="landlord[partnership_format]"]').change(function(){
    get_rate_or_fee();
  });
}

document.addEventListener("turbolinks:load", function() {
  get_rate_or_fee()
});

function get_rate_or_fee(){
  var value = $( 'input[name="landlord[partnership_format]"]:checked' ).val();
  if (value == 'Complete Partner' || value == 'Support Partner' || value == 'Owned') {
    $('.helper').hide();
    $('#fee').hide();
    $('#rate').show();
    if(value == 'Owned'){
      $("#landlord_rate").val('0');
    } else {
      $("#landlord_rate").val($('#rate_value').val());
    }
  } else {
    $('.helper').hide();
    $('#rate').hide();
    $('#fee').show();
  }
}

const Tenancy = function() {

  // Update the tenancy date value base on select year
  // $('#tenancy_year').on('change', function(){
  //   var years = $(this).val().split('/')
  //   var month = $("#tenancy_tenancy_start_2i").val();
  //   if(month < 9){
  //     $("#tenancy_tenancy_start_1i").val('20' + years[1]);
  //   } else {
  //     $("#tenancy_tenancy_start_1i").val('20' + years[0]);
  //   }
  // })

  // Update the tenancy year value base on select tenancy start
  // $('#tenancy_tenancy_start_1i').on('change', function(){
  //   var month = $("#tenancy_tenancy_start_2i").val();
  //   var year = $(this).val().substr(2);
  //
  //   if(month < 9){
  //     $("#tenancy_year").val((parseInt(year) - 1)+'/' + (parseInt(year)))
  //   } else {
  //     $("#tenancy_year").val((parseInt(year))+'/' + (parseInt(year) + 1))
  //   }
  // })
  //
  // $('#tenancy_tenancy_start_2i').on('change', function(){
  //   var year = $("#tenancy_tenancy_start_1i").val().substr(2);
  //   var month = $(this).val();
  //   $("#tenancy_year").children('option').remove();
  //   $("#tenancy_year").append('<option value="'+(parseInt(year))+'/' + (parseInt(year) + 1) +'">'+(parseInt(year))+'/' + (parseInt(year) + 1)+'</option>');
  //   $("#tenancy_year").append('<option value="'+(parseInt(year) - 1)+'/' + (parseInt(year))+'">'+(parseInt(year) - 1)+'/' + (parseInt(year))+'</option>');
  //   if(month < 9){
  //     $("#tenancy_year").val((parseInt(year) - 1)+'/' + (parseInt(year)))
  //   } else {
  //     $("#tenancy_year").val((parseInt(year))+'/' + (parseInt(year) + 1))
  //   }
  // })

  $('#tenancy_number_of_months').on('change keyup', function(){
    var total = ($('#tenancy_monthly_price').val() * $(this).val()).toFixed(2)
    adjust_payment_amt(total, 'monthly')
  })

  $('#tenancy_number_of_weeks').on('change keyup', function(){
    var total = ($('#tenancy_weekly_price').val() * $(this).val()).toFixed(2)
    adjust_payment_amt(total, 'weekly')
  })

  $('#tenancy_monthly_price').on('change keyup', function(){
    var total = ($(this).val() * $('#tenancy_number_of_months').val()).toFixed(2)
    adjust_payment_amt(total, 'monthly')
  })

  $('#tenancy_weekly_price').on('change keyup', function(){
    var total = ($(this).val() * $('#tenancy_number_of_weeks').val()).toFixed(2)
    adjust_payment_amt(total, 'weekly')
  })

  function adjust_payment_amt(amt, term){
    var adv_rent = $('#tenancy_advanced_rent_payment_amount').val();
    var number_payment = $('#tenancy_number_of_payments').val()
    var payment_amount = ((amt - adv_rent) / number_payment).toFixed(2)
    $('#tenancy_total_tenancy_value').val(amt)
    $('#tenancy_payment_amount').val()
    s_day = $('#tenancy_tenancy_start_3i').val();
    s_month = $('#tenancy_tenancy_start_2i').val();
    s_year = $('#tenancy_tenancy_start_1i').val();
    e_date = $('#tenancy_tenancy_end').val(payment_amount);
    var endDate = moment(e_date, "DD-MM-YYYY");
    var startDate = moment(s_day + '-' + s_month + '-' + s_year, "DD-MM-YYYY")
    if(term == 'weekly') {
      var months = endDate.diff(startDate, 'months');
      console.log(months === NaN);
      // if(months != NaN){
        $('#tenancy_number_of_months').val(parseFloat(months) || 0)
        $('#tenancy_monthly_price').val((parseFloat(amt) / parseFloat(months)) || 0);
      // }
    }
    if(term == 'monthly') {
      var weeks = endDate.diff(startDate, 'weeks');
      // if(weeks != NaN){
        $('#tenancy_number_of_weeks').val(parseFloat(weeks) || 0)
        $('#tenancy_weekly_price').val((parseFloat(total) / parseFloat(weeks)).toFixed(2) || 0);
      // }
    }
  }
}

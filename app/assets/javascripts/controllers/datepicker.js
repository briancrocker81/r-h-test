const Datepicker = function() {
  $('.datepicker').datepicker({
    format: 'dd/mm/yyyy'
  });

  $('.daterange').daterangepicker({
    locale: {
      format: 'DD/MM/YYYY'
    }
  });
  $('.daterange').on('apply.daterangepicker', function(ev, picker) {
    if ($(this).data('report') == 'monthly_property') {
      console.log('test');
      var url = $(this).data('url') + "?start_date=" + picker.startDate.format('DD/MM/YYYY')+ "&end_date=" + picker.endDate.format('DD/MM/YYYY')
      window.open(url, '_blank')
    }
    if ($(this).data('report') == 'annual_landlord_stmt') {
      if (confirm('Are you sure to generate the Report')) {
        var url = "/properties/"+$(this).data('id')+"/generate_landlord_annual_statement.json"
        $.get(url, { start_date: picker.startDate.format('DD/MM/YYYY'), end_date: picker.endDate.format('DD/MM/YYYY') }, function(data){
          console.log(data);
          if(data['errors'].length < 1) {
            location.reload();
          } else {
            $('#notice').html("<div class='alert alert-danger alert-dismissible fade show'>" + errors + "<button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button></div>")
            $('#notice').show();
          }
        });
      }
    }

   });
}

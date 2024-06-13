$(document).ready(function(){
  $('#change-password').change(function(){
    if(this.checked)
      $('#new-password').slideDown();
    else
      $('#new-password').slideUp();
  });
  //
  // $('#user_role_agent').click(function() {
  //   $("#colour-picker").toggle(this.checked);
  // });
});
//set initial state.

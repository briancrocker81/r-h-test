$(document).ready(function () {

  $('#sidebarCollapse').on('click', function () {
    $('#sidebar').toggleClass('active');
  });

  /////// Offset scroll to anchor
  // The function actually applying the offset
  function offsetAnchor() {
    if (location.hash.length !== 0) {
      window.scrollTo(window.scrollX, window.scrollY - 150);
    }
  }
  // Captures click events of all a elements with href starting with #
  $(document).on('click', 'a[href^="#"]', function(event) {
    // Click events are captured before hashchanges. Timeout
    // causes offsetAnchor to be called after the page jump.
    window.setTimeout(function() {
      offsetAnchor();
    }, 0);
  });
  // Set the offset when entering page with hash present in the url
  window.setTimeout(offsetAnchor, 0);

});

$(document).on('click','#sidebar-toggle',function() {
  var font_awe = $( this ).find('i');
  if ( font_awe.hasClass( 'fas fa-angle-double-right' ) ) {
    font_awe.removeClass().addClass( 'fas fa-angle-double-left' );
    // $( '#sidebar' ).removeClass().addClass( 'active' );
  } else {
    font_awe.removeClass().addClass( 'fas fa-angle-double-right' );
    $( '#sidebar' ).removeClass().addClass( 'active' );
  }
  $( '#sidebar' ).toggleClass( 'show' );
});
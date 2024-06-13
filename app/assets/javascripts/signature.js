function resizeCanvas(canvas) {
    var ratio =  Math.max(window.devicePixelRatio || 1, 1);
    canvas.width = canvas.offsetWidth * ratio;
    canvas.height = canvas.offsetHeight * ratio;
    canvas.getContext("2d").scale(ratio, ratio);
}

$(document).on('turbolinks:load', function() {
  var canvas = document.querySelector("canvas#one");
  if (canvas){
    canvas.height = canvas.offsetHeight;
    canvas.width = canvas.offsetWidth;
    window.onresize = resizeCanvas(canvas);
    resizeCanvas(canvas);
    signature_pad = new SignaturePad(canvas);
    $('.signature_pad_clear').click(function() { signature_pad.clear() });
    $('.signature_pad_save').click(function(event) { 
      if (signature_pad.isEmpty()) {
        alert('You must sign to accept the Terms and Conditions');
        event.preventDefault();
      } else {
        $('.signature_pad_input').val(signature_pad.toDataURL());
      }
    });
  }

  var canvasTwo = document.querySelector("canvas#two");
  if (canvasTwo){
    canvasTwo.height = canvasTwo.offsetHeight;
    canvasTwo.width = canvasTwo.offsetWidth;
    window.onresize = resizeCanvas(canvas);
    resizeCanvas(canvasTwo);
    signature_pad_two = new SignaturePad(canvasTwo);
    $('#signature-two .signature_pad_clear').click(function() { signature_pad_two.clear() });
    $('.signature_pad_save_two').click(function(event) {
      if (signature_pad_two.isEmpty()) {
        alert('Tenant Two - You must sign to accept the Terms and Conditions');
        event.preventDefault();
      } else {
        $('.signature_pad_two_input').val(signature_pad_two.toDataURL());
      }
    });
  }
});
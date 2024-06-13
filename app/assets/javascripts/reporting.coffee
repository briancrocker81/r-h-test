# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'ready turbolinks:load', ->
  $('#print, #send-arrear, #send-account').on 'click', ->
    item_ids = $('#payment_item_ids').val()
    url = $(this).data('url') + '&ids=' + item_ids + '&order=' + $('#filterrific_sorted_by').val()
    send = $(this).data('send')
    url = if send then url + '&send=' + send else url
    console.log url
    if $(this).data('print')
      window.open(url, "_blank")
    else
       $.get url, ->
        message = "Mail has been sent to the " + send
        console.log message
        $('#notice').html("<div class='alert alert-success alert-dismissible fade show'>" + message + "<button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button></div>")
        $('#notice').show()
        return
    return
  return

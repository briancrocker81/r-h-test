# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'ready turbolinks:load', ->
  $('.confirm_tenancy_signed').on 'click', ->
    checked = $('#guarantor_confirm_signed_tenancy').is(':checked')
    console.log  $('.confirm_signed_tenancy').find('.invalid-feedback').length == 0
    if !checked
      $('#guarantor_confirm_signed_tenancy').addClass 'is-invalid'
      if $('.confirm_signed_tenancy').find('.invalid-feedback').length == 0
        $('.confirm_signed_tenancy').append '<div class="invalid-feedback feedback-show">Please accept the agreement</div>'
    else
      '#guarantor_confirm_signed_tenancy'.removeClass 'is-invalid'
      $('.confirm_signed_tenancy').find('.invalid-feedback').remove()
    checked
  return

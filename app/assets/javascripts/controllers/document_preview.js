const DocumentPreview = function() {
  $('.doc-prv').on('click', function() {
    var url = $(this).attr('data');
    var doc_name = $(this).data('doc-name');
    var doc_verified = $(this).data('verified') ? '<span class="badge badge-success">Yes</span>' : '<span class="badge badge-warning">No</span>';
    var doc_verified_by = $(this).data('verified-by');
    $('.doc-name').replaceWith('<span class="doc-name"> '+doc_name+'</span>');
    if (doc_verified != '' && doc_verified_by != '') {
      $('.doc-verified').replaceWith('<span class="doc-verified">, ( Verified: ' +doc_verified+'</span>');
      $('.doc-verified-by').replaceWith('<span class="doc-verified-by">, Verified By: ' +doc_verified_by+'</span>)');
    }
    $('.doc-preview').replaceWith('<object data="'+url+'" type="application/pdf" width="100%" height="520px" class="doc-preview"></object>');
    $('#doc-modal').modal('show');
  });
}

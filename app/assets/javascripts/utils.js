$(document).ready(function () {

  $(".js-toggle-elements").click(function(){
    show_id = $(this).data('show');
    hide_id = $(this).data('hide');
    $('#'+show_id).show();
    $('#'+hide_id).hide();
  });

});

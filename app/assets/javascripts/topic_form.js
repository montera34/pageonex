$(function () {
  // Delete a topic
  $('.delete_topic').click(function() {
    var index = $(this).attr('id').substr('delete_topic_'.length);
    $("#topic_deleted_" + index).val('1');
    $("#topic_" + index).hide();
  });
});
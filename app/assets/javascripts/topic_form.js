
$(function () {
  
  var initDelete = function () {
    $('.delete_topic').unbind('click');
    $('.delete_topic').click(function () {
      var index = $(this).attr('id').substr('delete_topic_'.length);
      $("#topic_deleted_" + index).val('1');
      $("#topic_" + index).hide();
    });
  }
  
  // lets you add new topics via Ajax request
  $('#add_topic').click(function() { 
    var existingTopicCount = parseInt($("#topic_count").val());
    $.get('/threads/new_topic/'+existingTopicCount, function(data) {   
      $('#topic-list').append(data);
      $("#topic_color_"+$("#topic_count").val()).minicolors({ defaultValue: '#FF0000' });
      $("#topic_count").val(existingTopicCount+1);
      initDelete();
    });
  });
  // add the first topic option dynamically if there are none
  if($("#topic_count").val()==0){
    $("#add_topic").click();
  }
  initDelete();
});

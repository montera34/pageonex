$(function () {
  $(".topic_color").miniColors({
    change: function (hex,rgb) {
      $(".miniColors-trigger").css("background-color",hex)
      }
    });

  $(".miniColors").attr("value","#FF0000")  
  $(".miniColors-trigger").attr("style","margin-bottom:9px;width: 214px;height: 26px;display: block;").css("background-color", $(".miniColors").attr("value"))
  $('.datepicker').datepicker();
  $('.dates').popover()
  $('.status').popover()
  $('#media').popover()
  $(".field_with_errors").attr("class", "field_with_errors control-group error")
  $("#media").val($("#selected_newspapers").attr("value").split(" "));
  validates()
  
  $(".server_validation").change(function () {
    if ($(this).parent().attr("class") == "field_with_errors control-group error" ) {
      $(this).parent().attr("class", "")
      $("#validation_error").attr("value","false")
    }else if($(this).attr("value") == ""){
      $(this).parent().attr("class","field_with_errors control-group error")
      $("#validation_error").attr("value","true")
    }else{
      $("#validation_error").attr("value","false")
    }
  })

  $(".js_validate").change(function () {
    validates()
  })

  // media_count=1
  // media_element = $("#media1");
  // media_label_element = $("#media_label1");
  // $("#add_media").on("click",function () {
  //   cloned_m_e = media_element.clone();
  //   cloned_m_l_e = media_label_element.clone();

  //   cloned_m_l_e.attr("id", "media_label" + ++media_count);
  //   cloned_m_l_e.attr("for", "media" + media_count);
  //   cloned_m_l_e.text("Media"+media_count);

  //   cloned_m_e.attr("id", "media" + media_count);
  //   cloned_m_e.attr("name", "media" + media_count);

  //   $(cloned_m_l_e).insertBefore('#add_media');
  //   $(cloned_m_e).insertBefore('#add_media');
  //   $("<br/>").insertBefore('#add_media');
  //   $("#media_count").attr("value", media_count);
  // });

  topic_count=1
  $("#add_topic").on("click",function () {
    
    var topic_element = $("#topic").clone();
    var topic_name_element = topic_element.find("#topic_name");
    var topic_name_label_element = topic_element.find("#topic_name_label");

    var topic_color_element = topic_element.find("#topic_color");
    var topic_color_label_element = topic_element.find("#topic_color_label");

    var topic_description_element = topic_element.find("#topic_description");
    var topic_description_label_element = topic_element.find("#topic_description_label");

    topic_element.attr("style","display:block");
    topic_element.attr("id","topic"+ ++topic_count);

    topic_name_element.attr("id","topic_name_"+topic_count);
    topic_name_element.attr("name","topic_name_"+topic_count);
    topic_name_label_element.attr("id","topic_name_label_"+topic_count)
    topic_name_label_element.attr("for","topic_name_"+topic_count)
    topic_name_label_element.text("topic_name_"+topic_count)

    topic_color_element.attr("id","topic_color_"+topic_count)
    topic_color_element.attr("name","topic_color_"+topic_count)
    
    random_color = getRandomColor();
    topic_color_element.attr("value","#FEE"+random_color)


    
    topic_color_label_element.attr("id","topic_color_label_"+topic_count)
    topic_color_label_element.attr("for","topic_color_"+topic_count)
    topic_color_label_element.text("topic_color_"+topic_count)

    topic_description_element.attr("id","topic_description_"+topic_count)
    topic_description_element.attr("name","topic_description_"+topic_count)
    topic_description_label_element.attr("id","topic_description_label_"+topic_count)
    topic_description_label_element.attr("for","topic_description_"+topic_count)
    topic_description_label_element.text("topic_description_"+topic_count)

    $(topic_element).insertBefore("#add_topic");
    $("<br/>").insertBefore('#add_topic');
    $("#topic_count").attr("value", topic_count);
  });
  
  

  function getRandomColor () {
    random_color = Math.ceil(Math.random(topic_count)*1000)
    if (random_color >= 100 && random_color != undefined) {
      return random_color;
    } else {
      getRandomColor();
    }
  }

  $("#strat_coding").on("click",function () {
    $('#scraping').modal('show')
    var wait_box = $(".modal-body")
    var opts = {
      lines: 13,       length: 11,       width: 4, 
      radius: 16,       rotate: 0,       color: '#000',       speed: 1.2, 
      trail: 56,       shadow: true,       hwaccel: true,       className: 'spinner', 
      zIndex: 2e9,       top: '297',       left: '-67'     
    };
    var spinner = new Spinner(opts).spin();
    wait_box.append(spinner.el);
  })

  $("#open_thread").click(function () {
    // it's disabled until the feature implemented on the back end
    // $("label[for='threadx_end_date']").hide()
    // $("#threadx_end_date").hide()

  })

  $("#close_thread").click(function () {
    $("label[for='threadx_end_date']").show()
    $("#threadx_end_date").show()
    $("#status").attr("value","closed")
  })

  $("#clear_media").click(function () {
    $("#media").val([]);
    validates()
  })

  $("#strat_coding").click(function (event) {
    event.preventDefault()
    // validates()
    if ($("#validation_error").attr("value") == "false"){
      $("#new_threadx").submit()
    } else {
      $('#scraping').modal('hide')
      window.scroll()
    }
    
  })
 
  function validates () {
    var errors_box = $("#errors")
    var valid=0
    if (true) {
      if (mediaValidator()) {
        $("#errors").find("#media_message").css("display","list-item")
        valid+=1

      }else{
        $("#errors").find("#media_message").css("display","none")
        $("#media_box").attr("class", "")
        valid=0
      }

      if (dateValidator()) {
        $("#errors").find("#date_message").css("display","list-item")
        valid+=1
        
      }else{
        $("#errors").find("#date_message").css("display","none")
        $(".date_errors").attr("class", "date_errors")
        valid=0
      }

      if (topicNameValidator()) {
        $("#errors").find("#topic_name_message").css("display","list-item")
        valid+=1

      }else{
        $("#errors").find("#topic_name_message").css("display","none")
        $("#topic_name_box").attr("class", "")
        valid=0
      }

      if (topicColorValidator()) {
        $("#errors").find("#topic_color_message").css("display","list-item")
        valid+=1
        
      }else{
        $("#errors").find("#topic_color_message").css("display","none")
        $(".topic_color_box").attr("class", "topic_color_box")
        valid=0
      }

      if (valid != 0) {
        $("#validation_error").attr("value","true")
      };
    }

  } 




  function mediaValidator () {
    media_list = $("#media")
    if (media_list.val() == null) {
      $("#media_box").attr("class", "field_with_errors control-group error")
      return true;
    }else{  
      return false;
    }
  }

  function topicNameValidator () {
    if ($(".topic_name").attr("value") == "") {
      $("#topic_name_box").attr("class", "field_with_errors control-group error")
      return true;
    }else{
      return false;
    } 
  }
  
  function topicColorValidator () {
    if ($(".topic_color").attr("value") == "") {
      $(".topic_color_box").attr("class", "field_with_errors control-group error topic_color_box")
      return true;
    }else{
      return false;
    } 
  }


  function dateValidator () {
    var s_d = $("#threadx_start_date").attr("value").split('/')
    var e_d = $("#threadx_end_date").attr("value").split('/')

    var start_date = new Date(s_d[2], parseInt(s_d[1])-1, s_d[0])
    var end_date = new Date(e_d[2], parseInt(e_d[1])-1, e_d[0])
    if (start_date > end_date) {
      $(".date_errors").attr("class", "date_errors field_with_errors control-group error")
      return true;
    }else{
      return false;
    }
  }

});
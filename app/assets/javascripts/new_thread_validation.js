$(function () {
  // initializing the color picker for topic_color_1 textbox 
  $("#topic_color_1").miniColors({
    change: function (hex,rgb) {
      // for any changes in the value of the color, it should update the color of the box beneath the textbox
      $("div#topic_1 .miniColors-trigger").css("background-color",hex)
      }
    });

  // setting the defualt color as #FF0000
  $("div#topic_1 .miniColors").attr("value","#FF0000") 
  // set the color of the box beneath the textbox with current color 
  $("div#topic_1 .miniColors-trigger").attr("style","margin-bottom:9px;width: 214px;height: 26px;display: block;").css("background-color", $("div#topic_1 .miniColors").attr("value"))

  // initializing the datepicker, and the popover object
  $('.datepicker').datepicker();
  $('.dates').popover()
  $('.status').popover()
  $('#media').popover()
  $(".field_with_errors").attr("class", "field_with_errors control-group error")
  // gets the value in the "selected_newspapers" hidden field which is a string of number like this "23 35 114" and convert it to array, and store it in the "media" hidden field
  $("#media").val($("#selected_newspapers").attr("value").split(" "));
  validates()
  
  // for all the classes with "server_validation" class, whenever thier value changes, it will apply the error classes and run the validator to check the new values
  $(".server_validation").change(function () {
    if ($(this).parent().attr("class") == "field_with_errors control-group error" ) {
      $(this).parent().attr("class", "")
      $("#validation_error").attr("value","false")
       validates()
    }else if($(this).attr("value") == ""){
      $(this).parent().attr("class","field_with_errors control-group error")
      $("#validation_error").attr("value","true")

    }else{
      $("#validation_error").attr("value","false")
    }
  })

  // the same as the "server_validation" class
  $(".js_validate").change(function () {
    validates()
  })


  // adding a new topic
  topic_count = parseInt($("#topic_count").attr("value"))
  $("#add_topic").on("click",function () {
    
    // cloning the "topic" div, and modify the cloned version, and then append it to the page
    var topic_element = $("#topic").clone();
    var topic_name_element = topic_element.find("#topic_name");
    var topic_name_label_element = topic_element.find("#topic_name_label");

    var topic_color_element = topic_element.find("#topic_color");
    var topic_color_label_element = topic_element.find("#topic_color_label");

    var topic_description_element = topic_element.find("#topic_description");
    var topic_description_label_element = topic_element.find("#topic_description_label");

    topic_element.attr("style","display:block");
    topic_element.attr("id","topic_"+ ++topic_count);

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

    // insert the new topic before the button for creating topics
    $(topic_element).insertBefore("#add_topic");

    // initializing the color picker for topic_color_topic_count textbox 
    $("#topic_color_"+topic_count).miniColors({
      change: function (hex,rgb) {
        $("div#topic_"+topic_count+" .miniColors-trigger").css("background-color",hex)
      }
    });

    $("div#topic_"+topic_count+" .miniColors").attr("value","#FF0000")  
    $("div#topic_"+topic_count+" .miniColors-trigger").attr("style","margin-bottom:9px;width: 214px;height: 26px;display: block;").css("background-color", $("div#topic_"+topic_count+" .miniColors").attr("value"))


    $("<br/>").insertBefore('#add_topic');
    $("#topic_count").attr("value", topic_count);
  });
  
  
  // generate random number for creating random colors
  function getRandomColor () {
    random_color = Math.ceil(Math.random(topic_count)*1000)
    if (random_color >= 100 && random_color != undefined) {
      return random_color;
    } else {
      getRandomColor();
    }
  }

  // when the "strat_coding" button clicked, the message box will appears, untill the scraping finishes
  // to add any calculation or progress bar it will be added here
  $("#strat_coding").on("click",function () {
    // trigger the modal box
    $('#scraping').modal('show')
    var wait_box = $(".modal-body")
    // options for the spinner
    var opts = {
      lines: 13,       length: 11,       width: 4, 
      radius: 16,       rotate: 0,       color: '#000',       speed: 1.2, 
      trail: 56,       shadow: true,       hwaccel: true,       className: 'spinner', 
      zIndex: 2e9,       top: '297',       left: '-67'     
    };
    var spinner = new Spinner(opts).spin();
    wait_box.append(spinner.el);
  })

  // if the used chooses the open option, it will hide the end date box and will set the value for status with opened
  $("#open_thread").click(function () {
    $("label[for='threadx_end_date']").hide()
    $("#threadx_end_date").hide()
    $("#status").attr("value","opened")

  })

  // if the used chooses the close option, it will show the end date box and will set the value for status with closed
  $("#close_thread").click(function () {
    $("label[for='threadx_end_date']").show()
    $("#threadx_end_date").show()
    $("#status").attr("value","closed")
  })

  // clear all the selected media choices
  $("#clear_media").click(function () {
    $("#media").val([]);
    validates()
  })

  // this event should be combined with the above on line 117, and what is this method do is, preventing the "start_coding" button from submitting the form and check if there was any validation error first, if so it will scroll the user up to the error messages, if not it will submit the form
  $("#strat_coding").click(function (event) {
    event.preventDefault()
    if ($("#validation_error").attr("value") == "false"){
      $("#new_threadx").submit()
    } else {
      $('#scraping').modal('hide')
      window.scroll()
    }
    
  })
 
  // the main validations method
  function validates () {
    var errors_box = $("#errors")
    var m_valid=true,d_valid=true,t_n_valid=true
    var empty_topic = $("#empty_topic")
    var empty_media = $("#empty_media")
    
    // check if there was an error with media or the topic, if so it will display the error message
    if (errors_box.children().length >= 1 || empty_topic.attr('value') == 'true' || empty_media.attr('value') == 'true') {
     
      if (errors_box.children().length == 0) {
        $("#errors").append('<div class="alert alert-error"></div>')
        
        if (empty_topic.attr('value') == 'true' ) {
          $('.alert-error').append('<li id="topic_name_message" style="display:none">Topic name cannot be empty</li>')
        };
        if (empty_media.attr('value') == 'true') {
          $('.alert-error').append('<li id="media_message" style="display:none">You must at least select one newspaper</li>')
        };
      };
      
      // runs the media validatior, and if there was an error it display the error message
      if (mediaValidator()) {
        $("#errors").find("#media_message").css("display","list-item")
        m_valid=false

      }else{
        $("#errors").find("#media_message").css("display","none")
        $("#media_box").attr("class", "")
      }

      // runs the date validatior, and if there was an error it display the error message
      if (dateValidator()) {
        $("#errors").find("#date_message").css("display","list-item")
        d_valid=false
        
      }else{
        $("#errors").find("#date_message").css("display","none")
        $(".date_errors").attr("class", "date_errors")
      }

      // runs the topic validatior, and if there was an error it display the error message
      if (topicNameValidator()) {
        $("#errors").find("#topic_name_message").css("display","list-item")
        t_n_valid=false

      }else{
        $("#errors").find("#topic_name_message").css("display","none")
        $("#topic_name_box").attr("class", "")
      }

      // check for the result of the above validatior, and if there was an error in any of them it will set the "validation_error" hiddin field with true
      if (m_valid && d_valid && t_n_valid) {
        $("#validation_error").attr("value","false")
      }else{
        $("#validation_error").attr("value","true")
      }

    }

  } 

  // check if there was a newspaper selected
  function mediaValidator () {
    media_list = $("#media")
    if (media_list.val() == null) {
      $("#media_box").attr("class", "field_with_errors control-group error")
      return true;
    }else{  
      return false;
    }
  }

  // check if the topic name is not empty
  function topicNameValidator () {
    if ($(".topic_name").attr("value") == "") {
      $("#topic_name_box").attr("class", "field_with_errors control-group error")
      return true;
    }else{
      return false;
    } 
  }

  // check that the end date is not comes before the start date
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
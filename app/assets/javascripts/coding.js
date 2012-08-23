$(document).ready(function () {
    // initializing the image slider "carousel" plugin
    carousel = $('.carousel').carousel();
    
    // checks if the this user is owner, if so, it will initialize the imgAreaSelect plugin which is used for highlighting
    if ($("#allow_coding").attr("value") == "true") {
        
        // get the object of image selection plugin
        var currrent_img = $("#images_section div.active img")

        // initializing imgAreaSelect plugin for the current active (displayed image)
        var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});

        // get the highlighted area related set of the hidden fields which stores the values of the highlighted areas
        var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")
    
        // initializing jQuery UI draggable plugin to give the user the ability to change the highlighted areas position
        $(".high_area").draggable({
            // attach the is callback for the stop event, so if the user drag the highlighted area to a differnt position, it will set the new values to image related hidden fields
            stop: function (event, ui) {
                var carousel_position = $('.carousel').position()
                var y1 =  ui.position.top - carousel_position.top
                var x1 = ui.position.left - carousel_position.left
                var ha = "_ha" + $(this).attr("id").substr(9);
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_y1").attr("value",y1);
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_x1").attr("value",x1);
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_status").attr("value","1");
                // and then set the status with "1", so the user should save before leaving the page
                $("#status").attr("value","1")
            },
        // initializing jQuery UI resizable plugin to give the user the ability to change the highlighted areas size
        }).resizable({
            containment:'#myCarousel',
            handles: "se, ne",
            aspectRatio: false,
            // attach the is callback for the resize event, so if the user change the size of the highlighted area to a differnt size, it will set the new values to image related hidden fields
            resize: function(e, ui) {
                var ha = "_ha" + $(this).attr("id").substr(9);
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_width").attr("value",ui.size.width);
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_height").attr("value",ui.size.height);
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_status").attr("value","1");
                $("#status").attr("value","1")
                $(this).css("width",ui.size.width)
                $(this).css("height",ui.size.height)
            },

        })

    };

    // setting the value for each image
    $("#publication_date").text($("#images_section div.active img").attr("pub_date"));
    $("#newspaper_name").text($("#images_section div.active img").attr("media"));
    // $("#source_of_image").attr("href",$("#images_section div.active img").attr('src'))
    $("#source_of_image").attr("value",$("#images_section div.active img").attr('src')).tooltip({placement:'bottom'})
    
    // attaching a callback for the slide event on the carousel, so it will clear all the highlighted areas when the user slide
    // "This event fires immediately when the slide instance method is invoked." from bootstrap documentation
    carousel.on('slide',function () {
        // reset the highlighted areas values
        clearHighlightedArea();
    });

    // "This event is fired when the carousel has completed its slide transition." from bootstrap documentation
    carousel.on('slid',function(){
        // set the current image to the current active(displayed) image in the carousel
        var currrent_img = $("#images_section div.active img")

        // after we slide for the next image, we normally initialize the imgAreaSelect for the new image, but befor that, we also check if the user have a premonition
        if ($("#allow_coding").attr("value") == "true") {

            // is the image was not found, it will not initialize the imgAreaSelect, and this not working in the heroku deployed version
            if (currrent_img.attr("altr") == "Assets404") {
                currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea, disable:true});
            }else{
                currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});
            }

            var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")
    
            $(".high_area").draggable( {
                stop: function (event, ui) {
         
                    carousel_position = $('.carousel').position()

                    y1 =  ui.position.top - carousel_position.top

                    x1 = ui.position.left - carousel_position.left

                    ha = "_ha" + $(this).attr("id").substr(9);
                    image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_y1").attr("value",y1);
                    image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_x1").attr("value",x1);
                    image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_status").attr("value","1");
                    $("#status").attr("value","1")
                },
            })
            .resizable({
                containment:'#myCarousel',
                handles: "se, ne",
                aspectRatio: false,
                resize: function(e, ui) {
                    var ha = "_ha" + $(this).attr("id").substr(9);
                    image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_width").attr("value",ui.size.width);
                    image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_height").attr("value",ui.size.height);
                    image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_status").attr("value","1");
                    $("#status").attr("value","1")
                    $(this).css("width",ui.size.width)
                    $(this).css("height",ui.size.height)
                }

            })
        }

        currrent_img = $("#images_section div.active img");
        
        $("#high_area1").css("background-color","#000")
        $("#high_area2").css("background-color","#000")

        // if there was no highlighted areas loaded, it will call the loadHighlightingAreas method
        if ( $("#high_area1").css("top") == "0px") {
            loadHighlightingAreas();
        };

        $("#publication_date").text(currrent_img.attr("pub_date"));
        $("#newspaper_name").text(currrent_img.attr("media"));
        // $("#source_of_image").attr("href",$("#images_section div.active img").attr('src'));
        $("#source_of_image").attr("value",$("#images_section div.active img").attr('src')).tooltip({placement:'bottom'})
        $("#image_number").text(currrent_img.attr("id").substr(5,100))
    });

    // if the user have zoomed out or zoomed in, it will reload the images again
    $(window).resize(function() {
        clearHighlightedArea();
        if ( $("#high_area1").css("top") == "0px") {
            loadHighlightingAreas();
        };
    });

    // when the user choose a code from the drop down menu, and click this button it will set the code of this highlighted area by this code
    $("#set_code").on("click",function () {
        var currrent_img = $("#images_section div.active img")

        var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")

        var code_id = $("#codes").attr("value") 
        var c_ha = $("#current_high_area").attr("value")

        if (c_ha == "high_area1"){
            //high_area_1
            $($(image_hidden_fields[0]).children()[1]).attr("value",code_id);
            $("#"+c_ha).css("background-color", $("#code_"+code_id).css("background-color"))
        }else{
            //high_area_2
            $($(image_hidden_fields[1]).children()[1]).attr("value",code_id);
            $("#"+c_ha).css("background-color", $("#code_"+code_id).css("background-color"))
        }
        
    })

    // it will set the highlighted areas to zero 
    $("#clear_highlighting").click(function () {
        var currrent_img = $("#images_section div.active img")

        var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")

        $($(image_hidden_fields[0]).children()[0]).attr("value","0");
        $($(image_hidden_fields[0]).children()[0]).attr("value","0");

        var ha1 = $(image_hidden_fields[0]).attr("id")
        var ha2 = $(image_hidden_fields[1]).attr("id")
        setHighlightingAreaValues(ha1,'0','0','0','0','0','0');
        setHighlightingAreaValues(ha2,'0','0','0','0','0','0');
        clearHighlightedArea()
        progressBarPercentage()
    })  

    // this used to for "nothing to code here"
    $("#skip_coding").click(function () {
        var currrent_img = $("#images_section div.active img")
        var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")

        // this condition to prevent from duplicate the work if it was already done
        if ($(image_hidden_fields[0]).children()[1].value != "-1") {
            
            clearHighlightedArea()
            
            $(image_hidden_fields[0]).children()[0].value = "1"
            
            setHighlightingAreaValues($(image_hidden_fields[0]).attr("id"), 1, 1, '0', '0', currrent_img.width(), currrent_img.height());
            
            $(image_hidden_fields[0]).children()[1].value = "-1"
            
            $("#high_area1").css("top", $("#myCarousel").position().top);

            $("#high_area1").css("left", $("#myCarousel").position().left);

            $("#high_area1").css("width",currrent_img.width());

            $("#high_area1").css("height",currrent_img.height()); 

            $("#high_area1").css("opacity","0.9");

            $("#high_area1").css("background-color","#eee");

        };
        progressBarPercentage()
    })
    
    // call the loadHighlightingAreas after loading all the images
    window.onload = function() {
        if ( $("#high_area1").css("top") == "0px") {
            loadHighlightingAreas();
        };
    }

    // this part used for the heroku deployment, which is replacing the url of an image to the 404.jpg image if the image doesn't exist
    $("#myCarousel img").error(function (e) {
        $(this).attr("src","/assets/404.jpg")
    })

    progressBarPercentage()

    // initializing the popover message of the code
    $(".codes_boxes").popover()

});

// the imgAreaSelect callback for the event onSelectEnd, which handles setting the values for the highlighted areas divs
function highlightingArea (img, selection) {
    var currrent_img = $("#images_section div.active img")
    img_pos = $("#myCarousel").position();
    
    var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")

    var ha1 = $(image_hidden_fields[0]).attr("id")
    var ha2 = $(image_hidden_fields[1]).attr("id")

    // checks if the first highlighted areas is used or not
    if ( $($("#"+ha1).children()[0]).attr("value") == 0){

        // call setHighlightingAreaValues and pass the values returned by the imgAreaSelect, to set the hidden fields
        setHighlightingAreaValues(ha1, selection.x1,selection.y1,selection.x2,selection.y2,selection.width,selection.height);

        _top = img_pos.top + parseInt(image_hidden_fields.find("#"+ha1+"_y1").attr("value"));

        _left= img_pos.left + parseInt(image_hidden_fields.find("#"+ha1+"_x1").attr("value"));

        $("#high_area1").css("top",_top);

        $("#high_area1").css("left",_left);

        $("#high_area1").css("height",image_hidden_fields.find("#"+ha1+"_height").attr("value"));

        $("#high_area1").css("width",image_hidden_fields.find("#"+ha1+"_width").attr("value")); 

        // display the coding box, to ask the user to choose a code
        $('#coding_topics').modal({backdrop:false});

        $("#current_high_area").attr("value","high_area1")

        $("#"+ha1).children()[0].value ="1"
        progressBarPercentage()

    // check for the second highlighted area
    } else if ( $($("#"+ha2).children()[1]).attr("value") == 0){
        setHighlightingAreaValues(ha2, selection.x1,selection.y1,selection.x2,selection.y2,selection.width,selection.height);

        _top = img_pos.top + parseInt(image_hidden_fields.find("#"+ha2+"_y1").attr("value"));

        _left= img_pos.left + parseInt(image_hidden_fields.find("#"+ha2+"_x1").attr("value"));

        $("#high_area2").css("top",_top);

        $("#high_area2").css("left",_left);

        $("#high_area2").css("height",image_hidden_fields.find("#"+ha2+"_height").attr("value"));

        $("#high_area2").css("width",image_hidden_fields.find("#"+ha2+"_width").attr("value"));
        
        $('#coding_topics').modal({backdrop:false});

        $("#current_high_area").attr("value","high_area2")

        $("#"+ha2).children()[0].value ="1"
        progressBarPercentage()
    // if both the highlighted areas are used, so it ask the user if he/she want to clear the current highlighted areas
    } else {
        if (currrent_img.attr("altr") == "Assets404") {
            var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea, disable:true});
        }else{
            var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});
        }
        if(confirm("Do you want to clear current highlighted areas?")){
                $($("#"+ha1).children()[0]).attr("value","0")
                $($("#"+ha2).children()[1]).attr("value","0")
                setHighlightingAreaValues(ha1,'0','0','0','0','0','0');
                setHighlightingAreaValues(ha2,'0','0','0','0','0','0');
                clearHighlightedArea()
                currrent_img_area_select.cancelSelection()
        }else{
                currrent_img_area_select.cancelSelection()
        }
        
    }

    highlighting_done();
}

// set the values to image related hidden fields
function setHighlightingAreaValues (ha, x1, y1, x2, y2, width, height) {
    var currrent_img = $("#images_section div.active img")
    var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")

    image_hidden_fields.find("#"+ha+"_code_id").attr("value",0);
    image_hidden_fields.find("#"+ha+"_x1").attr("value",x1);
    image_hidden_fields.find("#"+ha+"_y1").attr("value",y1);
    image_hidden_fields.find("#"+ha+"_x2").attr("value",x2);
    image_hidden_fields.find("#"+ha+"_y2").attr("value",y2);
    image_hidden_fields.find("#"+ha+"_width").attr("value",width);
    image_hidden_fields.find("#"+ha+"_height").attr("value",height);
    image_hidden_fields.find("#"+ha+"_status").attr("value","1");
    $("#status").attr("value","1")
}

// cancel the selection when the user done
function highlighting_done() {
    var currrent_img = $("#images_section div.active img")
    if (currrent_img.attr("altr") == "Assets404") {
            var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea, disable:true});
        }else{
            var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});
    }
    currrent_img_area_select.cancelSelection()
};

// this method will load the values from the hidden field to the highlighted areas divs
function loadHighlightingAreas () {
    var currrent_img = $("#images_section div.active img")
    // get the position of the image in the page
    img_pos = $("#myCarousel").position();
    
    // get the div which contains the hidden field that holds the highlighted area values
    var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")
    var ha1 = $(image_hidden_fields[0]).attr("id")
    var ha2 = $(image_hidden_fields[1]).attr("id")


    _top = img_pos.top + parseInt(image_hidden_fields.find("#"+ha1+"_y1").attr("value"));

    _left= img_pos.left + parseInt(image_hidden_fields.find("#"+ha1+"_x1").attr("value"));

    $("#high_area1").css("top",_top);

    $("#high_area1").css("left",_left);

    $("#high_area1").css("height",image_hidden_fields.find("#"+ha1+"_height").attr("value"));

    $("#high_area1").css("width",image_hidden_fields.find("#"+ha1+"_width").attr("value")); 

    var code_id = image_hidden_fields.find("#"+ha1+"_code_id").attr("value")
    $("#high_area1").css("background-color", $("#code_"+code_id).css("background-color"))

    // this condition is used to distingesh the "nothing to code here" area
    if (image_hidden_fields.find("#"+ha1+"_code_id").attr("value") == "-1")  {
        $("#high_area1").css("background-color", "#eee")
        $("#high_area1").css("opacity", " 0.8")
        if ($("#high_area1").children().length == 0) {
            $("#high_area1").append("<h1 style='text-align:center; color: black;'>None</h1>");
        }
        $("#high_area1").css("top",image_hidden_fields.find("#"+ha1+"_y1").attr("value"));

        $("#high_area1").css("left",image_hidden_fields.find("#"+ha1+"_x1").attr("value"));
    }else{

        $("#high_area1").css("opacity", " 0.4")
    }


    _top = img_pos.top + parseInt(image_hidden_fields.find("#"+ha2+"_y1").attr("value"));

    _left= img_pos.left + parseInt(image_hidden_fields.find("#"+ha2+"_x1").attr("value"));

    $("#high_area2").css("top",_top);

    $("#high_area2").css("left",_left);

    $("#high_area2").css("height",image_hidden_fields.find("#"+ha2+"_height").attr("value"));

    $("#high_area2").css("width",image_hidden_fields.find("#"+ha2+"_width").attr("value")); 

    var code_id = image_hidden_fields.find("#"+ha2+"_code_id").attr("value")
    $("#high_area2").css("background-color", $("#code_"+code_id).css("background-color"))
}

// set the values of the highlighted areas to zero
function clearHighlightedArea () {
    $("#high_area1").css("top","0px");
    $("#high_area1").css("width","0px");
    
    $("#high_area2").css("top","0px");
    $("#high_area2").css("width","0px");

    progressBarPercentage()
    $("#status").attr("value","1")
}

// calculate the percentage of progress bar 
function progressBarPercentage () {
    // set the total number of images
    $("#total").text($("#total_images_number").attr("value"))
    var images_counter = parseInt($("#total").text())
    var remain_counter = 0
    // get all the highlighted areas
    var high_areas = $("#high_images").children()
    // iterates over all the highligted areas 
    for (var i = 0; i < high_areas.length; i++) {
        ha=$("input#"+high_areas[i].id).attr("value")
        // if the highlighted area is set to "1" and it was the first highlighted area, we increment the counter
        if (ha != "1" && high_areas[i].id.split('_')[1] == "ha1") {
            remain_counter += 1
        };
    };
    // calculate percentage of the bar
    var percentage = 100 - ((remain_counter/images_counter) * 100)
    
    // set the value in percentage form "%"
    $(".bar").css("width",Math.ceil(percentage)+"%")
    $("#remain").text(images_counter-remain_counter)
}
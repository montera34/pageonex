$(document).ready(function () {
    carousel = $('.carousel').carousel({
        interval: 500000000
    });
    
    if ($("#allow_coding").attr("value") == "true") {
        // get the object of image selection plugin
        var currrent_img = $("#images_section div.active img")
        var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});
        // var currrent_img = $("#images_section div.active img")
        var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")
    
        $(".high_area").draggable({
            stop: function (event, ui) {
     
                var carousel_position = $('.carousel').position()

                var y1 =  ui.position.top - carousel_position.top

                var x1 = ui.position.left - carousel_position.left

                var ha = "_ha" + $(this).attr("id").substr(9);
                console.log(image_hidden_fields.attr("id").split('_')[0]+ha)
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_y1").attr("value",y1);
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_x1").attr("value",x1);
            },
        }).resizable({
            containment:'#myCarousel',
            handles: "se, ne",
            aspectRatio: false,
            resize: function(e, ui) {
                var ha = "_ha" + $(this).attr("id").substr(9);
                console.log(image_hidden_fields.attr("id").split('_')[0]+ha)
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_width").attr("value",ui.size.width);
                image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_height").attr("value",ui.size.height);
                $(this).css("width",ui.size.width)
                $(this).css("height",ui.size.height)
            },

        })

    };

    // current display image 
    // currrent_img = $("#images_section div.active img") 
    //if (currrent_img.attr("alt")){
    $("#publication_date").text($("#images_section div.active img").attr("pub_date"));
    $("#newspaper_name").text($("#images_section div.active img").attr("media"));
    //};
    
    carousel.on('slide',function () {
        // reset the highlighted areas values
        clearHighlightedArea();
    });

    $("#image_number").text($("#images_section div.active img").attr("id").substr(5,100))

    // change the currrent_img_area_select, currrent_img variable when user slide to another image, and also clean the highlighted areas
    carousel.on('slid',function(){
        var currrent_img = $("#images_section div.active img")
        if ($("#allow_coding").attr("value") == "true") {
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
                    console.log(image_hidden_fields.attr("id").split('_')[0]+ha)
                    image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_y1").attr("value",y1);
                    image_hidden_fields.find("#"+image_hidden_fields.attr("id").split('_')[0]+ha+"_x1").attr("value",x1);
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
                    $(this).css("width",ui.size.width)
                    $(this).css("height",ui.size.height)
                }

            })
        }

        currrent_img = $("#images_section div.active img");

        if ( $("#high_area1").css("top") == "0px") {
            loadHighlightingAreas();
        };

        $("#publication_date").text(currrent_img.attr("pub_date"));
        $("#newspaper_name").text(currrent_img.attr("media"));
        $("#image_number").text(currrent_img.attr("id").substr(5,100))
    });

    $(window).resize(function() {
        clearHighlightedArea();
        if ( $("#high_area1").css("top") == "0px") {
            loadHighlightingAreas();
        };
    });


    $('input[name="codes"]').on("click",function(){
        var currrent_img = $("#images_section div.active img")

        var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")
        
        ha = $("#current_high_area").attr("value")

        image_hidden_fields.find("#"+image_hidden_fields.attr("id")+"_ha"+ha.substring(9)+"_code_id").attr("value",$(this).attr("code_id"))
        
        $("#"+ha).css("background-color",$(this).attr("color"));    
    });

    $("#clear_highlighting").click(function () {
        var currrent_img = $("#images_section div.active img")

        var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")
        $("#"+image_hidden_fields.attr("id") +"_ha1").attr("value","0");

        $("#"+image_hidden_fields.attr("id") +"_ha2").attr("value","0");
        setHighlightingAreaValues("_ha1",'0','0','0','0','0','0');
        setHighlightingAreaValues("_ha2",'0','0','0','0','0','0');
        clearHighlightedArea()
        progressBarPercentage()
    })  

    $("#skip_coding").click(function () {
        var currrent_img = $("#images_section div.active img")
        var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")
        if ($("#"+image_hidden_fields.attr("id") +"_ha1_code_id").attr("value") != "-1") {
            clearHighlightedArea()
            
            $("#"+image_hidden_fields.attr("id") +"_ha1").attr("value","1");
            
            setHighlightingAreaValues("_ha1", 1, 1, '0', '0', currrent_img.width(), currrent_img.height());
            
            $("#"+image_hidden_fields.attr("id") +"_ha1_code_id").attr("value","-1");
            
            $("#high_area1").css("top", $("#myCarousel").position().top);

            $("#high_area1").css("left", $("#myCarousel").position().left);

            $("#high_area1").css("width",currrent_img.width());

            $("#high_area1").css("height",currrent_img.height()); 

            $("#high_area1").css("opacity","0.9");

            $("#high_area1").css("background-color","#eee");

            // if ($("#high_area1").children().length == 2) {
            //     $("#high_area1").append("<h1 style='text-align:center color: black;'>None</h1>");
            // }
        };
        progressBarPercentage()
    })

    window.onload = function() {
        if ( $("#high_area1").css("top") == "0px") {
            loadHighlightingAreas();
        };
    }

    $("#myCarousel img").error(function (e) {
        $(this).attr("src","/assets/404.jpg")
    })

    progressBarPercentage()


});
function highlightingArea (img, selection) {
    var currrent_img = $("#images_section div.active img")
    img_pos = $("#myCarousel").position();
    
    // var image_hidden_fields = $("div#" + currrent_img.attr("id"));
    var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")

    var ha1 = $(image_hidden_fields[0]).attr("id")
    var ha2 = $(image_hidden_fields[1]).attr("id")

    if ( $($("#"+ha1).children()[0]).attr("value") == 0){

        setHighlightingAreaValues(ha1, selection.x1,selection.y1,selection.x2,selection.y2,selection.width,selection.height);

        _top = img_pos.top + parseInt(image_hidden_fields.find("#"+ha1+"_y1").attr("value"));

        _left= img_pos.left + parseInt(image_hidden_fields.find("#"+ha1+"_x1").attr("value"));

        $("#high_area1").css("top",_top);

        $("#high_area1").css("left",_left);

        $("#high_area1").css("height",image_hidden_fields.find("#"+ha1+"_height").attr("value"));

        $("#high_area1").css("width",image_hidden_fields.find("#"+ha1+"_width").attr("value")); 

        // $('#coding_topics').modal({backdrop:false});
        $("#high_area1").css("background-color",$('.code').css("background-color"))

        $("#current_high_area").attr("value","high_area1")

        // var ha = $("#current_high_area").attr("value")

        image_hidden_fields.find("#"+ha1+"_code_id").attr("value",$('.code').attr("id").substr(4,100))

        $("#"+ha1).children()[0].value ="1"
        progressBarPercentage()

    } else if ( $($("#"+ha2).children()[1]).attr("value") == 0){
        setHighlightingAreaValues(ha2, selection.x1,selection.y1,selection.x2,selection.y2,selection.width,selection.height);

        _top = img_pos.top + parseInt(image_hidden_fields.find("#"+ha2+"_y1").attr("value"));

        _left= img_pos.left + parseInt(image_hidden_fields.find("#"+ha2+"_x1").attr("value"));

        $("#high_area2").css("top",_top);

        $("#high_area2").css("left",_left);

        $("#high_area2").css("height",image_hidden_fields.find("#"+ha2+"_height").attr("value"));

        $("#high_area2").css("width",image_hidden_fields.find("#"+ha2+"_width").attr("value"));
        
        // $('#coding_topics').modal({backdrop:false});
        $("#high_area2").css("background-color",$('.code').css("background-color"))

        $("#current_high_area").attr("value","high_area2")
        
        ha = $("#current_high_area").attr("value")

        image_hidden_fields.find("#"+ha2+"_code_id").attr("value",$('.code').attr("id").substr(4,100))

        $("#"+ha2).children()[0].value ="1"
        progressBarPercentage()

    } else {
        if (currrent_img.attr("altr") == "Assets404") {
            var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea, disable:true});
        }else{
            var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});
        }
        if(confirm("Do you want to clear current highlighted areas?")){
                $("#"+image_hidden_fields.attr("id") +"_ha1").attr("value","0");
                $("#"+image_hidden_fields.attr("id") +"_ha2").attr("value","0");
                setHighlightingAreaValues("_ha1",'0','0','0','0','0','0');
                setHighlightingAreaValues("_ha2",'0','0','0','0','0','0');
                clearHighlightedArea()
                currrent_img_area_select.cancelSelection()
            }else{
                currrent_img_area_select.cancelSelection()
            }
    }

	img.hide = true
    highlighting_done();

}

function setHighlightingAreaValues (ha, x1, y1, x2, y2, width, height) {
    var currrent_img = $("#images_section div.active img")
    // var image_hidden_fields = $("div#" + currrent_img.attr("id"));
    var image_hidden_fields = $("div[image_name="+ currrent_img.attr("name") +"]")

    image_hidden_fields.find("#"+ha+"_code_id").attr("value",0);
    image_hidden_fields.find("#"+ha+"_x1").attr("value",x1);
    image_hidden_fields.find("#"+ha+"_y1").attr("value",y1);
    image_hidden_fields.find("#"+ha+"_x2").attr("value",x2);
    image_hidden_fields.find("#"+ha+"_y2").attr("value",y2);
    image_hidden_fields.find("#"+ha+"_width").attr("value",width);
    image_hidden_fields.find("#"+ha+"_height").attr("value",height);
    
}

function highlighting_done() {
    var currrent_img = $("#images_section div.active img")
    if (currrent_img.attr("altr") == "Assets404") {
            var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea, disable:true});
        }else{
            var currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});
    }
    currrent_img_area_select.cancelSelection()
};

function loadHighlightingAreas () {
    var currrent_img = $("#images_section div.active img")
    // get the position of the image in the page
    img_pos = $("#myCarousel").position();
    
    // get the div which contains the hidden field that holds the highlighted area values
    // var image_hidden_fields = $("div#" + currrent_img.attr("id"));
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
    $("#high_area1").css("background-color", $("div#code"+code_id).css("background-color"))  

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
        // $("#high_area1").children().first().remove()
    }


    _top = img_pos.top + parseInt(image_hidden_fields.find("#"+ha2+"_y1").attr("value"));

    _left= img_pos.left + parseInt(image_hidden_fields.find("#"+ha2+"_x1").attr("value"));

    $("#high_area2").css("top",_top);

    $("#high_area2").css("left",_left);

    $("#high_area2").css("height",image_hidden_fields.find("#"+ha2+"_height").attr("value"));

    $("#high_area2").css("width",image_hidden_fields.find("#"+ha2+"_width").attr("value")); 

    code_id = image_hidden_fields.find("#"+ha2+"_code_id").attr("value")
    $("#high_area2").css("background-color", $("div#code"+code_id).css("background-color"))  
    
}



function clearHighlightedArea () {
    $("#high_area1").css("top","0px");
    $("#high_area1").css("width","0px");
    
    $("#high_area2").css("top","0px");
    $("#high_area2").css("width","0px");
}

function progressBarPercentage () {
    $("#total").text($("#total_images_number").attr("value"))
    var images_counter = parseInt($("#total").text())
    var remain_counter = 0
    for (var i = 1; i <= images_counter; i++) {
        // ha1 = $("div#image"+i).first().children()[0].value
        ha1 = $("#image"+i+"_ha1").attr("value")
        // ha2 = $("div#image"+i).last().children()[0].value 
        if (ha1 != "1" ) {
            remain_counter += 1
        };
    };
    var percentage = 100 - ((remain_counter/images_counter) * 100)
    
    $(".bar").css("width",Math.ceil(percentage)+"%")
    $("#remain").text(images_counter-remain_counter)
}
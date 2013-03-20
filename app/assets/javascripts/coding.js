$(document).ready(function () {
    // initializing the image slider "carousel" plugin
    carousel = $('.carousel').carousel();
    
    // checks if the this user is owner, if so, it will initialize the imgAreaSelect plugin which is used for highlighting
    if ($("#allow_coding").attr("value") == "true") {
        // initializing imgAreaSelect plugin for the current active (displayed image)
        $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});
    };
    renderHighlightedAreas();

    // setting the value for each image
    $("#publication_date").text($("#images_section div.active img").attr("pub_date"));
    $("#newspaper_name").text($("#images_section div.active img").attr("media")).attr("href",$("#images_section div.active img").attr('url'));
    // $("#source_of_image").attr("href",$("#images_section div.active img").attr('src'))
    $("#source_of_image").attr("value",$("#images_section div.active img").attr('src')).tooltip({placement:'bottom'})
    
    // attaching a callback for the slide event on the carousel, so it will clear all the highlighted areas when the user slide
    // "This event fires immediately when the slide instance method is invoked." from bootstrap documentation
    carousel.on('slide',function () {
        // reset the highlighted areas values
        clearHighlightedAreas();
    });

    // "This event is fired when the carousel has completed its slide transition." from bootstrap documentation
    carousel.on('slid',function(){
        // set the current image to the current active(displayed) image in the carousel
        var currrent_img = $("#images_section div.active img")
        
        renderHighlightedAreas();

        // after we slide for the next image, we normally initialize the imgAreaSelect for the new image, but befor that, we also check if the user have a premonition
        if ($("#allow_coding").attr("value") == "true") {

            // is the image was not found, it will not initialize the imgAreaSelect, and this not working in the heroku deployed version
            if (currrent_img.attr("altr") == "Assets404") {
                currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea, disable:true});
            }else{
                currrent_img_area_select = $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});
            }
        }

        currrent_img = $("#images_section div.active img");
        
        $("#high_area1").css("background-color","#000")
        $("#high_area2").css("background-color","#000")

        // if there was no highlighted areas loaded, it will call the loadHighlightingAreas method
        if ( $("#high_area1").css("top") == "0px") {
            loadHighlightingAreas();
        };

        $("#publication_date").text(currrent_img.attr("pub_date"));
        //$("#newspaper_name").text(currrent_img.attr("media"));
	$("#newspaper_name").text(currrent_img.attr("media")).attr("href",$("#images_section div.active img").attr('url'));
        // $("#source_of_image").attr("href",$("#images_section div.active img").attr('src'));
        $("#source_of_image").attr("value",$("#images_section div.active img").attr('src')).tooltip({placement:'bottom'})
        $("#image_number").text(currrent_img.attr("id").substr(5,100))
    });

    // if the user have zoomed out or zoomed in, it will reload the highlighted areas again
    $(window).resize(function() {
        renderHighlightedAreas();
    });

    // when the user choose a code from the drop down menu, and click this button it will set the code of this highlighted area by this code
    $("#set_code").on("click",function () {
        var ha_cssid = $("#current_high_area").attr("value")
        ha = getHighlightedArea(ha_cssid);
        ha.code_id = $("#codes").val();
        saveHighlightedArea(ha);
        renderHighlightedAreas();
    });

    // it will set the highlighted areas to zero 
    $("#clear_highlighting").click(function () {
        deleteHighlightedAreas(getCurrentImageId());
        renderHighlightedAreas();
        progressBarPercentage();
    })  

    // this used to for "nothing to code here"
    $("#skip_coding").click(function () {
        var current_img = getCurrentImage();
        // Clear existing areas
        deleteHighlightedAreas(getCurrentImageId());
        nothingToCode(getCurrentImageId());
        renderHighlightedAreas();
        progressBarPercentage();
    })
    
    // call the loadHighlightingAreas after loading all the images
    window.onload = function() {
        renderHighlightedAreas();
    }

    // this part used for the heroku deployment, which is replacing the url of an image to the 404.jpg image if the image doesn't exist
    $("#myCarousel img").error(function (e) {
        $(this).attr("src","/assets/404.jpg")
    })

    progressBarPercentage()

});

// Return the current image
function getCurrentImage () {
    return $("#images_section div.active img");
}
function getCurrentImageId () {
    return getCurrentImage().attr("name");
}

// Enable dragging and resizing functionality on a jquery result set
function enableDragging(elt) {
    elt.draggable( {
        stop: function (event, ui) {
            // Get highlighted area, update and save
            cssid = $(this).attr('id').substr(3);
            ha = getHighlightedArea(cssid);
            // Get new position of dragged area
            carousel_position = $('.carousel').position();
            ha.y1 = ui.position.top - carousel_position.top;
            ha.x1 = ui.position.left - carousel_position.left;
            saveHighlightedArea(ha);
        },
    })
    .resizable({
        containment:'#myCarousel',
        handles: "se, ne",
        aspectRatio: false,
        resize: function(e, ui) {
            // Get highlighted area, update and save
            cssid = $(this).attr('id').substr(3);
            ha = getHighlightedArea(cssid);
            // Get new position of dragged area
            carousel_position = $('.carousel').position();
            ha.width = ui.size.width;
            ha.height = ui.size.height;
            saveHighlightedArea(ha);
            renderHighlghtedAreas();
        }
    });
}

// API for tracking modified status
function setModified () {
    $("#status").attr("value","1");
}
function isModified () {
    return ($("#status").attr("value") == '1');
}

// API for nothing to code button
function clearNothingToCode (img_id) {
    var nothing_to_code = $('[name="nothing_to_code_' + img_id + '"]');
    nothing_to_code.val('0');
}
function nothingToCode (img_id) {
    var nothing_to_code = $('[name="nothing_to_code_' + img_id + '"]');
    nothing_to_code.val('1');
}
function hasNothingToCode (img_id) {
    var nothing_to_code = $('[name="nothing_to_code_' + img_id + '"]');
    return (nothing_to_code.val() == '1');    
}

function clearHighlightedAreas () {
    $('.high_area.clone').remove();
}

function renderHighlightedArea (ha) {
    // If the area is deleted, don't render
    if (ha.deleted == 1) {
        return;
    }
    // Create a new highlighted area by cloning a template DOM element
    var ha_elt = $('#high_area_template').clone();
    ha_elt.attr('id', 'ha_' + ha.cssid);
    ha_elt.addClass('clone');
    $('#high_area_template').after(ha_elt);
    // Position and style the new highlighted area
    img_pos = $("#myCarousel").position();
    ha_elt.css("top", (parseInt(img_pos.top) + parseInt(ha.y1)) + 'px');
    ha_elt.css("left", (parseInt(img_pos.left) + parseInt(ha.x1)) + 'px');
    ha_elt.css("height", ha.height + 'px');
    ha_elt.css("width", ha.width + 'px');
    ha_elt.css("background-color", $("#code_"+ha.code_id).css("background-color"));
}

// Display highlighted areas
function renderNothingToCode () {
    // Check whether the current image has nothing to code
    var img_id = getCurrentImageId();
    var nothing_to_code = $('[name="nothing_to_code_' + img_id + '"]');
    if (nothing_to_code.val() == 0) {
        return;
    }
    // Create a new highlighted area by cloning a template DOM element
    var ha_elt = $('#high_area_template').clone();
    ha_elt.attr('id', 'ha_' + ha.cssid);
    ha_elt.addClass('clone');
    ha_elt.addClass('no_code');
    $('#high_area_template').after(ha_elt);
    // Position and style the new highlighted area
    img_pos = $("#myCarousel").position();
    ha_elt.css("top", parseInt(img_pos.top) + 'px');
    ha_elt.css("left", parseInt(img_pos.left) + 'px');
    ha_elt.css("width", getCurrentImage().width() + 'px');
    ha_elt.css("height", getCurrentImage().height() + 'px');
    ha_elt.css("background-color", "#eee");
    ha_elt.css("opacity", "0.9");
}

function renderHighlightedAreas () {
    clearHighlightedAreas();
    ha_list = getHighlightedAreas(getCurrentImageId());
    var i;
    for (i = 0; i < ha_list.length; i++) {
        renderHighlightedArea(ha_list[i]);
    }
    renderNothingToCode();
    // Enable dragging if the user is allowed to edit this thread
    if ($("#allow_coding").attr("value") == "true") {
        enableDragging($('.high_area').not('.no_code'));
    }
}

// the imgAreaSelect callback for the event onSelectEnd, which handles setting the values for the highlighted areas divs
function highlightingArea (img, selection) {
    // Create the highlighted area
    img_id = getCurrentImageId();
    code_id = '';
    ha = addHighlightedArea(img_id, code_id, selection);
    // display the coding box, to ask the user to choose a code
    $('#coding_topics').modal({backdrop:false});
    $("#current_high_area").attr("value",ha.cssid)
    progressBarPercentage()
    highlighting_done();
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
    
    // Clear all highlighted areas
    $('.high_area.clone').remove();
    
    // Get the element containing highlighted area info for current image
    var highlight_group = $("#ha_group_" + current_img.attr("name"));
    highlight_group.children().each(function () {
        // Position a single highlighted area
        var ha_name = $(this).attr("id");
        ha = makeHighlightingArea();
        // Set the css for the highlight area using data from hidden fields
        var _top = img_pos.top + parseInt($("#"+ha_name+"_y1").attr("value"));
        var _left= img_pos.left + parseInt($("#"+ha_name+"_x1").attr("value"));
        ha.css("top",_top);
        ha.css("left",_left);
        ha.css("height",$("#"+ha_name+"_height").attr("value"));
        ha.css("width",$("#"+ha_name+"_width").attr("value"));
        // Get the code id and set the color of the highlighted area
        var code_id = $("#"+ha_name+"_code_id").attr("value")
        ha.css("background-color", $("#code_"+code_id).css("background-color"))
        ha.css("opacity", " 0.4")
        // this condition is used to distingesh the "nothing to code here" area
        if (image_hidden_fields.find("#"+ha_name+"_code_id").attr("value") == "-1")  {
            ha.css("background-color", "#eee")
            ha.css("opacity", " 0.8")
            if (ha.children().length == 0) {
                ha.append("<h1 style='text-align:center; color: black;'>None</h1>");
            }
            ha.css("top",image_hidden_fields.find("#"+ha_name+"_y1").attr("value"));
            ha.css("left",image_hidden_fields.find("#"+ha_name+"_x1").attr("value"));
        }
    });
}

// set the values of the highlighted areas to zero
function clearHighlightedArea () {
    $("#high_area1").css("top","0px");
    $("#high_area1").css("width","0px");
    
    $("#high_area2").css("top","0px");
    $("#high_area2").css("width","0px");

    progressBarPercentage()
    setModified();
}

// calculate the percentage of progress bar 
function progressBarPercentage () {
    // set the total number of images
    $("#total").text($("#total_images_number").attr("value"))
    var image_count = parseInt($("#total").text())
    var coded_count = 0;
    
    // Go through each image div
    $("#images_section div.item").each(function () {
        img_id = $(this).find('img').attr('name');
        if (hasNothingToCode(img_id)) {
            coded_count++;
        } else {
            ha_list = getHighlightedAreas(img_id);
            var i;
            for (i = 0; i < ha_list.length; i++) {
                if (ha_list[i].deleted != 1) {
                    coded_count++;
                    break;
                }
            }
        }
    });
    // calculate percentage of the bar
    var percentage = Math.ceil((coded_count/image_count) * 100)
    // set the value in percentage form "%"
    $(".bar").css("width",Math.ceil(percentage)+"%")
    $("#remain").text(coded_count);
}

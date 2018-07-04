$(document).ready(function () {
    // initializing the image slider "carousel" plugin
    carousel = $('.carousel').carousel();

    // checks if the user is owner, if so, it will initialize the imgAreaSelect plugin which is used for highlighting
    if (pageData.allowedToCode) {
        // initializing imgAreaSelect plugin for the current active (displayed image)
        $('#images_section div.active img').imgAreaSelect({instance: true, handles: true,onSelectEnd: highlightingArea});
    };

    // setting the value for each image
    var source_url = $("#images_section div.active img").attr('url');
    var media_url = $("#images_section div.active img").attr('media_url');
    $("#publication_date").text($("#images_section div.active img").attr("pub_date"));
    $("#newspaper_name").text($("#images_section div.active img").attr("media")).attr("href",media_url);
    $("#original_image_url").text("Link to original image").attr("href",source_url);
    $("#source_of_image").attr("value",$("#images_section div.active img").attr('url')).tooltip({placement:'bottom'})

    // attaching a callback for the slide event on the carousel, so it will clear all the highlighted areas when the user slide
    // "This event fires immediately when the slide instance method is invoked." from bootstrap documentation
    carousel.on('slide',function () {
        // reset the highlighted areas values
        clearHighlightedAreas();
    });

    //hides alert message "first image of this thread". Prevents from appearing in the first image that is being coded.
    $('#youHaveLoopedAlert').hide();

    // "This event is fired when the carousel has completed its slide transition." from bootstrap documentation
    carousel.on('slid',function(){
        // set the current image to the current active(displayed) image in the carousel
        var current_img = $("#images_section div.active img")

        renderHighlightedAreas();

        // after we slide for the next image, we normally initialize the imgAreaSelect for the new image, but before that, we also check if the user have a premonition
        if (pageData.allowedToCode) {
            // is the image was not found, it will not initialize the imgAreaSelect, and this not working in the heroku deployed version
            if ( (current_img.attr("alt") == "404") || (current_img.attr('data-missing')=='true') ) {
                $('#images_section div.active img').imgAreaSelect({handles: true,onSelectEnd: highlightingArea, disable:true});
                $('#missing_image_id').val(current_img.attr('data-id'));
            }else{
                $('#images_section div.active img').imgAreaSelect({handles: true,onSelectEnd: highlightingArea});
            }
        }
        setMissingImageInfoFromImg(current_img);

        // update the sidebar meta-data about the image
        var source_url = $("#images_section div.active img").attr('url');
        var media_url = $("#images_section div.active img").attr('media_url');
        $("#publication_date").text(current_img.attr("pub_date"));
    	$("#newspaper_name").text($("#images_section div.active img").attr("media")).attr("href",media_url);
        $("#original_image_url").text("Link to original image").attr("href",source_url);
        $("#source_of_image").attr("value",source_url).tooltip({placement:'bottom'})
        $("#image_number").text(current_img.attr("id").substr(5,100))

        // alert when we get to the first image image of the thread
        if ($("#images_section div img:first").first().attr('name') == $("#images_section div.active img").attr('name')){
            $('#youHaveLoopedAlert').show();
        } else {
            $('#youHaveLoopedAlert').hide();
        }

        // TODO: update the 'i' param on the url to be current_img.attr("name")... without refreshing the page
    });

    // this attemps to handle user zoom in/out, but doesn't play well with the highlighted area resizing code
    /*$(window).resize(function() {
        renderHighlightedAreas();
    });*/

    // when the user choose a code from the drop down menu, and click this button it will set the code of this highlighted area by this code
    $("#set_code").on("click",function() {
        setCodeOnHighlightedArea(pageData.currentHighlightedArea);
    });

    // it will set the highlighted areas to zero
    $(".clear_highlighting").click(function () {
        HighlightedAreas.removeAllForImage(getCurrentImageId());
        renderHighlightedAreas();
        progressBarPercentage();
    });

    // this used to for "nothing to code here"
    $(".skip_coding").click(markAsNothingToCode)

    // render the highlighted areas after loading all the images
    window.onload = function() {
        renderHighlightedAreas();
    }

    // this part used for the heroku deployment, which is replacing the url of an image to the 404.jpg image if the image doesn't exist
    $("#myCarousel img").error(function (e) {
        $(this).attr("src","/assets/404.jpg")
    })

    progressBarPercentage()

});

function addCloseAreaBehaviors(){
    if (pageData.allowedToCode) {
        $(".ha-close-icon").on("click",function() {
            ha_id = $(this).parent('div').attr("id");
            $('#' + ha_id).hide();
            HighlightedAreas.removeOne(ha_id);
        });
    }
}

function setMissingImageInfoFromImg(imgElem){
    if(imgElem.attr('data-missing')=='true' || imgElem.attr('src')=="/assets/404.jpg"){
        $('#missing_image_id').val(imgElem.attr('data-id'));
        $('#downloadImageAlert').show();
    } else {
        $('#downloadImageAlert').hide();
    }
}

function markAsNothingToCode(){
    var current_img = getCurrentImage();
    // Clear existing areas
    HighlightedAreas.removeAllForImage(getCurrentImageId());
    nothingToCode(getCurrentImageId());
    renderHighlightedAreas();
    progressBarPercentage();
}

function setCodeOnHighlightedArea(highlightedAreaCssId) {
    ha = HighlightedAreas.getByCssId(highlightedAreaCssId);
    ha.code_id = $("#codes").val();
    HighlightedAreas.save(ha);
    renderHighlightedAreas();
}

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
        containment:'#myCarousel',
        stop: function (event, ui) {
            // Get highlighted area, update and save
            cssid = $(this).attr('id').substr(3);
            ha = naturalToScreen(HighlightedAreas.getByCssId(cssid));
            // Get new position of dragged area
            carousel_position = $('.carousel').position();
            ha.y1 = ui.position.top - carousel_position.top;
            ha.x1 = ui.position.left - carousel_position.left;
            HighlightedAreas.save(screenToNatural(ha));
            renderHighlightedAreas();
        },
    });
    elt.resizable({
        handles: "se",
        stop: function(e, ui) {
            // Get highlighted area, update and save
            cssid = $(this).attr('id').substr(3);
            ha = naturalToScreen(HighlightedAreas.getByCssId(cssid));
            // Get new position of dragged area
            ha.width = ui.size.width;
            ha.x2 = ha.x1 + ha.width;
            ha.height = ui.size.height;
            ha.y2 = ha.y2 + ha.height;
            HighlightedAreas.save(screenToNatural(ha));
            renderHighlightedAreas();
        }
    });
}

function renderHighlightedAreas () {
    clearHighlightedAreas();
    ha_list = HighlightedAreas.getAllForImage(getCurrentImageId());
    var i;
    for (i = 0; i < ha_list.length; i++) {
        var elem = renderHighlightedArea(ha_list[i]);
        if (elem!=null && pageData.allowedToCode) {
            enableDragging(elem);
        }
    }
    renderNothingToCode();
    addCloseAreaBehaviors();
}

// API for tracking modified status
function setModified(isModified) {
    if(isModified==null) {
        isModified = 1;
    }
    $("#status").attr("value",isModified);
}
function isModified() {
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

function renderHighlightedArea(ha) {
    ha = naturalToScreen(ha);
    // If the area is deleted, don't render
    if (ha.deleted == 1) {
        return null;
    }
    // Create a new highlighted area by cloning a template DOM element
    var ha_elt = $('#high_area_template').clone();
    var icon = $('<div class="user-id"><img class="avatar-icon" src="http://gravatar.com/avatar/' + ha.hash + '?s=20&d=identicon"/> <span class="ha-user-name">' +  ha.username + '</span></div>');
    icon.appendTo(ha_elt);

    if (pageData.allowedToCode) {
        var close_icon = $('<div id="close_' + ha.cssid + '" class="ha-close-icon"><img id="close_img_' + ha.cssid + '" src="/assets/icon-close.png" title="Remove area" alt="Remove area icon"/></div>');
        close_icon.appendTo(ha_elt);
    }

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
    return ha_elt;
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
    ha_elt.attr('id', 'ha_' + nothing_to_code.attr('name'));
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
    ha_elt.css("opacity", ".4");
    ha_elt.css("background-image", "url('/nothing-to-code.png')");
    ha_elt.css("background-repeat", "no-repeat");
}

// the imgAreaSelect callback for the event onSelectEnd, which handles setting the values for the highlighted areas divs
function highlightingArea(img, selection) {
    // Create the highlighted area
    img_id = getCurrentImageId();
    code_id = '';
    ha = HighlightedAreas.add(current_user, current_user_hash, img_id, code_id, screenToNatural(selection));
    if( $("#codes option").length == 1) {   // if only one topic, default to that one
        setCodeOnHighlightedArea( ha.cssid );
    } else {
        // display the coding box, to ask the user to choose a code
        pageData.currentHighlightedArea = ha.cssid; // remember the current highlighted area id
        $('#coding_topics').modal({backdrop:false});
    }
    progressBarPercentage()
    highlighting_done();
}

// cancel the selection when the user done
function highlighting_done() {
    var current_img = $("#images_section div.active img")
    var currentImgSelectArea = null;
    if (current_img.attr("altr") == "Assets404") {
        currentImgSelectArea = $('#images_section div.active img').imgAreaSelect(
            {instance: true, handles: true, onSelectEnd: highlightingArea, disable:true});
    } else {
        currentImgSelectArea = $('#images_section div.active img').imgAreaSelect(
            {instance: true, handles: true, onSelectEnd: highlightingArea});
    }
    currentImgSelectArea.cancelSelection()
};

// calculate the percentage of progress bar
function progressBarPercentage () {
    // set the total number of images
    $("#total").text( pageData.totalImageCount );
    var coded_count = 0;

    // Go through each image div
    $("#images_section div.item").each(function () {
        img_id = $(this).find('img').attr('name');
        if (hasNothingToCode(img_id)) {
            coded_count++;
        } else {
            ha_list = HighlightedAreas.getAllForImage(img_id);
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
    var percentage = Math.ceil((coded_count/pageData.totalImageCount) * 100)
    // set the value in percentage form "%"
    $(".bar").css("width",Math.ceil(percentage)+"%")
    $("#remain").text(coded_count);
}

function screenToNatural (selection) {
    scale = currentImgScale();
    scaled = jQuery.extend(true, {}, selection);;
    scaled.x1 = selection.x1 / scale;
    scaled.y1 = selection.y1 / scale;
    scaled.x2 = selection.x2 / scale;
    scaled.y2 = selection.y2 / scale;
    scaled.width = selection.width / scale;
    scaled.height = selection.height / scale;
    return scaled;
}

function naturalToScreen (selection) {
    scale = currentImgScale();
    scaled = jQuery.extend(true, {}, selection);;
    scaled.x1 = selection.x1 * scale;
    scaled.y1 = selection.y1 * scale;
    scaled.x2 = selection.x2 * scale;
    scaled.y2 = selection.y2 * scale;
    scaled.width = selection.width * scale;
    scaled.height = selection.height * scale;
    return scaled;
}

function currentImgScale () {
    var originalWidth = $("#images_section div.active img").attr('image_size').split('x')[0];
    var visibleWidth = $("#images_section div.active img").width();
    return visibleWidth / originalWidth;
}

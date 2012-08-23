$(function () {

	// this method is for resizing the images to the appropriate size
	function imagesResizing () {
		
		var images = $(".images img")
		var image_box = $(".images .span1")
		var number_of_images = parseInt($("#number_of_column").attr("value"))
		var row_width = $(".img_box").width()

		// iterates over all the images
		for (var i = 0; i < images.length; i++) {
			var curr_img = $(images[i])
			var curr_img_box = $(image_box[i])

			// for the images with direct links from kisoko
			var original_img_width = $(images[i]).width() 

			// the carousel width, if we change the size of the carousel we should change this value also
			var displayed_img_width = 670

			// for the images with direct links from kisoko
			var original_img_height = $(images[i]).height() 

			// calculated based on the displayed width
			var displayed_img_height = (original_img_height / (original_img_width/displayed_img_width) )

			// we can change "0" at the end of the expression with any number which is the margin between images
			var image_down_size_ratio = (displayed_img_width / (row_width/number_of_images - 0))

			// the number in this case "0" at the end of this expression should be the same as the line 29
			curr_img.width((row_width/number_of_images - 0))

			curr_img.height((displayed_img_height/image_down_size_ratio))

			// set the the width of the div containing the image and it's highlighted areas
			curr_img_box.css("width",(row_width/number_of_images))

		};
	}

	// load the highlighted areas for each image
	function loadImagesHighlightedAreas () {

		// iterates over all the highlighted areas 
		var high_areas = $("#high_areas div")
		for (var i = high_areas.length -1; i >= 0; i--) {
				var c_image_id = $(high_areas[i]).attr("id").substr(5)

				var img_name = $($(high_areas[i]).children()[2]).attr("value")
				var c_image = $('img[name='+img_name+']') 
				var high_area1 = $("div[image_name="+img_name+"]").find("div#high_area"+1)
				var high_area2 = $("div[image_name="+img_name+"]").find("div#high_area"+2)
				

				var dispalyed_img_size = 670
				var ratio = (dispalyed_img_size/c_image.width())
			
				// higlighted area 1

				var curr_high_area_code = $("#image"+c_image_id+"_ha1"+"_code_id").attr("value")
				
				// in case of "nothing to code here"
				if (curr_high_area_code == "-1") {
					high_area1.css("background-color", "#eee")
				}else{
					high_area1.css("background-color", $("#code_"+curr_high_area_code).css("background-color"))
				}

				var _top = parseFloat($("#image"+c_image_id+"_ha"+"1"+"_y1").attr("value")) / ratio

				_top = (_top) + c_image.position().top
				
				high_area1.css("top", Math.ceil(_top) + "px" )

				var _left = parseFloat($("#image"+c_image_id+"_ha"+"1"+"_x1").attr("value")) / ratio

				_left = (_left) + c_image.position().left
				high_area1.css("left", Math.ceil(_left) + "px")

				var _width = parseFloat($("#image"+c_image_id+"_ha"+"1"+"_width").attr("value")) / ratio 

				high_area1.css("width", (_width) + "px")

				var _height = parseFloat($("#image"+c_image_id+"_ha"+"1"+"_height").attr("value")) / ratio
				high_area1.css("height", (_height) + "px")


				// higlighted area 2
				
				curr_high_area_code = $("#image"+c_image_id+"_ha2"+"_code_id").attr("value")

				high_area2.css("background-color", $("#code_"+curr_high_area_code).css("background-color"))	

				_top = parseFloat($("#image"+c_image_id+"_ha"+"2"+"_y1").attr("value")) / ratio
				_top = _top + c_image.position().top
				high_area2.css("top", Math.ceil(_top) + "px" )

				_left = parseFloat($("#image"+c_image_id+"_ha"+"2"+"_x1").attr("value")) / ratio
				_left = _left + c_image.position().left
				high_area2.css("left", Math.ceil(_left) + "px")

				_width = parseFloat($("#image"+c_image_id+"_ha"+"2"+"_width").attr("value")) / ratio
				high_area2.css("width", _width + "px")

				_height = parseFloat($("#image"+c_image_id+"_ha"+"2"+"_height").attr("value")) / ratio
				high_area2.css("height", _height + "px")

		};

	}

	// calculating the percentage of the loading bar of the images
	var step = 100 / $(".images img").length
	// attach a callback for load event on all the images, an for each images load, it will call this event and advance the bar
	$(".images img").load(function (event) {
		curr_progress = parseInt($("#loading-bar .bar").attr("style").split(':')[1].split('%')[0])
		$("#loading-bar .bar").css("width", curr_progress + step*2 + "%")
	})

	// run the resizing and the loading the highlighted areas after all the images loads
	window.onload = function() {
		imagesResizing()
		
		// after all the images load, we convert the display of the div contains the images to block instated of none
		$("#datavis").css("display","block")

		// then loads the highlighted areas
		loadImagesHighlightedAreas()

		// hide the progress bar
		$("#loading-bar").css("display","none")
		$("#loading-bar-h").css("display","none")
	};

	// if the user resize the page it will loads the highlighted areas again
	$(window).resize(function() {
	 	loadImagesHighlightedAreas();
	});

	// this part used for the heroku deployment, which is replacing the url of an image to the 404.jpg image if the image doesn't exist	
	$(".images img").error(function (e) {
		$(this).attr("src","/assets/404.jpg")
	})

})
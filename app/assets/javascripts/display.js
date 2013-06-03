$(function () {

	// this method is for resizing the images to the appropriate size in the array of images
	function imagesResizing () {
		
		var images = $(".images img")
		var image_box = $(".images .span1")
		var number_of_images = parseInt($("#number_of_column").attr("value"))
		var row_width = $(".img_box").width()
		var margin_between_images  = 3 //margin between images in the array
		var displayed_img_width = 670 // the carousel width, if we change the size of the carousel we should change this value also
		var width_of_image_in_display = row_width/number_of_images //with of the row divided by number of images

		// iterates over all the images
		for (var i = 0; i < images.length; i++) {
			var curr_img = $(images[i])
			var curr_img_box = $(image_box[i])

			// for the images with direct links from kisoko
			var original_img_width = $(images[i]).width() 

			// for the images with direct links from kisoko
			var original_img_height = $(images[i]).height() 

			// calculated based on the displayed width
			var displayed_img_height = (original_img_height / (original_img_width/displayed_img_width) )

			// ratio between original image and image in display
			var image_down_size_ratio = (displayed_img_width / (width_of_image_in_display - margin_between_images))

			// sets width and height of images in array
			curr_img.width((width_of_image_in_display - margin_between_images))
			curr_img.height((displayed_img_height/image_down_size_ratio))

			// set the the width of the div containing the image and it's highlighted areas
			curr_img_box.css("width",(width_of_image_in_display))

		};
	}

	// load the highlighted areas for each image
	function loadImagesHighlightedAreas () {
	
		// Iterates over all images
		$("#high_images .ha_group").each(function () {
			var img_id = $(this).attr('id').substr(9);
			ha_list = HighlightedAreas.getAllForImage(img_id);
			var img = $('img[name='+img_id+']');
			// Iterate over all highlighted areas for a single image
			var i, ha;
			for (i = 0; i < ha_list.length; i++) {
				// Get model and view
				ha = ha_list[i];
				ha_div = $('#ha_' + ha.id);
				// Calculate scaling
				var ratio = (ha.img_width/img.width());
				// Calculate geometry
				var _top = ha.y1/ratio + img.position().top;
				var _left = ha.x1/ratio + img.position().left;
				var _width = ha.width / ratio;
				var _height = ha.height / ratio;
				// Update css
				ha_div.css("top", Math.ceil(_top) + "px" );
				ha_div.css("left", Math.ceil(_left) + "px");
				ha_div.css("width", _width + "px");
				ha_div.css("height", _height + "px");
				ha_div.css("background-color", $("#code_"+ha.code_id).css("background-color"));
			}
		});
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

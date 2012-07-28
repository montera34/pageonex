$(function () {
	
	var images = $(".images img")
	var image_box = $(".images .span1")
	var number_of_images = images.length/parseInt($("#number_of_rows").attr("value"))
	var row_width = $("div.images").width() - 225;	

	for (var i = 0; i < images.length; i++) {
		var curr_img = $(images[i])
		var curr_img_box = $(image_box[i])

		var original_img_width = curr_img.attr("image_size").split("x")[0]
		var displayed_img_width = 670

		var original_img_height = curr_img.attr("image_size").split("x")[1]
		var displayed_img_height = (original_img_height / (original_img_width/displayed_img_width) )

		var image_down_size_ratio = (displayed_img_width / (row_width/number_of_images - 9))	

		curr_img.width((row_width/number_of_images - 9))

		curr_img.height((displayed_img_height/image_down_size_ratio))

		curr_img_box.css("width",(row_width/number_of_images))

	};

	window.onload = function() {
		loadImagesHighlightedAreas()
	};

	function loadImagesHighlightedAreas () {

		high_areas = $("#high_areas div")
		for (var i = high_areas.length -1; i >= 0; i--) {
				var c_high_area_id = $(high_areas[i]).attr("id").substr(5)

				var high_area1 = $("div.images").find("div.thum_image"+c_high_area_id).find("div#high_area"+1)
				var high_area2 = $("div.images").find("div.thum_image"+c_high_area_id).find("div#high_area"+2)
				var c_image = $("img#image"+c_high_area_id)
		
				var dispalyed_img_size = 670
				var ratio = (dispalyed_img_size/c_image.width())
			
				// higlighted area 1

				var curr_high_area_code = $("#image"+c_high_area_id+"_ha1"+"_code_id").attr("value")
				
				if (curr_high_area_code == "-1") {
					high_area1.css("background-color", "#eee")
					if (high_area1.children().length == 0) {
						high_area1.append("<p style='text-align:center; color: black;'>Nothing to code here</p>");
					};
				}else{
					high_area1.css("background-color", $("#code-"+curr_high_area_code).css("background-color"))
				}

				var _top = parseFloat($("#image"+c_high_area_id+"_ha"+"1"+"_y1").attr("value")) / ratio

				_top = (_top) + c_image.position().top
				
				high_area1.css("top", Math.ceil(_top) + "px" )

				var _left = parseFloat($("#image"+c_high_area_id+"_ha"+"1"+"_x1").attr("value")) / ratio

				_left = (_left) + c_image.position().left
				high_area1.css("left", Math.ceil(_left) + "px")

				var _width = parseFloat($("#image"+c_high_area_id+"_ha"+"1"+"_width").attr("value")) / ratio 

				high_area1.css("width", (_width) + "px")

				var _height = parseFloat($("#image"+c_high_area_id+"_ha"+"1"+"_height").attr("value")) / ratio
				high_area1.css("height", (_height) + "px")


				// higlighted area 2
				
				var curr_high_area_code = $("#image"+c_high_area_id+"_ha2"+"_code_id").attr("value")
				high_area2.css("background-color", $("#code-"+curr_high_area_code).css("background-color"))	

				_top = parseFloat($("#image"+c_high_area_id+"_ha"+"2"+"_y1").attr("value")) / ratio
				_top = _top + c_image.position().top
				high_area2.css("top", Math.ceil(_top) + "px" )

				_left = parseFloat($("#image"+c_high_area_id+"_ha"+"2"+"_x1").attr("value")) / ratio
				_left = _left + c_image.position().left
				high_area2.css("left", Math.ceil(_left) + "px")

				_width = parseFloat($("#image"+c_high_area_id+"_ha"+"2"+"_width").attr("value")) / ratio
				high_area2.css("width", _width + "px")

				_height = parseFloat($("#image"+c_high_area_id+"_ha"+"2"+"_height").attr("value")) / ratio
				high_area2.css("height", _height + "px")

		};

	}

	
	$(window).resize(function() {
	 	loadImagesHighlightedAreas();
	});

	$(".images img").error(function (e) {
		$(this).attr("src","/assets/404.jpg")
	})

})
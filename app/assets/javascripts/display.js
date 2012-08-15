$(function () {

	function imagesResizing () {
		
		var images = $(".images img")
		var image_box = $(".images .span1")
		var number_of_images = parseInt($("#number_of_column").attr("value"))// images.length/parseInt($("#number_of_rows").attr("value"))
		// var row_width = $("div.images").width() - 225;	
		var row_width = $(".img_box").width() 

		for (var i = 0; i < images.length; i++) {
			var curr_img = $(images[i])
			var curr_img_box = $(image_box[i])

			var original_img_width = $(images[i]).width() // for the images with direct links from kisoko
			var displayed_img_width = 670

			var original_img_height = $(images[i]).height() // for the images with direct links from kisoko
			var displayed_img_height = (original_img_height / (original_img_width/displayed_img_width) )

			var image_down_size_ratio = (displayed_img_width / (row_width/number_of_images - 0))//9	margin between images

			curr_img.width((row_width/number_of_images - 0))//9 margin between images

			curr_img.height((displayed_img_height/image_down_size_ratio))

			curr_img_box.css("width",(row_width/number_of_images))

		};
	}


	function loadImagesHighlightedAreas () {

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

	var step = 100 / $(".images img").length
	$(".images img").load(function (event) {
		curr_progress = parseInt($("#loading-bar .bar").attr("style").split(':')[1].split('%')[0])
		$("#loading-bar .bar").css("width", curr_progress + step*2 + "%")
	})

	window.onload = function() {
		imagesResizing()
		
		$("#datavis").css("display","block")

		loadImagesHighlightedAreas()

		$("#loading-bar").css("display","none")
		$("#loading-bar-h").css("display","none")
	};
	$(window).resize(function() {
	 	loadImagesHighlightedAreas();
	});

	$(".images img").error(function (e) {
		$(this).attr("src","/assets/404.jpg")
	})

})
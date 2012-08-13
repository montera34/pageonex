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

			// var original_img_width = curr_img.attr("image_size").split("x")[0] // for scraped full image size
			var original_img_width = $(images[i]).width() // for the images with direct links from kisoko
			// alert($(images[i]).height())
			var displayed_img_width = 670

			// var original_img_height = curr_img.attr("image_size").split("x")[1] // for scraped full image size
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
				var c_high_area_id = $(high_areas[i]).attr("id").substr(5)

				// var c_image = $("img#image"+c_high_area_id)
				// var high_area1 = $("div.images").find("div.thum_image"+c_high_area_id).find("div#high_area"+1)
				// var high_area2 = $("div.images").find("div.thum_image"+c_high_area_id).find("div#high_area"+2)

				var img_name = $($(high_areas[i]).children()[2]).attr("value")
				var c_image = $('img[name='+img_name+']') 
				var high_area1 = $("div[image_name="+img_name+"]").find("div#high_area"+1)
				var high_area2 = $("div[image_name="+img_name+"]").find("div#high_area"+2)
				

				var dispalyed_img_size = 670
				var ratio = (dispalyed_img_size/c_image.width())
			
				// higlighted area 1

				var curr_high_area_code = $("#image"+c_high_area_id+"_ha1"+"_code_id").attr("value")
				
				if (curr_high_area_code == "-1") {
					high_area1.css("background-color", "#eee")
					// if (high_area1.children().length == 0) {
					// 	high_area1.append("<p style='text-align:center; color: black;'>None</p>");
					// };
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

	var step = 100 / $(".images img").length
	$(".images img").load(function (event) {
		curr_progress = parseInt($("#loading-bar .bar").attr("style").split(':')[1].split('%')[0])
		$("#loading-bar .bar").css("width", curr_progress + step*2 + "%")
	})

	window.onload = function() {
		imagesResizing()
		
		$("#datavis").css("display","block")

		// insert images dates above the first images row
		// var dates = $('#date-box').children()
		// var imgs = $($('.img_box')[0]).children()
		// var columns = dates.length
		// for (var i = 0; i < columns; i++) {
		// 	$(imgs[i]).prepend('<h6 style="text-align:center; color:#000;font-size: 10px;">'+$(dates[i]).attr("name")+'</h6>')
		// };
		
		loadImagesHighlightedAreas()

		$("#loading-bar").css("display","none")
		$("#loading-bar-h").css("display","none")
		// $(".images").css("visibility","visible")
	};
	$(window).resize(function() {
	 	loadImagesHighlightedAreas();
	});

	$(".images img").error(function (e) {
		$(this).attr("src","/assets/404.jpg")
	})

})


// Interface for highlighted areas
// HighlightedAreas.add() - Add a single highlighted area to the current page
// HighlightedAreas.save() - Save a highlighted area
// HighlightedAreas.removeAllForImage() - Delete all highlighted areas for the current page
// HighlightedAreas.removeOne() - Delete a specific highlighted area
// HighlightedAreas.getByCssId() - Get data for a single highlighted area
// HighlightedAreas.getAllForImage() - Get a list of highlighted areas

var HighlightedAreas = {

    _roundSelection: function(selection) {
        var s = {
            x1: Math.round(selection.x1),
            y1: Math.round(selection.y1),
            x2: Math.round(selection.x2),
            y2: Math.round(selection.y2)
        };
        s.width = s.x2 - s.x1;
        s.height = s.y2 - s.y1;
        return s;
    },

    add: function(username, hash, img_id, code_id, selection) {

        // Get div containing highlighted area info for the specified image
        var ha_group = $("#ha_group_" + img_id);
        var count = ha_group.children().length;
        var cssid = img_id + '_' + (count+1);
        var roundedSelection = HighlightedAreas._roundSelection(selection);
        // Create hidden fields to contain data
        var ha_elt = $('<div>').attr('id', cssid).appendTo(ha_group);
        var tag = '<input type="hidden"/>';
        $(tag).attr('name', 'ha_name[]').val(cssid).appendTo(ha_elt);
        $(tag).attr('name', 'img_id_'+cssid).val(img_id).appendTo(ha_elt);
        $(tag).attr('name', 'id_'+cssid).val(0).appendTo(ha_elt);
        $(tag).attr('name', 'code_id_'+cssid).val(code_id).appendTo(ha_elt);
        $(tag).attr('name', 'username_'+cssid).val(username).appendTo(ha_elt);
        $(tag).attr('name', 'hash_'+cssid).val(hash).appendTo(ha_elt);
        $(tag).attr('name', 'x1_'+cssid).val(roundedSelection.x1).appendTo(ha_elt);
        $(tag).attr('name', 'y1_'+cssid).val(roundedSelection.y1).appendTo(ha_elt);
        $(tag).attr('name', 'x2_'+cssid).val(roundedSelection.x2).appendTo(ha_elt);
        $(tag).attr('name', 'y2_'+cssid).val(roundedSelection.y2).appendTo(ha_elt);
        $(tag).attr('name', 'width_'+cssid).val(roundedSelection.width).appendTo(ha_elt);
        $(tag).attr('name', 'height_'+cssid).val(roundedSelection.height).appendTo(ha_elt);
        $(tag).attr('name', 'deleted_'+cssid).appendTo(ha_elt);
        setModified();
        clearNothingToCode(img_id);
        return HighlightedAreas.getByCssId(cssid);
    },

    save: function(ha) {
        // Get element containing hidden fields and update their values
        cssid = ha.cssid;
        var ha_elt = $('#' + cssid);
        $("[name='code_id_"+cssid+"']").val(ha.code_id);
        $("[name='x1_"+cssid+"']").val(ha.x1);
        $("[name='x2_"+cssid+"']").val(ha.x2);
        $("[name='y1_"+cssid+"']").val(ha.y1);
        $("[name='y2_"+cssid+"']").val(ha.y2);
        $("[name='width_"+cssid+"']").val(ha.width);
        $("[name='height_"+cssid+"']").val(ha.height);
        $("[name='deleted_"+cssid+"']").val(ha.deleted);
        setModified();
    },

    removeAllForImage: function(img_id) {
        ha_list = HighlightedAreas.getAllForImage(img_id);
        var i;
        for (i = 0; i < ha_list.length; i++) {
            ha_list[i].deleted = '1';
            HighlightedAreas.save(ha_list[i]);
        }
        clearNothingToCode(img_id);
        setModified();
    },

    removeOne: function(area_id) {
        //id for hidden inputs container of the area with id=ha_ha_47 is ha_47
        ha_removed = HighlightedAreas.getByCssId(area_id.replace("ha_", ''));
        ha_removed.deleted = '1';
        HighlightedAreas.save(ha_removed);
    },

    getByCssId: function(cssid) {
        ha = {}
        ha.cssid = cssid;
        ha.id = $("[name='id_"+cssid+"']").val();
        ha.code_id = $("[name='code_id_"+cssid+"']").val();
        ha.username = $("[name='username_"+cssid+"']").val();
        ha.hash = $("[name='hash_"+cssid+"']").val();
        ha.x1 = $("[name='x1_"+cssid+"']").val();
        ha.x2 = $("[name='x2_"+cssid+"']").val();
        ha.y1 = $("[name='y1_"+cssid+"']").val();
        ha.y2 = $("[name='y2_"+cssid+"']").val();
        ha.width = $("[name='width_"+cssid+"']").val();
        ha.height = $("[name='height_"+cssid+"']").val();
        ha.img_width = $("[name='img_width_"+cssid+"']").val();
        ha.img_height = $("[name='img_height_"+cssid+"']").val();
        ha.deleted = $("[name='deleted_"+cssid+"']").val();
        return ha;
    },

    getAllForImage: function (img_id) {
        // Get div containing highlighted area info for the specified image.
        // Then load the highlighted area for each child element.
        var ha_list = [];
        $("#ha_group_" + img_id).children().each(function () {
            ha_list.push(HighlightedAreas.getByCssId($(this).attr('id')));
        });
        return ha_list;
    }

};

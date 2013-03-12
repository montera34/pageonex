// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs

// require jquery.ui.all

//= require jquery.ui.core
//= require jquery.ui.widget
//= require jquery.ui.mouse
//= require jquery.ui.position

//= require jquery.ui.draggable
// require jquery.ui.droppable
//= require jquery.ui.resizable
// require jquery.ui.selectable
// require jquery.ui.sortable

//= require jquery.ui.accordion
// require jquery.ui.autocomplete
// require jquery.ui.button
// require jquery.ui.dialog
// require jquery.ui.slider
// require jquery.ui.tabs
//= require jquery.ui.datepicker
//= require jquery.ui.datepicker-en-AU
// require jquery.ui.progressbar

// require jquery.ui.effect.all
//= require jquery.ui.effect
// require jquery.ui.effect-blind
// require jquery.ui.effect-bounce
// require jquery.ui.effect-clip
// require jquery.ui.effect-drop
// require jquery.ui.effect-explode
// require jquery.ui.effect-fade
// require jquery.ui.effect-fold
// require jquery.ui.effect-highlight
// require jquery.ui.effect-pulsate
// require jquery.ui.effect-scale
// require jquery.ui.effect-shake
// require jquery.ui.effect-slide
// require jquery.ui.effect-transfer

//= require twitter/bootstrap/bootstrap-transition
//= require twitter/bootstrap/bootstrap-alert
//= require twitter/bootstrap/bootstrap-modal
//= require twitter/bootstrap/bootstrap-dropdown
//= require twitter/bootstrap/bootstrap-scrollspy
// require twitter/bootstrap/bootstrap-tab
//= require twitter/bootstrap/bootstrap-tooltip
//= require twitter/bootstrap/bootstrap-popover
//= require twitter/bootstrap/bootstrap-button
//= require twitter/bootstrap/bootstrap-collapse
// require twitter/bootstrap/bootstrap-typeahead
//= require bootstrap-carousel
// require twitter/bootstrap

// require jquery.imgareaselect
//= require spin.min

// require_tree .

$(function() {
  // initialize any and all popovers on the page
  $('[rel="popover"]').popover({trigger:'hover'});
})
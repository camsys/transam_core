//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery-ui/draggable
//= require jquery-ui/droppable
//= require jquery.form
//= require gritter
//= require bootstrap-editable
//= require bootstrap-editable-rails
//= require cocoon
//= require bootstrap-datepicker/core
//= require_tree .
if($.fn.bootstrapTable) {
  // override bootstrap table default option, set silentSort as false 
  // so whenever sort, blank the table and display the loading message
  $.fn.bootstrapTable.defaults.silentSort = false;
}

$(document).ready(function() {
    $('body').on('click', '.input-group-addon:has(.fa-calendar)', function(event) {
        event.preventDefault();
        $(this).parent().find('input').datepicker('show');
    });


    // install click handlers for navigable objects
    transam.install_quick_link_handlers();

    // Render any popovers and tooltips
    transam.enable_info_popups('.info-icon');
    transam.enable_info_popups('.transam-popover');
    $('.transam-tooltip').tooltip();
    $('table').on('post-body.bs.table', function () {
        transam.enable_info_popups('.transam-popover');

        $('.transam-tooltip').tooltip();
    });


    // Enable any date pickers etc
    transam.enable_date_pickers();

    // Force uppercase text for OFT inputs
    $('[data-convert="uppercase"]').keyup(function(evt) {
        this.value = this.value.toUpperCase();
    });

    // fiscal year fields
    transam.make_fiscal_year('input.fiscal_year');

    // Make the tabs responsive if the viewport gets smaller than the displayed tabs
    $('.responsive-tabs').tabdrop({
        text: '<i class="fa fa-align-justify"></i>'
    });
});
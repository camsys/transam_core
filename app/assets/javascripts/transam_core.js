//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery-ui/draggable
//= require jquery-ui/droppable
//= require jquery.form
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
});
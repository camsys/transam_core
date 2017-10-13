//= require_tree .
if($.fn.bootstrapTable) {
  // override bootstrap table default option, set silentSort as false 
  // so whenever sort, blank the table and display the loading message
  $.fn.bootstrapTable.defaults.silentSort = false;
}

$(document).ready(function() {
    $('.input-group .fa-calendar').click(function (event) {
        event.preventDefault();
        $(this).parent().parent().find('input').datepicker('show');
    });
});
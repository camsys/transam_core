function init_selection(id, current) {
  const table = $('#'+id);
  $(document).ready(function(){
    let wrapper = $('<div class="select_columns">');
    let button = $('<div class="function_button select_button flyout-button">').append('<i class="fas fa-table button-label button-icon" aria-hidden="true">');
    $(document).on('click', ".select_columns", function(event){
      event.stopPropagation();
      event.stopImmediatePropagation();
      $(this).toggleClass("open");
    });

    let flyout = $('<div class="flyout-panel flyout-content-right">');
    let header = $('<header>');
    let title = $('<div class="panel-title">');
    let content = $('<div class="panel-content">');
    let visible = $('<div class="panel-column">')
	.append('<div class="column-header">')
	.append('<div class="column-title">').text("Visible Columns");
    
    title.append($('<i class="fas fa-table title-icon" aria-hidden="true">').text("Manage Columns"));
    content.append(visible);
    header.append(title);
    flyout.append(header);
    flyout.append(content);
    wrapper.append(button)
    wrapper.append(flyout);
    // table.parent().find(".function_bar").append(wrapper).append(flyout);
    table.parent().find(".function_bar").append(wrapper);
    // table.parent().find(".flyout_section").append(flyout);
  });
}
    
    

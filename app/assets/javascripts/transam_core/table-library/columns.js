function init_columns(id, columns, current) {
  const table = $('#'+id);
  const wrapper_html =
'<div class="select_columns">' +
'  <div class="function_button select_button flyout-button">' +
'    <i class="fas fa-table button-label button-icon" aria-hidden="true">'
  ;
  const flyout_html =
'<div class="flyout-panel flyout-content-right">' +	
'  <header>' +
'    <div class="panel-title">' +
'      <i class="fas fa-table title-icon" aria-hidden="true"></i>' +
'      Manage Columns' +
'    </div>' +
'    <button class="close-flyout button-clear button-icononly">' +
'      <i class="fas fa-arrow-alt-to-right">'
  ;
  const content_html =
'    <div class="panel-content panel-columns sortable-columns">' +
'      <div class="panel-column active">' +
'        <div class="column-header">' +
'          <div class="column-title panel-header">Visible Columns</div>' +
'        </div>' + 
'        <div class="column-content">' +
'          <ul id="visible-columns" class="manage-columns-list sortable-columns-list">' +
'          </ul>' +
'        </div>' +
'      </div>' +
'      <div class="panel-column">' +
'        <div class="column-header">' +
'          <div class="column-title panel-header">Available Columns</div>' +
'        </div>' +
'        <div class="column-content">' +
'          <ul id="available-columns" class="sortable-columns-list manage-columns-list">'
  ;

  $(document).ready(function(){
    let $wrapper = $(wrapper_html);

    table.parent().on('click', ".select_button, .close-flyout", function(event){
      event.stopPropagation();
      event.stopImmediatePropagation();
      table.parent().find(".select_columns").toggleClass("open");
    });
    
    $(".manage-columns-list").sortable({
      items: "li:not(.unsortable)",
      connectWith: ".manage-columns-list",
      placeholder: "target-placeholder",
      sort: function(e, t) {
        t.item.addClass("dragging")
      },
      beforeStop: function(e, t) {
        t.item.removeClass("dragging")
      },
      update: function(e, t) {
	let id = t.item.closest('.function_bar').parent().find('table')[0].id;
	let columns = t.item.closest('.panel-columns').find('#visible-columns li').map(function() {return this.id;}).get().join();
	updatePage(id, 0, table.data('currentPageSize'), -1, false, {}, "", columns);
      }
    });
    
    $(window).on("load", function() {
      $(".sortable-columns .column-content").each(function() {
        var e = Math.round($(this).parent(".panel-column").outerHeight() - $(this).prev(".column-header").outerHeight());
        $(this).css("height", e);
      });
    });
    
    let $flyout = $(flyout_html);
    let $content = $(content_html);
    let $visible = $content.find('#visible-columns');
    let $available = $content.find('#available-columns');

    update_visible_available_columns(columns, current, $visible, $available);
    
    $flyout.append($content);
    $wrapper.append($flyout);

    table.parent().find(".function_bar").append($wrapper);
  });
}

function update_visible_available_columns(columns, current, $visible, $available) {
  let unmovable_above = true;
  let cols_copy = Object.assign({}, columns);

  $visible.empty();
  $available.empty();
  
  for (let col of current) {
    let name = cols_copy[col].name;
    if (cols_copy[col].unmovable) {
      if (unmovable_above) {
	classes = "unsortable rule-below";
	unmovable_above = false;
      } else {
	classes = "unsortable rule-above";
	unmovable_above = true;
      }
    } else {
      classes = "ui-sortable-handle";
    }
    $visible.append($('<li></li>', {"class": classes, "id": col}).text(name));
    delete cols_copy[col];
  }
  for (const col in cols_copy) {
    $available.append($('<li></li>', {"class": "ui-sortable-handle", "id": col}).text(cols_copy[col].name));
  }

}
    
    

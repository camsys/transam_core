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
'      <i class="fas fa-arrow-alt-to-right"/>' +
'    </button>' +
'  </header>' +
'  <div class="panel-links">' +
'    <div class="link-group">' + 
'      <button class="link-secondary button-clear restore-defaults"><i class="fal fa-undo link-icon restore-defaults"></i>Restore Defaults</button>' +
'    </div>' +
'    <div class="link-group">' +
// '      <button class="link-secondary button-clear trigger-flyout" data-target="table-filters"><i class="fal fa-filter link-icon"></i>Filter Data</button>' +
// '      <button class="link-secondary button-clear trigger-flyout" data-target="sort-columns"><span class="combo-sort-icon link-icon"><i class="fal fa-long-arrow-up"></i><i class="fal fa-long-arrow-down"></i></span></i>Sort Columns</button>' +
'    </div>' +
'  </div>'
  ;
	
  const content_html =
'    <div class="panel-content panel-columns sortable-columns">' +
'      <div class="panel-column active">' +
'        <div class="column-header">' +
'          <div class="column-title panel-header">Visible Columns</div>' +
'            <button class="link-secondary button-clear deselect-all">Deselect All<i class="fal fa-long-arrow-right link-icon link-icon-right"></i></button>' +
'            <label class="column-search formfield-wrap has-icon has-icon-left"><i class="fas fa-search"></i>' +
'              <input type="text" class="search formfield" placeholder="Search…">' +
'            </label>' +
'        </div>' + 
'        <div class="column-content">' +
'          <ul id="visible-columns" class="manage-columns-list sortable-columns-list">' +
'          </ul>' +
'        </div>' +
'      </div>' +
'      <div class="panel-column">' +
'        <div class="column-header">' +
'          <div class="column-title panel-header">Available Columns</div>' +
'            <button class="link-secondary button-clear select-all"><i class="fal fa-long-arrow-left link-icon"></i>Select All</button>' +
'            <label class="column-search formfield-wrap has-icon has-icon-left"><i class="fas fa-search"></i>' +
'              <input type="text" class="search formfield" placeholder="Search…">' +
'            </label>' +
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

    table.parent().on('click', ".restore-defaults", function(event){
      event.stopPropagation();
      event.stopImmediatePropagation();
      let id = table[0].id;
      let selected = window[id].default_selected;
      updateVisibleAvailableColumns(window[id].columns, selected,
				    table.parent().find('#visible-columns'), table.parent().find('#available-columns'));
      updatePage(id, 0, table.data('currentPageSize'), -1, false, {}, "", selected.join());
    });
    
    table.parent().on('click', ".deselect-all", function(event){
      event.stopPropagation();
      event.stopImmediatePropagation();
      table.parent().find('.target-placeholder').remove();
      let newItems = table.parent().find('#visible-columns li:not(.unsortable)');
      table.parent().find('#available-columns').prepend(newItems);
      let columns = table.parent().find('#visible-columns li').map(function() {return this.id;}).get().join();
      let id = table[0].id;

      table.parent().find('#visible-columns .rule-below').after($('<li></li>', {"class": "target-placeholder"}));
      updatePage(id, 0, table.data('currentPageSize'), -1, false, {}, "", columns);
    });

    table.parent().on('click', ".select-all", function(event){
      event.stopPropagation();
      event.stopImmediatePropagation();

      let newItems = table.parent().find('#available-columns li');
      table.parent().find('#visible-columns li:not(.unsortable)').last().after(newItems);
      table.parent().find('#visible-columns .target-placeholder').remove();
      table.parent().find('#available-columns').append($('<li></li>', {"class": "target-placeholder"}));
      let columns = table.parent().find('#visible-columns li').map(function() {return this.id;}).get().join();
      let id = table[0].id;

      updatePage(id, 0, table.data('currentPageSize'), -1, false, {}, "", columns);
    });
    
    let $flyout = $(flyout_html);
    let $content = $(content_html);
    let $visible = $content.find('#visible-columns');
    let $available = $content.find('#available-columns');
    let visibleCount = Object.keys(current).length;

    updateVisibleAvailableColumns(columns, current, $visible, $available);

    $flyout.append($content);
    $wrapper.append($flyout);

    table.parent().find(".function_bar").append($wrapper);

    if (table.is(':visible')) {
      updateColumnsFlyout(table.parent());
    }

    table.parent().find(".manage-columns-list").sortable({
      items: "li:not(.unsortable)",
      connectWith: ".manage-columns-list",
      placeholder: "target-placeholder",
      cursor: "grabbing",
      start: function(e, t) {
	t.item.closest('.sortable-columns').find('input.search').val('');
	t.item.closest('.sortable-columns').find('input.search').keyup();
      },
      sort: function(e, t) {
        t.item.addClass("dragging")
      },
      beforeStop: function(e, t) {
        t.item.removeClass("dragging")
      },
      update: function(e, t) {
	let id = t.item.closest('.function_bar').parent().find('table')[0].id;
	let columns = t.item.closest('.panel-columns').find('#visible-columns li:not(.target-placeholder)').map(function() {return this.id;}).get().join();
	if (t.item.closest('.panel-columns').find('#visible-columns .ui-sortable-handle').length > 0) {
	  t.item.closest('.panel-columns').find('#visible-columns .target-placeholder').remove();
	} else if (t.item.closest('.panel-columns').find('#visible-columns .target-placeholder').length < 1) {
	  t.item.closest('.panel-columns').find('#visible-columns .rule-below').after($('<li></li>', {"class": "target-placeholder"}));
	}
	if (t.item.closest('.panel-columns').find('#available-columns .ui-sortable-handle').length > 0) {
	  t.item.closest('.panel-columns').find('#available-columns .target-placeholder').remove();
	} else if (t.item.closest('.panel-columns').find('#available-columns .target-placeholder').length < 1) {
	  t.item.closest('.panel-columns').find('#available-columns').append($('<li></li>', {"class": "target-placeholder"}));
	}
	updatePage(id, 0, table.data('currentPageSize'), -1, false, {}, "", columns);
      }
    });

    table.parent().on('keyup', '.search', function(e) {
      let value = $(this).val().toLowerCase();
      $(this).closest('.panel-column').find('.manage-columns-list li').each(function() {
	$(this).css('display', '');
	if ($(this).text().toLowerCase().indexOf(value) < 0) {
	  $(this).css('display', 'none');
	}
      });
    });
  });
}

function updateVisibleAvailableColumns(columns, current, $visible, $available) {
  let unmovable_above = true;
  let unmovable_below = false;
  let has_movable = false;
  let cols_copy = Object.assign({}, columns);

  $visible.empty();
  $available.empty();

  // Assumes a single unmovable column at the top
  for (let col of current) {
    let name = cols_copy[col].name;
    if (cols_copy[col].unmovable) {
      if (unmovable_above) {
	classes = "unsortable rule-below";
	unmovable_above = false;
      } else if (unmovable_below) {
	classes = "unsortable";
      } else {
	if (!has_movable) {
	  // Add a placeholder
	  $visible.append($('<li></li>', {"class": "target-placeholder"}))
	}
	classes = "unsortable rule-above";
	unmovable_below = true;
      }
    } else {
      classes = "ui-sortable-handle";
      has_movable = true;
    }
    $visible.append($('<li></li>', {"class": classes, "id": col}).text(name));
    delete cols_copy[col];
  }
  for (const col in cols_copy) {
    $available.append($('<li></li>', {"class": "ui-sortable-handle", "id": col}).text(cols_copy[col].name));
  }
}

function updateColumnsFlyout(parent) {
  parent.find(".sortable-columns .column-content").each(function() {
    var e = Math.round($(this).parent(".panel-column").outerHeight() - $(this).prev(".column-header").outerHeight());
    $(this).css("height", e);
  });
}

    
    

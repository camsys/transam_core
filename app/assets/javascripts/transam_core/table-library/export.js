$(document).on('click', ".export_option", async function(event){
  event.stopPropagation();
  $(this).addClass('loading');
  const id = $(this).closest(".library-table").find("table").eq(0).attr('id');
  const href = await export_table(id, $(this).text().trim());
  if($(this).text().trim() === "csv") {
    $(this).append($('<a class="hidden-link">').attr({ 'download': "output.csv", 'href': href, 'target': '_blank' }));
  } else if($(this).text().trim() === "txt") {
    $(this).append($('<a class="hidden-link">').attr({ 'download': "output.txt", 'href': href, 'target': '_blank' }));
  } else if($(this).text().trim() === "excel") {
    $(this).append($('<a class="hidden-link">').attr({ 'download': "output.csv", 'href': href, 'target': '_blank' })); // TODO: THIS IS NOT AN EXCEL FILE, THIS IS A CSV. TO GET AN XLS OR XLSX FILE WE NEED TO GO BACK TO THE SERVER OR USE A LIBRARY. EXCEL CAN READ CSV. WEB APPLICATIONS GENERATING XLSX DOESN'T EXACTLY MAKE SENSE. 
  }
  let hidden = $(this).find(".hidden-link")[0];
  hidden.click()
  hidden.remove();


  $(this).closest('.export').eq(0).removeClass("open");
  $(this).removeClass('loading');

});

$(document).on('click', ".hidden-link", (e) => {
  e.stopPropagation();
});





async function export_table(id, type) {
  const table = $('#'+id);
  const side = $(table).data('side'); //Client Side or Server Side
  const url = $(table).data('url');
  const table_code = $(table).data('tableCode');
  const header = table.find("tr:has(th)").eq(0).find(".header-item:not(.header-checkbox)");
  let csv = "";
  for(let cell of header){
    csv = csv + $(cell).find(".header-text").text().replace(/,/g, '') + ",";
  }
  // Google Tag Manager
  window.dataLayer = window.dataLayer || [];
  event = {
    'event': 'export',
    'tableCode': table_code,
    'type': type,
    'selectedOnly': false,
    'sortColumn': '',
    'sortOrder': 'ascending'
  };

  csv = csv + '\n';
  let rows = [];
  if(side === "client") { // Client-Side Table


    if($('#' + id + '_export_checkbox').is(':checked')) { // Only export selected rows
      rows = table.find(".row-checked:has(td)");
      event['selectedOnly'] = true;
    } else { // Export All Rows
      rows = table.find("tr:has(td)");
    }
    
    for(let row of rows){
      let new_row = ""
      for(let c of $(row).find(".row-item")) {
        let new_value = "";
        if($(c).hasClass("action-column")) {
          continue;
        } else if($(c).hasClass("checkmark-column") || $(c).hasClass("x-column")) {
          new_value = (($(c).find(".cell-text i").css("visibility") == "visible")? "Yes,": "No,");
        } else {
          new_value =  $(c).find(".cell-text").text().replace(/(,|\r|\n|\r\n)/g, '') + ",";
        }
        new_row = new_row + new_value;
      }
      csv = csv + new_row + '\n';
    }    
  } else { // Server-Side Table Export
    if($('#' + id + '_export_checkbox').is(':checked') && !window[id].selectAll) { // if the header checkbox is selected then all of the rows should be exported, which is the same case as not checking the "selected only" option
      event['selectedOnly'] = true;
      let checked = window[id].checkedRows;
      for(let row in checked) {
        for(let cell in checked[row]) {
          csv = csv + checked[row][cell].toString().replace(/,/g, '') + ",";
        }
        csv = csv + '\n';
      }
    } else {
      let data = {"table_code":table_code, 'page': 0, 'page_size': 22222, 'search': $('#'+id).siblings(".function_bar").find(".searchbar").val()}; // 22222 page size is meant to include all of the rows, ugly hack
      const params = $(table).data('params');
      for(let x in params){ data[x] = params[x]; }
      sorted_column = $(table).find(".header-item.sorted").eq(0);
      data['sort_column'] = $(sorted_column).attr("code");
      data['sort_order'] = ($(sorted_column).hasClass("sorted-desc")) ? "descending": "ascending";
      event['sortColumn'] = data['sort_column'];
      event['sortOrder'] = data['sort_order'];

      await $.ajax({
        type: "GET",
        contentType: "application/json; charset=utf-8",
        url: url,
        data : data,
        dataType: "json",
        success: (d, s, xhr)=> {
          response = d;
        },
        complete: (jqXHR, status) => {
          if(status == 'success') {
            r = response;
            try {
              r_columns = Object.keys(r['rows'][0]);
            } catch(e) {
              console.log("empty table?", e);
              return;
            }
            for(let [index,obj] of r['rows'].entries()) {
                if(window[id].stickySelect && window[id].uncheckedRows[index]){
                  continue;
                }
                let columns = Object.keys(obj);
                for(let col of columns) {
                  try {
                    csv = csv + (""+obj[col]["data"]).toString().replace(/,/g, '') + ",";
                  } catch (e) {
                    console.log(e);
                  }
                }
                csv = csv + '\n';
            }
          }
        },
        error: function (e){
            console.log(e);
            return -1;
        }
      });
    }
  }
  window.dataLayer.push(event);
  
  let csvData = "";
  if(type === "csv") {
    csvData = 'data:application/csv;charset=utf-8,' + encodeURIComponent(csv);
    return csvData;
  } else if(type === "txt") {
    csvData = 'data:application/txt;charset=utf-8,' + encodeURIComponent(csv);
    return csvData;
  } else if(type === "excel") {
    csvData = 'data:application/csv;charset=utf-8,' + encodeURIComponent(csv); // TODO: SEE EARLIER TODO
    return csvData;
  }
  
}

function init_export(id, types) {
  const table = $('#'+id);
  $(document).ready(function(){
    let wrapper = $('<div class="export">');
    let button = $('<button class=" function_button export_button" title="Export">').append('<i class="fas fa-file-download button-label button-icon" aria-hidden="true">');
    let options = $('<div class="export_options">');
    let selected_rows_checkbox = $('<div class="selected_rows_checkbox_wrapper">').append($('<input type="checkbox" class="selected_rows_checkbox" id="' + id + '_export_checkbox">')).append($('<label class="selected_rows_checkbox_label" for="' + id + '_export_checkbox">').text("Selected Rows Only"));
    $(document).on('click', ".export", function(event){
      event.stopPropagation();
      event.stopImmediatePropagation();
      $(this).toggleClass("open");
    });
    options.append($('<div class="export_label">').text("Export Data"));
    options.append(selected_rows_checkbox);
    for(let type of types){
      // include href to make focusable
      options.append($('<a class="export_option" href="javascript:;">').text(type).prepend('<i class="fas fa-file-download button-label button-icon" aria-hidden="true">'));
    }
    wrapper.append(button).append(options);
    table.parent().find(".function_bar").append(wrapper);
    
  });
}

  
// close on click away
$(document).on('click focus', '*', function(e){
  if($(e.target).closest('.open').length === 0) {
    $('.open').removeClass('open');
  }
  if($(e.target).closest(".flyout_button_trigger").length == 0 && $(e.target).closest('.flyout_wrapper').length === 0) {
    if(!e.target.classList.contains("remove")) {
      $('.flyout_wrapper').addClass("close");
    }
  }
});


$(document).on('click', '.selected_rows_checkbox,.selected_rows_checkbox_label', function(e){
  e.stopImmediatePropagation();
});

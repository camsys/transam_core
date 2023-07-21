$("table[use]").ready(()=>{

    $("table[use]").each(async function(i, value){

        $(this).addClass('loading');
        if($(value).attr('use') == 'true'){
            const id = $(value).attr('id');
            const table_code = $(value).data('tableCode');
            const side = $(value).data('side');
            const export_types = $(value).data('export').replace(/[\[\]']+/g,'').split(',');
            let curPage = $(value).data('currentPage');
            let curPageSize = $(value).data('currentPageSize');
            const pageSizes = $(value).data('pageSizes').split(',');
            const columns = $(value).data('columns');
            let selected_columns = $(value).data('selectedColumns').split(',');
            const col_names = {};
            const col_types = {};
            const col_widths = {};
            const col_sortable = {};
            for(let col of Object.keys(columns)){
                let x = columns[col];
                col_names[col] = x["name"];
                col_types[col] = x["type"];
                col_widths[col] = x["width"];
                col_sortable[col] = x["sortable"];
            }
	        window[id].columns = columns;
            window[id].col_names = col_names;
            window[id].col_types = col_types;
            window[id].col_widths = col_widths;
            window[id].col_sortable = col_sortable;
            window[id].col_selected = selected_columns;
            window[id].default_selected = selected_columns;
            window[id].selectAll = false;
            window[id].stickySelect = false; // client side library managing selections for server side data... no... i'm serious...
	    window[id].table_data = []
	    window[id].table_timeouts = new Set();

            const search = $(value).data('search');
            const url = $(value).data('url');
            const sort = $(value).data('sort');
            let sort_params = [];
            await $.ajax({
                type: "GET",
                contentType: "application/json; charset=utf-8",
                data:{"table_code":table_code},
                url: "/users/table_preferences?",
                success: function(data){
                  if(data) {
                    sort_params = data["sort"];
                    //     .reduce((obj,item)=>{
                    //     key=Object.keys(item)[0];
                    //     obj[key]=item[key];return obj;
                    // }, {});
                  }
                },
                dataType: "json"
            });
            window[id].sort_params = sort_params;
            let params = $(value).data('params');

            initialize(id, columns, selected_columns, curPage, curPageSize, pageSizes, side, url, params, sort, export_types);

            if(search == 'client') {
                addSearch(id);
            } else if(search === 'server') {
                addSearchServer(id);
            }

	  // Conditionally add only for appropriate tables
	  if (['bus', 'rail_car', 'ferry', 'other_passenger_vehicle',
	       'service_vehicle', 'capital_equipment',
	       'admin_facility', 'maintenance_facility', 'passenger_facility', 'parking_facility',
	       'track', 'guideway', 'power_signal'].includes(table_code)) {
	    let disposedCheckbox = $("<div>").addClass("include_disposed")
		.append($('<input type="checkbox" id="disposed_checkbox">'))
		.append($('<label class="disposed_checkbox_label" for="disposed_checkbox">').html("&nbsp;Include Disposed"));
	    $(disposedCheckbox).on("click", function(){
	      let include_disposed = $(this).find('#disposed_checkbox').is(':checked');
	      let table = $(this).closest('.library-table').find("table").eq(0);
	      let params = table.data('params') || {};
	      let id = table.attr('id');

	      params['include_disposed'] = include_disposed;
	      table.data('params', params);

	      updatePage_help(id, table.data("currentPage"), table.data('currentPageSize'));
	    });

	    $('#'+id).parent().find(".function_bar").append(disposedCheckbox);
	  }
        }
    });

    $(document).on('click', '.cell-checkbox input[type="checkbox"]:checked', function(e){
        $(this.parentNode.parentNode.parentNode).toggleClass("row-checked");
        const table = $(this).closest('.library-table').find("table").eq(0);
        const id = $(table).attr('id');
        // $('#' + id + " .header-checkbox").prop('checked', false); // case shouldn't be needed, omitted for efficiency
        if(!window[id].checkedRows){
            window[id].checkedRows = {};
        }
        let flat = {};
        const row = $(this).closest(".table-row");
        const columns = $(table).find(".header-item:not(.header-checkbox) .header-text");
        $(row).find(".cell-text").each(function(index){
            flat[$(columns[index]).text()] = $(this).text();
        });
        window[id].checkedRows[row.attr("index")] = flat;


        if(!window[id].uncheckedRows){
            window[id].uncheckedRows = {};
        } else {
            delete window[id].uncheckedRows[$(this).closest(".table-row").attr("index")];
        }
    });

    $(document).on('click', '.cell-checkbox input[type="checkbox"]:not(:checked)', function(e){
        $(this.parentNode.parentNode.parentNode).toggleClass("row-checked");
        const table = $(this).closest('.library-table').find("table").eq(0);
        const id = $(table).attr('id');
        
        if(!window[id].checkedRows){
            window[id].checkedRows = {};
        } else {
            const row = $(this).closest(".table-row");
            delete window[id].checkedRows[row.attr("index")];
        }

        if(!window[id].uncheckedRows){
            window[id].uncheckedRows = {};
        }
        window[id].uncheckedRows[$(this).closest(".table-row").attr("index")] = true;

        
        window[id].stickySelect = window[id].selectAll;
        $('#' + id + " .header-checkbox").prop('checked', false);
        
        // if($(table).data('side') === "server") {
            
        // }
    });

    $(document).on('click', '.header-checkbox input[type="checkbox"]:checked', function(){
        let table = $(this).closest('.library-table').find("table").eq(0);
        const id = $(table).attr('id');
        window[id].selectAll = true;
        window[id].stickySelect = false;
        table.find('.table-row:not(.row-checked) .cell-checkbox input').click();
        window[id].uncheckedRows = {};
    });
    $(document).on('click', '.header-checkbox input[type="checkbox"]:not(:checked)', function(){
        let table = $(this).closest('.library-table').find("table").eq(0);
        const id = $(table).attr('id');
        window[id].selectAll = false;
        window[id].stickySelect = false;
        table.find('.table-row.row-checked .cell-checkbox input').click();
        window[id].checkedRows = {};
    });
    // $(document).on('click', '.header-checkbox input[type="checkbox"]:checked', function(){
    //     let table = $(this).closest('.library-table').find("table").eq(0);
    //     table.find('.table-row:not(.row-checked))').each(function(){
    //         $(this).addClass("row-checked").find(".cell-checkbox label input").prop("checked", true);
    //         let flat = {};
    //         const row = $(this);
    //         const columns = $(table).find(".header-item:not(.header-checkbox) .header-text");
    //         $(row).find(".cell-text").each(function(index){
    //             flat[$(columns[index]).text()] = $(this).text();
    //         });
    //         window[id].checkedRows[row.attr("index")] = flat;
    //     });
    // });
    // $(document).on('click', '.header-checkbox input[type="checkbox"]:not(:checked)', function(){
    //     let table = $(this).closest('.library-table').find("table").eq(0);
    //     table.find('.table-row.row-checked').removeClass("row-checked").find(".cell-checkbox label input").prop("checked", false);
    // });
    $(".custom-drilldown-content").hover((e)=>{e.stopPropagation();});
});


async function initialize(id, columns, selected, curPage, curPageSize, pageSizes, side, url, params, sort, export_types) {
    if($('#'+id).parent().find('.function_bar').length === 0) {
        $('#'+id).parent().prepend($('<div class="function_bar">'));
    }
    $('#'+id).append($("<tbody>"));
    if(side === 'server') {
        pagination(id, curPage, curPageSize, pageSizes, -1);
        init_export(id, export_types);
        init_columns(id, columns, selected);
        // clear_row_queue(id);
        updatePage(id, curPage, curPageSize, -1, false, params);
        applyIcons($('#'+id).find('.header'));
        return;
    }
    
    updateHeader(id, selected, sort);
    pagination(id, curPage, curPageSize, pageSizes);
    init_export(id, export_types);
    init_columns(id, columns, selected);
    clear_row_queue(id);
    updatePage_help(id, curPage, curPageSize);
    clear_aux_queue(id);
    client_sort($('#'+id).find('.header-item[code="'+ Object.keys(window[id].sort_params[0])[0] +'"]'));

    

}


function updateHeader(id, selected, sort){
  const cols = window[id].col_names;
  const col_ts = window[id].col_types;
  const col_ws = window[id].col_widths;
  const col_sortable = window[id].col_sortable;
  let sort_params = window[id].sort_params;
  if($('#'+id + " thead").length > 0){
    $('#'+id + " thead").remove();
    $('#'+id + " colgroup").remove();
  }
    let table = $("#" + id);
    let header = $('<tr>').addClass("header");
    let colgroup = $('<colgroup>');
    header.append($('<th>').addClass("header-item header-checkbox").append($('<label>').append($('<input>').attr('type', "checkbox").addClass("header-checkbox").prop('checked', window[id].selectAll && !window[id].stickySelect)).append($('<span>').addClass('fa-stack').append($('<i class="fad fa-square fa-stack-1x" aria-hidden="true"></i>')).append($('<i class="fas fa-check-square fa-stack-1x" aria-hidden="true"></i>')))));
    colgroup.append($('<col>').addClass('col-item').attr('style', 'width: 32px'));
    // let sort_select = $('<div>');
    for (let col of selected){
        try {
            header.append($('<th>').addClass('header-item').attr("code", col).attr("type", col_ts[col])//.attr("order", sort_params[col])
                    .append($('<div>').addClass('header-content')
                      .append($('<div>').addClass('header-text').text(cols[col].toString()))
                      .append((col_sortable[col]!=="False")?$('<div>').addClass('header-icons'):$('<div>').addClass("not-sortable"))));

            colgroup.append(
                $('<col>').addClass('col-item').css("width", col_ws[col]));
            $("#" + id + " .table-row>:nth-child(" +  ($("[type|='" + col_ts[col] + "']").eq(0).index()+1) + ")").addClass(col_ts[col]);

        } catch (e) {
            try {
                header.append($('<th>').addClass('header-item').attr("type", "")
                    .append($('<div>').addClass('header-content').text(cols[col].toString())
                      .append($('<div>').addClass('header-text').text(cols[col].toString()))
                      .append((col_sortable[col]!=="False")?$('<div>').addClass('header-icons'):$('<div>').addClass("not-sortable"))));  
            } catch(e) {
                console.log("Bad column name in selected?", e);
                continue;
            }
            
        }
        // if (sort === "client") {
        //     // sort_select.append($('<form id='+col+'_select>').text(cols[col].toString())
        //     //     .append($('<input id="'+col+'_asc">').attr("type", "radio").attr("form", col+'_select').attr("name", col+'_select')).append($('<label>').attr("for",col+"_asc").text("Ascending"))
        //     //     .append($('<input id="'+col+'_desc">').attr("type", "radio").attr("form", col+'_select').attr("name", col+'_select')).append($('<label>').attr("for",col+"_desc").text("Descending")));
        // }



        // header.append($('<th>').addClass('header-item').attr('col_type', col_ts[i].toString()).append($('<div>').addClass('header-content').text(cols[i].toString())));
        // colgroup.append($('<col>').addClass('col-item').attr('style', 'width: '+ col_ws[i].toString()));
    }
    if(sort_params.length > 0){
        let col = Object.keys(sort_params[0])[0];
        header.find('.header-item[code='+ col +']').attr("order", sort_params[0][col]);
    }
    applyIcons(header);
    table.prepend($('<thead>').append(header)).prepend(colgroup);
    // table.parent().append(sort_select);
}

function applyIcons(header) {
    $(header).children().each((i,cell)=>{
        if ($(cell).attr("order") === "ascending") {
          $(cell).removeClass("sorted-desc").addClass("sorted sorted-asc");
          $(cell).find(".header-icons").empty().append($('<span>').addClass("sort icon")
                                  .append($('<i>').addClass("fad fa-sort-amount-down-alt sorted asc"))
                                  .append($('<i>').addClass("fad fa-sort-amount-up sorted desc")));
        } else if ($(cell).attr("order") === "descending") {
          $(cell).removeClass("sorted-asc").addClass("sorted sorted-desc");
          $(cell).find(".header-icons").empty().append($('<span>').addClass("sort icon")
                                  .append($('<i>').addClass("fad fa-sort-amount-down-alt sorted asc"))
                                  .append($('<i>').addClass("fad fa-sort-amount-up sorted desc")));
        } else {
          $(cell).removeClass("sorted sorted-desc sorted-asc").addClass("unsorted");
          $(cell).find(".header-icons").empty().append($('<span>').addClass("sort icon")
                                  .append($('<i>').addClass("fas fa-long-arrow-alt-up"))
                                  .append($('<i>').addClass("fas fa-long-arrow-alt-down")));
        }
    });


}

function clear_row_queue(id){
    if(typeof window[id].table_rows !== "undefined" && window[id].table_rows.length > 0)
        for(let f of window[id].table_rows) {f();}
}


function add_row(id, vals, index) {
    try{
        window[id].table_rows.push(function(){
            add_row_exec(id, vals, index);
        });
    } catch (e) {
        window[id].table_rows = [];
        window[id].table_rows.push(function(){
            add_row_exec(id, vals, index);
        });
    }
    
}





function add_row_exec(id, vals, index) {
    window[id].table_data.push(vals); // Save for use by column selection

  if(!($('#' + id + " .table-row[index=" + index + ']').length > 0)){
    let index_str = index.toString();
    let row = $('<tr>').addClass('table-row').attr("index", index.toString()).attr("id", index_str);
        let checkbox = $('<td>').addClass("cell-checkbox").append($('<label>').append($('<input>').attr('type', "checkbox")).append($('<span>').addClass('fa-stack').append($('<i class="fad fa-square fa-stack-1x" aria-hidden="true"></i>')).append($('<i class="fas fa-check-square fa-stack-1x" aria-hidden="true"></i>'))));
        
        // i've accepted that for the forseeable future we're using window variables
        let s_cols = window[id].col_selected;
        let col_names = window[id].col_names;
        let col_types = window[id].col_types;

        addCellsForData(row, vals, s_cols, col_types, false);

        if(    (window[id].checkedRows && window[id].checkedRows[index]) && (window[id].selectAll && window[id].stickySelect)   // sticky select on
            || (window[id].selectAll && !window[id].stickySelect)                                                               // sticky select off, select all on
            || (!window[id].selectAll && (window[id].checkedRows && window[id].checkedRows[index]))) {                          // select all off
                row.addClass("row-checked");
                checkbox.find("label input").prop("checked", true);
                if(!window[id].checkedRows){
                    window[id].checkedRows = {};
                }
                if(!window[id].checkedRows[index]){
                    let flat = {};
                    const columns = $('#'+id).find(".header-item:not(.header-checkbox) .header-text");
                    $(row).find(".cell-text").each(function(index){
                        flat[$(columns[index]).text()] = $(this).text();
                    });
                    window[id].checkedRows[index] = flat;
                }
                
        }
        row.prepend(checkbox);
        // messy way of inserting each row at correct position
        let lt = $('#' + id + " .table-row").filter(function(){
            return $(this).attr("index") < index;
        });
        (lt.length > 0) ? row.insertAfter(lt[lt.length-1]) : $('#' + id).prepend(row);
    } else {
        // 
    }

}


async function add_aux_queue(id, func){
    if(!window[id].aux_queue) {
        window[id].aux_queue = [];
    }
    window[id].aux_queue.push(function(){
        func();
    });
}

function clear_aux_queue(id){
    if(typeof window[id].aux_queue !== "undefined" && window[id].aux_queue.length > 0)
        for(let f of window[id].aux_queue) {f();}
}

// Create table cells and add to table row
function addCellsForData(row, data, selectedCols, colTypes, skipActions=true) {
  for (let key of selectedCols) {
    key = key.trim();
    if (skipActions && (colTypes[key] == "action-column")) continue;
    let text = "";
    try {
      text = ""+data[key].replace(/\>https?\:\/\//i, ">"); // removes http(s)
    } catch(e) {
      try {
        text = data[key];
      }
      catch (e) {
        text = ""+data[key];
      }
    }
    let cellText = $('<div>').addClass('cell-text').html(text)
    if ((typeof text !== 'undefined')
	&& (!isNaN(text) // check if its a number
	    // check if text is a percentage, currency value, year range, date // separated for clarity
            || (!isNaN(text.replace(/\d+%/g,'').replace(/[$,]+/g,'').replace(/[-]+/g,'').replace(/[\/]+/g,''))))) {
	cellText = cellText.addClass('numeric');
      }
    row.append($('<td>').addClass("row-item").addClass(colTypes[key]).append(cellText));
  }
}

// Recreate table cells based on selected columns and stashed row data
function updateTable(id, selectedCols) {
  let colTypes = window[id].col_types
  // First update visible rows
  $('tbody > tr:visible').each(function () {
    let data = window[id].table_data[this.id];
    updateRow(data, $(this), selectedCols, colTypes);
  });
  setTimeout(function () { updateHiddenRows(id, selectedCols, colTypes); }, 100);
}

function updateHiddenRows(id, selectedCols, colTypes) {
  // Clear out any existing timeouts to prevent race conditions and improve performance
  let timeouts = window[id].table_timeouts;
  timeouts.forEach(function (timeout) { clearTimeout(timeout); });
  timeouts.clear();
  $('tbody > tr:hidden').each(function () {
    let data = window[id].table_data[this.id];
    let row = $(this);
    timeouts.add(setTimeout(function () { updateRow(data, row, selectedCols, colTypes); }, 1));
  });
}

// Handle action column and removing old data cells
function updateRow(data, row, selectedCols, colTypes) {
  let action_td = row.find('td.action-column').detach();

  row.find('td.row-item').remove();
  addCellsForData(row, data, selectedCols, colTypes);
  row.append(action_td);
}
  
async function serverSide(id, url, curPage, curPageSize, params, search="", sort_by={}) {
        $('#'+id).addClass('loading');
        let response = {};
        let data = {'page': curPage, 'page_size': curPageSize, 'search': search};
        if(!$.isEmptyObject(sort_by)) { // assumes 1 column
            data['sort_column'] = Object.keys(sort_by[0])[0];
            data['sort_order'] = Object.values(sort_by[0])[0]; 
            $('#'+id).find('.table-row').remove(); // clear out table
        }
        for(let x in params){ data[x] = params[x]; }
        await $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: url,
            data : data,
            dataType: "json",
            beforeSend:(xhr) => {
                if(window[id].activeRequest && window[id].activeRequest.readyState !== 4) {
                    window[id].activeRequest.abort();
                }
                window[id].activeRequest = xhr;
            },
            success: (d, s, xhr)=> {
                response = d;
            },
            complete: (jqXHR, status) => {
                if(status == 'success') {
                    r = response;
                    try {
                      r_columns = Object.keys(r['rows'][0]); 
                      window[id].col_selected = r_columns;
                      updateHeader(id, r_columns, "server");
                    } 
                    catch (e) {
                    updateHeader(id, window[id].col_selected, "server");
                    }
                    for(let [index,obj] of r['rows'].entries()) {
                        let row = {};
                        let columns = Object.keys(obj);
                        for(let col of columns) {
                            if(!obj[col]["url"] || 0 === obj[col]["url"].trim().length) {
			        if(obj[col]["data"] !== null) {
                                    row[col] = obj[col]["data"].toString();
			        }
                            } else {
                                row[col] = "<a href='" + obj[col]["url"] + "'>" + obj[col]["data"] + "</a>";
                            }
                        }
                        add_row_exec(id, row, (curPage * curPageSize)+index);
                    }
                }
            },
            error: function (e){
                console.log(e);
                return -1;
            }
        });



        return response['count'];
}


























// function server_side_exec(id, r, curPage, curPageSize) 


// statusCode: {
//     500: async function(){
//         console.log("handling 500");
//         // retry without sorting
//         data['sort_column'] = "asset_id"; // what sould the default be? 
//         data['sort_order'] = "ascending"; //  how would we determine a good guess?
//         $('#'+id+' .header-item').attr("order", "");
//         await $.ajax({
//             type: "GET",
//             contentType: "application/json; charset=utf-8",
//             url: url,
//             data : data,
//             dataType: "json",
//             complete: (r) => {
//                 response = r;
//                 try {
//                   r_columns = Object.keys(r['rows'][0]); 
//                   window[id].col_selected = r_columns;
//                   updateHeader(id, r_columns, "server");
//                 } catch (e) {
//                   updateHeader(id, window[id].col_selected, "server");
//                 }
//                 for(let [index,obj] of r['rows'].entries()) {
//                     let row = {};
//                     let columns = Object.keys(obj);
//                     for(let col of columns) {
//                         if(!obj[col]["url"] || 0 === obj[col]["url"].trim().length) {
//                             row[col] = obj[col]["data"];
//                         } else {
//                             row[col] = "<a href='" + obj[col]["url"] + "'>" + obj[col]["data"] + "</a>";
//                         }
//                     }
//                     add_row_exec(id, row, (curPage * curPageSize)+index);
//                 }
//             },
//             error: function (){
//             }
//         });
//     }
// },

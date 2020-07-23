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
            for(let col of Object.keys(columns)){
                let x = columns[col];
                col_names[col] = x["name"];
                col_types[col] = x["type"];
                col_widths[col] = x["width"];
            }
	  console.log(columns);
	    window[id].columns = columns;
            window[id].col_names = col_names;
            window[id].col_types = col_types;
            window[id].col_widths = col_widths;
            window[id].col_selected = selected_columns;
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
        }
    });

    $(document).on('click', '.cell-checkbox input[type="checkbox"]:checked', function(e){
        $(this.parentNode.parentNode.parentNode).toggleClass("row-checked");
        const table = $(this).closest('.library-table').find("table").eq(0);
        const id = $(table).attr('id');
        if($(table).data('side') === "server") {
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
        }
    });

    $(document).on('click', '.cell-checkbox input[type="checkbox"]:not(:checked)', function(e){
        $(this.parentNode.parentNode.parentNode).toggleClass("row-checked");
        const table = $(this).closest('.library-table').find("table").eq(0);
        const id = $(table).attr('id');
        if($(table).data('side') === "server") {
            if(!window[id].checkedRows){
                window[id].checkedRows = {};
            } else {
                const row = $(this).closest(".table-row");
                delete window[id].checkedRows[row.attr("index")];
            }
        }
    });

    // $(document).on('click', '.header-checkbox input[type="checkbox"]', function(){
    //     let table = $(this).closest('.library-table').find("table").eq(0);
    //     table.find('.cell-checkbox input').click();
    // });
    $(document).on('click', '.header-checkbox input[type="checkbox"]:checked', function(){
        let table = $(this).closest('.library-table').find("table").eq(0);
        table.find('.table-row').addClass("row-checked").find(".cell-checkbox label input").prop( "checked", true);
    });
    $(document).on('click', '.header-checkbox input[type="checkbox"]:not(:checked)', function(){
        let table = $(this).closest('.library-table').find("table").eq(0);
        table.find('.table-row').removeClass("row-checked").find(".cell-checkbox label input").prop( "checked", false);
    });
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
    clear_row_queue(id);
    updatePage_help(id, curPage, curPageSize);
    clear_aux_queue(id);
    client_sort($('#'+id).find('.header-item[code="'+ Object.keys(window[id].sort_params[0])[0] +'"]'));

    

}


function updateHeader(id, selected, sort){
  let cols = window[id].col_names;
  let col_ts = window[id].col_types;
  let col_ws = window[id].col_widths;
  let sort_params = window[id].sort_params;
  if($('#'+id + " thead").length > 0){
    $('#'+id + " thead").remove();
    $('#'+id + " colgroup").remove();
  }
    let table = $("#" + id);
    let header = $('<tr>').addClass("header");
    let colgroup = $('<colgroup>');
    header.append($('<th>').addClass("header-item header-checkbox").append($('<label>').append($('<input>').attr('type', "checkbox").addClass("header-checkbox")).append($('<span>').addClass('fa-stack').append($('<i class="fad fa-square fa-stack-1x" aria-hidden="true"></i>')).append($('<i class="fas fa-check-square fa-stack-1x" aria-hidden="true"></i>')))));
    colgroup.append($('<col>').addClass('col-item').attr('style', 'width: 32px'));
    // let sort_select = $('<div>');
    for (let col of selected){
        try {
            header.append($('<th>').addClass('header-item').attr("code", col).attr("type", col_ts[col])//.attr("order", sort_params[col])
                    .append($('<div>').addClass('header-content')
                      .append($('<div>').addClass('header-text').text(cols[col].toString()))
                      .append($('<div>').addClass('header-icons'))));

            colgroup.append(
                $('<col>').addClass('col-item').css("width", col_ws[col]));
            $("#" + id + " .table-row>:nth-child(" +  ($("[type|='" + col_ts[col] + "']").eq(0).index()+1) + ")").addClass(col_ts[col]);

        } catch (e) {
            try {
                header.append($('<th>').addClass('header-item').attr("type", "")
                    .append($('<div>').addClass('header-content').text(cols[col].toString())
                      .append($('<div>').addClass('header-text').text(cols[col].toString()))
                      .append($('<div>').addClass('header-icons'))));  
            } catch(e) {
                console.error("Bad column name in selected?", e);
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
    if(!($('#' + id + " .table-row[index=" + index + ']').length > 0)){
        let row = $('<tr>').addClass('table-row').attr("index", index.toString());
        let checkbox = $('<td>').addClass("cell-checkbox").append($('<label>').append($('<input>').attr('type', "checkbox")).append($('<span>').addClass('fa-stack').append($('<i class="fad fa-square fa-stack-1x" aria-hidden="true"></i>')).append($('<i class="fas fa-check-square fa-stack-1x" aria-hidden="true"></i>'))));
        if(window[id].checkedRows && window[id].checkedRows[index]) {
            row.addClass("row-checked");
            checkbox.find("label input").prop( "checked", true);
        } 
        row.append(checkbox);
        // i've accepted that for the forseeable future we're using window variables
        let s_cols = window[id].col_selected;
        let col_names = window[id].col_names;
        let col_types = window[id].col_types;
        
        for(let key of s_cols){
            // let i = col_names.indexOf(key.trim());
            row.append($('<td>').addClass("row-item").addClass(col_types[key.trim()]).append($('<div>').addClass('cell-text').html(vals[key.trim()])));
            //$('#'+id+" .header-item:nth-child(" + col_types[i] + ")").attr("type")
        }
        // messy way of inserting each row at correct position
        let lt = $('#' + id + " .table-row").filter(function(){
            return $(this).attr("index") < index;
        });
        (lt.length > 0) ? row.insertAfter(lt[lt.length-1]) : $('#' + id).prepend(row);
    } else {
        
    }

}


async function add_aux_queue(id, func){
    try{
        window[id].aux_queue.push(function(){
            func();
        });
    } catch (e) {
        window[id].aux_queue = [];
        window[id].aux_queue.push(function(){
            func();
        });
    }
}

function clear_aux_queue(id){
    if(typeof window[id].aux_queue !== "undefined" && window[id].aux_queue.length > 0)
        for(let f of window[id].aux_queue) {f();}
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
                                row[col] = obj[col]["data"];
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

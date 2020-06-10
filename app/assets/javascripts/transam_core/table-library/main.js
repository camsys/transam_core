$("table[use]").ready(()=>{

    $("table[use]").each(async function(i, value){
        if($(value).attr('use') == 'true'){
            const id = $(value).attr('id');
            const table_code = $(value).data('tableCode');
            let side = $(value).data('side');
            let curPage = $(value).data('currentPage');
            let curPageSize = $(value).data('currentPageSize');
            let pageSizes = $(value).data('pageSizes').split(',');
            let columns = $(value).data('columns');
            let selected_columns = $(value).data('selectedColumns').split(',');
            let col_names = {};
            let col_types = {};
            let col_widths = {};
            for(let col of Object.keys(columns)){
                let x = columns[col];
                col_names[col] = x["name"];
                col_types[col] = x["type"];
                col_widths[col] = x["width"];
            }
            window[id].col_names = col_names;
            window[id].col_types = col_types;
            window[id].col_widths = col_widths;
            window[id].col_selected = selected_columns;
            let search = $(value).data('search');
            let url = $(value).data('url');
            let sort = $(value).data('sort');
            let sort_params = {};
            await $.ajax({
                type: "GET",
                contentType: "application/json; charset=utf-8",
                data:{"table_code":table_code},
                url: "/users/table_preferences?table_code="+table_code,
                success: function(data){
                  if(data) {
                    sort_params = data["sort"].reduce((obj,item)=>{
                        key=Object.keys(item)[0];
                        obj[key]=item[key];return obj;
                    }, {});
                  }
                },
                dataType: "json"
            });
            window[id].sort_params = sort_params;
            let params = $(value).data('params');

            initialize(id, selected_columns, curPage, curPageSize, pageSizes, side, url, params, sort);

            if(search == 'client') {
                addSearch(id);
            } else if(search === 'server') {
                addSearchServer(id);
            }
        }
    });

    $(document).on('click', '.cell-checkbox input[type="checkbox"]', function(){
        $(this.parentNode.parentNode.parentNode).toggleClass("row-checked");
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


async function initialize(id, selected, curPage, curPageSize, pageSizes, side, url, params, sort) {
    $('#'+id).append($("<tbody>"));
    if(side === 'server') {
        let total = await serverSide(id, url, curPage, curPageSize, params);
        pagination(id, curPage, curPageSize, pageSizes, total);
        clear_row_queue(id);
        updatePage(id, curPage, curPageSize, total, false, params);
        return;
    }
    
    updateHeader(id, selected, sort);
    pagination(id, curPage, curPageSize, pageSizes);
    clear_row_queue(id);
    updatePage_help(id, curPage, curPageSize);
    clear_aux_queue(id);

}


function updateHeader(id, selected, sort){
  let cols = window[id].col_names;
  let col_ts = window[id].col_types;
  let col_ws = window[id].col_widths;
  let sort_params = window[id].sort_params;
  if($('#'+id + " thead").length < 1){
    let table = $("#" + id);
    let header = $('<tr>').addClass("header");
    let colgroup = $('<colgroup>');
    header.append($('<th>').addClass("header-item header-checkbox").append($('<label>').append($('<input>').attr('type', "checkbox").addClass("header-checkbox")).append($('<span>').addClass('fa-stack').append($('<i class="fad fa-square fa-stack-1x" aria-hidden="true"></i>')).append($('<i class="fas fa-check-square fa-stack-1x" aria-hidden="true"></i>')))));
    colgroup.append($('<col>').addClass('col-item').attr('style', 'width: 32px'));
    // let sort_select = $('<div>');
    for (let col of selected){
        try {
            
            header.append($('<th>').addClass('header-item').attr("type", col_ts[col]).attr("order", sort_params[col])
                    .append($('<div>').addClass('header-text').text(cols[col].toString())));

            colgroup.append(
                $('<col>').addClass('col-item').css("width", col_ws[col]));
            $("#" + id + " .table-row>:nth-child(" +  ($("[type|='" + col_ts[col] + "']").eq(0).index()+1) + ")").addClass(col_ts[col]);

        } catch (e) {
            header.append($('<th>').addClass('header-item').attr("type", "")
                    .append($('<div>').addClass('header-text').text(cols[col].toString())));  
        }
        if (sort === "client") {
            // sort_select.append($('<form id='+col+'_select>').text(cols[col].toString())
            //     .append($('<input id="'+col+'_asc">').attr("type", "radio").attr("form", col+'_select').attr("name", col+'_select')).append($('<label>').attr("for",col+"_asc").text("Ascending"))
            //     .append($('<input id="'+col+'_desc">').attr("type", "radio").attr("form", col+'_select').attr("name", col+'_select')).append($('<label>').attr("for",col+"_desc").text("Descending")));
        }



        // header.append($('<th>').addClass('header-item').attr('col_type', col_ts[i].toString()).append($('<div>').addClass('header-text').text(cols[i].toString())));
        // colgroup.append($('<col>').addClass('col-item').attr('style', 'width: '+ col_ws[i].toString()));
    }
    table.prepend($('<thead>').append(header)).prepend(colgroup);
    // table.parent().append(sort_select);
  } else {
    
  }
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
        row.append(checkbox);
        // TODO: TEMP, stilll working on this
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


async function serverSide(id, url, curPage, curPageSize, params, search="") {
        let response = {};
        let data = {'page': curPage, 'page_size': curPageSize, 'search': search};
        for(let x in params){ data[x] = params[x]; }
        await $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: url,
            data : data,
            dataType: "json",
            success: function (r) {
                response = r;
                try {
                  r_columns = Object.keys(r['rows'][0]); 
                  window[id].col_selected = r_columns;
                  updateHeader(id, r_columns, "server");
                } catch (e) {
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
            },
            error: function (){
            }
        });



        return response['count'];
}


$("table[use]").ready(()=>{

    $("table[use]").each((i, value)=>{
        if($(value).attr('use') == 'true'){
            const id = $(value).attr('id');
            let side = $(value).data('side');
            let curPage = $(value).data('currentPage');
            let curPageSize = $(value).data('currentPageSize');
            let pageSizes = $(value).data('pageSizes').split(',');
            let columns = $(value).data('columns').split(/\r?\n/);
            let selected_columns = $(value).data('selectedColumns').split(',');
            let col_names = [];
            let col_widths = [];
            let col_types = [];
            for(let col of columns){
                let x = col.split(',');
                col_names.push(x[0].trim());
                col_widths.push(x[1].trim());
                col_types.push(x[2].trim());
            }
            let search = $(value).data('search');
            let url = $(value).data('url');

            initialize(id, selected_columns, col_names, col_widths, col_types, curPage, curPageSize, pageSizes, side, url);

            if(search == 'client') {
                addSearch(id);
            } else if(search === 'server') {
                addSearchServer(id);
            }
        }
    });

    $(document).on('click', '.cell-checkbox input[type="checkbox"]', function(){
        $(this).closest('tr').toggleClass("row-checked");
    });

    $(document).on('click', '.header-checkbox input[type="checkbox"]', function(){
        let table = $(this).closest('.library-table').find("table").eq(0);
        table.find('.cell-checkbox input').click();
    });
});


async function initialize(id, selected, cols, col_widths, col_types, curPage, curPageSize, pageSizes, side, url) {
    $('#'+id).append($("<tbody>"));
    if(side === 'server') {
        // console.log("server");

        updateHeader(id, selected, cols, col_widths, col_types);
        let total = await serverSide(id, url, curPage, curPageSize);
        pagination(id, curPage, curPageSize, pageSizes, total);
        updatePage(id, curPage, curPageSize, total);
        return;
    }
    // console.log("client");
    updateHeader(id, selected, cols, col_widths, col_types);
    pagination(id, curPage, curPageSize, pageSizes);
    updatePage_help(id, curPage, curPageSize);

}


function updateHeader(id, selected, cols, col_ws, col_ts){
    let table = $("#" + id);
    let header = $('<tr>').addClass("header");
    let colgroup = $('<colgroup>');
    header.append($('<th>').addClass("header-item header-checkbox").append($('<label>').append($('<input>').attr('type', "checkbox").addClass("header-checkbox")).append($('<span>').addClass('fa-stack').append($('<i class="fad fa-square fa-stack-1x" aria-hidden="true"></i>')).append($('<i class="fas fa-check-square fa-stack-1x" aria-hidden="true"></i>')))));
    colgroup.append($('<col>').addClass('col-item').attr('style', 'width: 2.5em'));
    for (let i=0;i<selected.length;i++) {
        let colIndex = cols.indexOf(selected[i].toString().trim());
        header.append($('<th>').addClass('header-item').attr('col_type', col_ts[colIndex].toString()).append($('<div>').addClass('header-text').text(cols[colIndex].toString())));
        colgroup.append($('<col>').addClass('col-item').attr('style', 'width: '+ col_ws[colIndex].toString()));



        // header.append($('<th>').addClass('header-item').attr('col_type', col_ts[i].toString()).append($('<div>').addClass('header-text').text(cols[i].toString())));
        // colgroup.append($('<col>').addClass('col-item').attr('style', 'width: '+ col_ws[i].toString()));
    }
    table.prepend($('<thead>').append(header)).prepend(colgroup);
}

// assumes right number of columns
function add_row(id, vals, index) {
    if(!($('#' + id + " .table-row[at" + index + ']').length > 0)){
        // console.log("Add row: " + index);
        let row = $('<tr>').addClass('table-row').attr("at" + index.toString(), "true");
        let checkbox = $('<td>').addClass("cell-checkbox").append($('<label>').append($('<input>').attr('type', "checkbox")).append($('<span>').addClass('fa-stack').append($('<i class="fad fa-square fa-stack-1x" aria-hidden="true"></i>')).append($('<i class="fas fa-check-square fa-stack-1x" aria-hidden="true"></i>'))));
        row.append(checkbox);
        for (let val of vals) {
            row.append($('<td>').addClass("row-item").append($('<div>').addClass('cell-text').html(val)));
        }
        $('#' + id).append(row);
    }

}


async function serverSide(id, url, curPage, curPageSize, search="") {
        let response = {};
        let params = "";//"?order=asc&limit=" + curPageSize + "&offset=" + curPage + "&role=&show_active_only=active&search_text=" + search;
        await $.ajax({
            type: "GET",
            contentType: "application/json; charset=utf-8",
            url: url+params,
            data : {'page': curPage, 'page_size': curPageSize, 'search': search},
            dataType: "json",
            success: function (r) {
                response = r;
                // addRowFuncs[id](r['rows'], selectedCols, curPage, curPageSize);
                for(let [index,obj] of r['rows'].entries()) {
                    let row = [];
                    let columns = Object.keys(obj);
                    for(let col of columns) {
                        row.push(obj[col.trim()]);
                    }
                    add_row(id, row, (curPage * curPageSize)+index);
                }
            },
            error: function (){
            }
        });



        return response['count'];
}


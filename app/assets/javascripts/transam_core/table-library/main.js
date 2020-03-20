$("table[use]").ready(()=>{

    $("table[use]").each((i, value)=>{
        if($(value).attr('use') == 'true'){
            const id = $(value).attr('id');
            let pagination = $(value).data('pagination');
            let curPage = $(value).data('currentPage');
            let curPageSize = $(value).data('currentPageSize');
            let pageSizes = $(value).data('pageSizes').split(',');
            let columns = $(value).data('columns').split(/\r?\n/);
            let col_names = [];
            let col_widths = [];
            let col_types = [];
            for(let col of columns){
                let x = col.split(',');
                col_names.push(x[0]);
                col_widths.push(x[1]);
                col_types.push(x[2]);
            }
            let search = $(value).data('search');


            initialize(id, col_names, col_widths, col_types, curPage, curPageSize, pageSizes);

            if(search == 'client') {
                addSearch(id);
            }
        }
    });

});

function initialize(id, cols, col_widths, col_types, curPage, curPageSize, pageSizes) {
    updateHeader(id, cols, col_widths, col_types);
    pagination(id, curPage, curPageSize, pageSizes);

}


function updateHeader(id, cols, col_ws, col_ts){
    let table = $("#" + id);
    let header = $('<tr>').addClass("header");
    let colgroup = $('<colgroup>');
    header.append($('<th>').addClass("header-item header-checkbox").append($('<input>').addClass("header-checkbox").attr('type', "checkbox")));
    colgroup.append($('<col>').addClass('col-item').attr('style', 'width: 20px'));
    for (let i=0;i<cols.length;i++) {
        header.append($('<th>').addClass('header-item').attr('col_type', col_ts[i].toString()).append('<span>').addClass('header-text').text(cols[i].toString()));
        colgroup.append($('<col>').addClass('col-item').attr('style', 'width: '+ col_ws[i].toString()));
    }
    table.prepend($('<thead>').append(header)).prepend(colgroup);
}

// assumes right number of columns
function add_row(id, vals) {
    let row = $('<tr>').addClass('table-row');
    let checkbox = $('<td>').addClass("cell-checkbox").append($('<input>').attr('type', "checkbox"));
    row.append(checkbox);
    for(let val of vals) {
        row.append($('<td>').addClass("row-item").append($('<div>').addClass('cell-text').html(val)));
    }
    $('#'+id).append(row);
}



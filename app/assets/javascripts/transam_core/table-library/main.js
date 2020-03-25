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

    $(document).on('click', '.cell-checkbox input[type="checkbox"]', function(){
        $(this).closest('tr').toggleClass("row-checked");
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
    header.append($('<th>').addClass("header-item header-checkbox").append($('<label>').append($('<input>').attr('type', "checkbox").addClass("header-checkbox")).append($('<span>').addClass('fa-stack').append($('<i class="fad fa-square fa-stack-1x" aria-hidden="true"></i>')).append($('<i class="fas fa-check-square fa-stack-1x" aria-hidden="true"></i>')))));
    colgroup.append($('<col>').addClass('col-item').attr('style', 'width: 2.5em'));
    for (let i=0;i<cols.length;i++) {
        header.append($('<th>').addClass('header-item').attr('col_type', col_ts[i].toString()).append($('<div>').addClass('header-text').text(cols[i].toString())));
        colgroup.append($('<col>').addClass('col-item').attr('style', 'width: '+ col_ws[i].toString()));
    }
    table.prepend($('<thead>').append(header)).prepend(colgroup);
}

// assumes right number of columns
function add_row(id, vals) {
    let row = $('<tr>').addClass('table-row');
    let checkbox = $('<td>').addClass("cell-checkbox").append($('<label>').append($('<input>').attr('type', "checkbox")).append($('<span>').addClass('fa-stack').append($('<i class="fad fa-square fa-stack-1x" aria-hidden="true"></i>')).append($('<i class="fas fa-check-square fa-stack-1x" aria-hidden="true"></i>'))));
    row.append(checkbox);
    for(let val of vals) {
        row.append($('<td>').addClass("row-item").append($('<div>').addClass('cell-text').html(val)));
    }
    $('#'+id).append(row);
}



$(document).on('click', ".page-select-item:not(.search-result-page)", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);
    updatePage(table.attr('id'), $(this).index(), table.data('currentPageSize'));
});

$(document).on('click', ".page-select-item.search-result-page", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);
    updatePage(table.attr('id'), $(this).index(), table.data('currentPageSize'), true);
});

$(document).on('click', ".page-select-arrow-left", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);

    if ($(this).parent().find(".search-result-page").length > 0){
        updatePage(table.attr('id'), table.data("currentPage") - 1, table.data('currentPageSize'), true);
    } else {
        updatePage(table.attr('id'), table.data("currentPage") - 1, table.data('currentPageSize'));

    }
});

$(document).on('click', ".page-select-arrow-right", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);
    let cur = $(".page-selected").index();
    if ($(".search-result-page").length > 0){
        updatePage(table.attr('id'), table.data("currentPage") + 1, table.data('currentPageSize'), true);
    } else {
        updatePage(table.attr('id'), table.data("currentPage") + 1, table.data('currentPageSize'));

    }
});

$(document).on('change', ".page-size-dropdown", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);
    updatePage(table.attr('id'), 0, parseInt(this.value), table.parent().find("search-result-page").length > 0);
});




function pagination(id, curPage, curPageSize, pageSizes) {

    let total = $('#'+id).find('.table-row').length;

    let footer = $('<div>').addClass("pagination-wrapper");

    let sizeSelect = $('<div>').addClass("size-select");
    sizeSelect.text("Rows per page ");
    let dropdown = $('<select>').addClass("page-size-dropdown");
    for(let size of pageSizes) {
        dropdown.append($('<option>').text(size));
    }
    sizeSelect.append(dropdown);
    footer.append(sizeSelect);

    let pageStatus = $('<div>').addClass("page-status");
    updatePageStatus(pageStatus, curPage, curPageSize, total);
    footer.append(pageStatus);

    let pageSelectWrapper = $('<div>').addClass("page-select-wrapper");
    let pageSelect = $('<div>').addClass("page-select");
    pageSelectWrapper.append($('<div>').addClass("page-select-arrow-left").text("◄"));
    pageSelect.append($('<span>').addClass("page-select-item").text("1"));
    pageSelectWrapper.append(pageSelect);
    pageSelectWrapper.append($('<div>').addClass("page-select-arrow-right").text("►"));

    footer.append(pageSelectWrapper);

    updatePageSelect(pageSelect, curPage, curPageSize, total);


    $('#'+id).parent().append(footer);


    updatePage(id, curPage, curPageSize);

}

function updatePage(id, curPage, curPageSize, search=false){

    if(!search){
        let total = $('#'+id).find('.table-row').length;
        let start = curPage * curPageSize;
        let end = Math.min(total, start + curPageSize-1);
        $('#'+id).find('.table-row').each(function(){
            $(this).toggle(($(this).index() >= start && $(this).index() <= end));
        });

        $('#'+id).data('currentPage', curPage);
        $('#'+id).data('currentPageSize', curPageSize);


        updatePageStatus($('#'+id).parent().find(".page-status").eq(0), curPage, curPageSize, total);
        updatePageSelect($('#'+id).parent().find(".page-select").eq(0), curPage, curPageSize, total);

    } else {

        let total = $('#'+id).find('.table-row.search-result').length;
        let start = curPage * curPageSize;
        let end = Math.min(total, start + curPageSize-1);
        $('#'+id).find('.table-row').hide();
        $('#'+id).find('.table-row.search-result').each(function(i,value){
            $(value).toggle((i >= start && i <= end));
        });


        $('#'+id).data('currentPage', curPage);
        $('#'+id).data('currentPageSize', curPageSize);

        updatePageStatus($('#'+id).parent().find(".page-status").eq(0), curPage, curPageSize, total);
        updatePageSelect($('#'+id).parent().find(".page-select").eq(0), curPage, curPageSize, total, true);

    }
    $('#'+ id + ' .table-row:visible:nth-child(' + curPageSize + ') .row-item:last-child').css('border-bottom-right-radius', '.5em');

}


function updatePageStatus(elem, curPage, curPageSize, total){

    let start = curPage * curPageSize + 1;
    let end = start + curPageSize - 1;
    elem.html("Showing <b>" + start + " to " + Math.min(end,total) + "</b> of " + total + " rows");

}


function updatePageSelect(elem, curPage, curPageSize, total, search) {

    let last = elem.children().last().index();
    if(last * curPageSize < total){
        for(let i = 1; (i+last)*curPageSize<total; i++){
            elem.append($('<span>').addClass("page-select-item").text(i+last+1));
        }
    } else if(last * curPageSize > total) {
        for(let j=last; j*curPageSize>total; j--){
            elem.children().last().remove();
        }
    }
    if(search)
        elem.children().addClass("search-result-page");
    else
        elem.children().removeClass("search-result-page");


    elem.children().removeClass("page-selected").eq(curPage).addClass("page-selected");
    elem.parent().find(".page-select-arrow-left,.page-select-arrow-right").css("opacity", 0);
    let cur = $(".page-selected").index();
    last = elem.children().last().index();
    if(cur != 0) {
        $(".page-select-arrow-left").css("opacity", 1);
    }
    if(cur != last) {
        $(".page-select-arrow-right").css("opacity", 1);
    }

}
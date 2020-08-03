$(document).on('click', ".page-select-item:not(.search-result-page)", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);
    updatePage_help(table.attr('id'), $(this).text()-1, table.data('currentPageSize'));
});

$(document).on('click', ".page-select-item.search-result-page", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);
    updatePage_help(table.attr('id'), $(this).text()-1, table.data('currentPageSize'), true);
});

$(document).on('click', ".page-select-arrow-left", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);

    if ($(this).parent().find(".search-result-page").length > 0){
        updatePage_help(table.attr('id'), table.data("currentPage") - 1, table.data('currentPageSize'), true);
    } else {
        updatePage_help(table.attr('id'), table.data("currentPage") - 1, table.data('currentPageSize'));

    }
});

$(document).on('click', ".page-select-arrow-right", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);
    let cur = $(".page-selected").index();
    if ($(this).parent().find(".search-result-page").length > 0){
        updatePage_help(table.attr('id'), table.data("currentPage") + 1, table.data('currentPageSize'), true);
    } else {
        updatePage_help(table.attr('id'), table.data("currentPage") + 1, table.data('currentPageSize'));

    }
});

$(document).on('click', ".page-select-arrow-left-full", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);

    if ($(this).parent().find(".search-result-page").length > 0){
        updatePage_help(table.attr('id'), 0, table.data('currentPageSize'), true);
    } else {
        updatePage_help(table.attr('id'), 0, table.data('currentPageSize'));

    }
});

$(document).on('click', ".page-select-arrow-right-full", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);
    if ($(this).parent().find(".search-result-page").length > 0){
        updatePage_help(table.attr('id'), $(this).parent().find(".page-select-item:last-child").text()-1, table.data('currentPageSize'), true);
    } else {
        updatePage_help(table.attr('id'), $(this).parent().find(".page-select-item:last-child").text()-1, table.data('currentPageSize'));
    }
});

$(document).on('click', ".page-size-dropdown .page-size-option", function(){
    let table = $(this).closest('.library-table').find("table").eq(0);
    $(this).closest(".page-size-dropdown").find(".page-size-current").text($(this).text());
    updatePage_help(table.attr('id'), 0, parseInt($(this).text()), table.parent().find("search-result-page").length > 0);
    $(this).parent().hide();
});

$(document).on('click', ".page-size-current", function(e){
    e.stopPropagation();
    $(this).siblings(".page-size-option-wrapper").toggle();
});



function pagination(id, curPage, curPageSize, pageSizes) {

    let footer = $('<div>').addClass("pagination-wrapper");

    let sizeSelect = $('<div>').addClass("size-select");
    sizeSelect.text("Rows per page ");

    let dropdown = $('<div>').addClass("page-size-dropdown");
    let options = $('<div>').addClass("page-size-option-wrapper");
    for(let size of pageSizes) {
        options.append($('<div>').addClass("page-size-option").text(size));
    }
    dropdown.append(options).append($('<div>').addClass("page-size-current").text(pageSizes[0]));
    sizeSelect.append(dropdown);
    footer.append(sizeSelect);

    let pageStatus = $('<div>').addClass("page-status");
    footer.append(pageStatus);

    let pageSelectWrapper = $('<div>').addClass("page-select-wrapper");
    let pageSelect = $('<div>').addClass("page-select");
    pageSelectWrapper.append($('<div>').addClass("page-select-arrow-left").append($('<i class="fa fa-angle-left" aria-hidden="true"></i>')));
    pageSelectWrapper.append($('<div>').addClass("page-select-arrow-left-full").append($('<i class="fa fa-angle-double-left" aria-hidden="true"></i>')));
    pageSelect.append($('<span>').addClass("page-select-item").text("1"));
    pageSelectWrapper.append(pageSelect);
    pageSelectWrapper.append($('<div>').addClass("page-select-arrow-right-full").append($('<i class="fa fa-angle-double-right" aria-hidden="true"></i>')));
    pageSelectWrapper.append($('<div>').addClass("page-select-arrow-right").append($('<i class="fa fa-angle-right" aria-hidden="true"></i>')));

    footer.append(pageSelectWrapper);

    $('#'+id).parent().append(footer);

}

function updatePage_help(id, curPage, curPageSize, clientSearch=false){
    if(!clientSearch){
        let searchContent = $('#'+id).siblings(".searchbar").eq(0).val();
        updatePage(id, curPage, curPageSize, $('#'+id).find('.table-row').length, clientSearch, searchContent);
    } else {
        updatePage(id, curPage, curPageSize, $('#'+id).find('.table-row.search-result').length, clientSearch);
    }
}


async function updatePage(id, curPage, curPageSize, total, clientSearch=false, params={}, searchContent="", columns=""){
    let serv = $('#'+id).data('side') === 'server';

    if(serv){
        params = $('#'+id).data('params');
        if (columns != "") { params.columns = columns; }
      
        searchContent = $('#'+id).siblings(".function_bar").find(".searchbar").val();
        try {
            total = await serverSide(id, $('#'+id).data('url'), curPage, curPageSize, params, searchContent, window[id].sort_params);
        } catch (e) {
            console.error("aborted request");
        }
        try {
            window[id].apply_styles();
        } catch (e){
            // don't need to
        }
      // Update column management flyout
      if (columns == "") {
        let $visible = $('#'+id).parent().find('#visible-columns');
        let $available = $('#'+id).parent().find('#available-columns');
        updateVisibleAvailableColumns(window[id].columns, window[id].col_selected, $visible, $available);
      }
    }

    if(!clientSearch){
        let start = curPage * curPageSize;
        let end = Math.min(total, start + curPageSize-1);
        $('#'+id).find('.table-row').each(function(){
            $(this).toggle(($(this).attr("index") >= start && $(this).attr("index") <= end));
        });

        $('#'+id).data('currentPage', curPage);
        $('#'+id).data('currentPageSize', curPageSize);


        updatePageStatus($('#'+id).parent().find(".page-status").eq(0), curPage, curPageSize, total);
        updatePageSelect($('#'+id).parent().find(".page-select").eq(0), curPage, curPageSize, total);

    } else {
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


    post_styles(id, curPageSize);

    $('#'+ id).removeClass("loading");

}


function updatePageStatus(elem, curPage, curPageSize, total){
    
    if(total == -1) {
        elem.html("loading...");
        return;
    }
    let start = curPage * curPageSize + 1;
    let end = start + curPageSize - 1;
    elem.html("Showing <b>" + start.toLocaleString() + " to " + Math.min(end,total).toLocaleString() + "</b> of " + total.toLocaleString() + " rows");

}


function updatePageSelect(elem, curPage, curPageSize, total, clientSearch) {
    if(total === -1) {
        elem.hide();
        return;
    } else {
        elem.show();
    }
    elem.find('.table-ellipses').remove();
    let last = elem.find('.page-select-item').last().index();
    if(last * curPageSize < total){
        for(let i = 1; (i+last)*curPageSize<total; i++){
            elem.append($('<span>').addClass("page-select-item").text(i+last+1));
        }
    } else if(last * curPageSize > total) {
        for(let j=last; j*curPageSize>total; j--){
            elem.find('.page-select-item').last().remove();
        }
    }
    if(clientSearch)
        elem.find('.page-select-item').addClass("search-result-page");
    else
        elem.find('.page-select-item').removeClass("search-result-page");


    elem.find('.page-select-item').removeClass("page-selected").eq(curPage).addClass("page-selected");
    elem.parent().find(".page-select-arrow-left,.page-select-arrow-right,.page-select-arrow-left-full,.page-select-arrow-right-full").css({"opacity": 0, "pointer-events": "none"});
    
    let cur = elem.find(".page-selected").index();
    last = elem.find('.page-select-item').last().index();
    if(cur != 0) {
        $(".page-select-arrow-left,.page-select-arrow-left-full").css({"opacity": 1, "pointer-events": "auto"});
    }
    if(cur != last) {
        $(".page-select-arrow-right,.page-select-arrow-right-full").css({"opacity": 1, "pointer-events": "auto"});
    }

    if(elem.find('.page-select-item').length > 5) {
        elem.children().hide();
        // elem.find($(':nth-child(1)')).show();
        // elem.find($(':nth-child(' + (last+1) + ')')).show();
        for(let i=curPage;i<=curPage+2;i++){
            elem.find($(':nth-child(' + i + ')')).show();
        }
        if(curPage == 0) {
            elem.find($(':nth-child(3)')).show();
        }
        if(curPage == last) {
            elem.find($(':nth-child(' + (last-2) + ')')).show();
        }
        // ellipses
        if(curPage >= 2){
            $("<span>").addClass("table-ellipses").text("...").insertAfter(elem.find('.page-select-item').eq(0));
        }
        if(curPage <= last-3){
            $("<span>").addClass("table-ellipses").text("...").insertBefore(elem.find('.page-select-item').eq(last));
        }
    }

}




function post_styles(id, curPageSize) {

    $('#'+ id + ' .table-row:visible:nth-child(' + curPageSize + ') .row-item:last-child').css('border-bottom-right-radius', '.5em');

    if($('#'+id+" .row-item.drilldown-link .cell-text i").length === 0){
        $('#'+id+" .row-item.drilldown-link .cell-text").append($('<i class="fas fa-level-down-alt"></i>'));
    }

}

// close page size box on click away
$(document).on('click', 'html > *:not(.page-size-current)', function(e){
    $(".page-size-option-wrapper").hide();
  });

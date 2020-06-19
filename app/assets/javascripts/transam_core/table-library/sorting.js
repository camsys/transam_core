$(document).ready(function(){
    $(document).on("click",".library-table table[data-sort='client'] .header-item",(function(){
        var table = $(this).parents('.elbat').eq(0);
        $(this).siblings().attr("order", "");
        var rows = table.find('tr:gt(0)').toArray().sort(comparer($(this).index(), $(this).attr("order")));
        $(this).attr("order", $(this).attr("order") == "ascending" ? "descending" : "ascending");
        // update the sort_params object
        updateSortPreferences(table.attr('id'), table.data('tableCode'));
        for (var i = 0; i < rows.length; i++){
            $(rows[i]).attr("index", i);
            table.append(rows[i]);
        }
        if ($(table).find(".search-result").length > 0){
            updatePage_help(table.attr('id'), table.data("currentPage"), table.data('currentPageSize'), true);
        } else {
            updatePage_help(table.attr('id'), table.data("currentPage"), table.data('currentPageSize'));
        }
        applyIcons(table.find('.header'));
    })
)});

const comparer = (idx, order) => (a, b) => ((v1, v2) => (order == "ascending") ?
                    v1 !== '' && v2 !== '' && !isNaN(v1) && !isNaN(v2) ? v2 - v1 : v2.toString().localeCompare(v1):
                    v1 !== '' && v2 !== '' && !isNaN(v1) && !isNaN(v2) ? v1 - v2 : v1.toString().localeCompare(v2))
                    (getCellValue(a, idx), getCellValue(b, idx));


const getCellValue = (row, index) => { 
    let td = $(row).children('td').eq(index);
    let date = new Date(td.text());
    if($(td).attr("class").includes("checkmark-column")) { return $(td).children().eq(0).children().eq(0).css("visibility")=="hidden"; } // needs a lot of work but gets the job done
    else if(td.text().includes('$')){ return Number(td.text().replace(/[^\d.]/g, '')); }
    else if(date && date.toString() !== "Invalid Date"){ return date.getTime(); }
    return td.text(); 
}


function updateSortPreferences(id, table_code) {
  $.ajax({
    method: "PUT",
    contentType: "application/json; charset=utf-8",
    data:{'table_preferences':{'table_code': table_code,'sort':window[id].sort_params}},
    url: "/users/table_preferences",
    dataType: "json"
  });
}

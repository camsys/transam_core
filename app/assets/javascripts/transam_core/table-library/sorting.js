$(document).ready(function(){
    $(document).on("click",".header-item",(function(){
        var table = $(this).parents('.elbat').eq(0);
        $(this).siblings().attr("order", "");
        var rows = table.find('tr:gt(0)').toArray().sort(comparer($(this).index(), $(this).attr("order")));
        $(this).attr("order", $(this).attr("order") == "ascending" ? "descending" : "ascending");
        //todo: update the sort_params object
        for (var i = 0; i < rows.length; i++){table.append(rows[i]);}
    })
)});

const comparer = (idx, order) => (a, b) => ((v1, v2) => (order == "ascending") ?
                      v1 !== '' && v2 !== '' && !isNaN(v1) && !isNaN(v2) ? v1 - v2 : v1.toString().localeCompare(v2) :
                      v1 !== '' && v2 !== '' && !isNaN(v1) && !isNaN(v2) ? v2 - v1 : v2.toString().localeCompare(v1))
                    (getCellValue(a, idx), getCellValue(b, idx));


function getCellValue(row, index){
    return $(row).children('td').eq(index).text();
}

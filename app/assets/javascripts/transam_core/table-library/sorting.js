$(document).ready(function(){
    $(document).on("click",".header-item",(function(){
        var table = $(this).parents('.elbat').eq(0);
        var rows = table.find('tr:gt(0)').toArray().sort(comparer($(this).index(), $(this).attr("order")));
        $(this).attr("order", $(this).attr("order") == "ascending" ? "descending" : "ascending");
        //todo: update the sort_params object
        for (var i = 0; i < rows.length; i++){table.append(rows[i]);}
    })
)});

function comparer(index, order) {
    return function(a, b) {
        var valA = getCellValue(a, index), valB = getCellValue(b, index);
        if (order == "ascending") {
            return valA - valB;
        } else {
            return valB - valA;
        }
        
    }
}
function getCellValue(row, index){
    // todo build cases for each data type
    return $(row).children('td').eq(index).text();
}
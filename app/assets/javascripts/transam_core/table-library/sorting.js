$(document).ready(function(){
    $(document).on("click",".library-table table[data-sort='client'] .header-item:not(.header-checkbox):has(.header-icons)",(function(){
      $(this).attr("order", $(this).attr("order") == "ascending" ? "descending" : "ascending");
      $(this).parent().parent().parent().addClass('loading');
      client_sort(this);
    }
      // function(){
      //   var table = $(this).parents('.elbat').eq(0);
      //   $(this).siblings().attr("order", "");
      //   var rows = table.find('tr:gt(0)').toArray().sort(comparer($(this).index(), $(this).attr("order")));
      //   $(this).attr("order", $(this).attr("order") == "ascending" ? "descending" : "ascending");
      //   // update the sort_params object
      //   console.log(window[table.attr('id')].sort_params);
      //   updateSortPreferences(table.attr('id'), table.data('tableCode'), $(this).attr("code"), $(this).attr("order"));
      //   for (var i = 0; i < rows.length; i++){
      //       $(rows[i]).attr("index", i);
      //       table.append(rows[i]);
      //   }
      //   if ($(table).find(".search-result").length > 0){
      //       updatePage_help(table.attr('id'), table.data("currentPage"), table.data('currentPageSize'), true);
      //   } else {
      //       updatePage_help(table.attr('id'), table.data("currentPage"), table.data('currentPageSize'));
      //   }
      //   applyIcons(table.find('.header'));
      // }
      )
    );
    $(document).on("click",".library-table table[data-sort='server'] .header-item:not(.header-checkbox):has(.header-icons)",(async function(){
      
      let table = $(this).parents('.elbat').eq(0);
      let id = table.attr('id')
      // toggle column
      $(this).attr("order", $(this).attr("order") == "ascending" ? "descending" : "ascending");
      $(this).siblings().attr("order", "");
      let obj = {};
      obj[$(this).attr("code")] = $(this).attr("order");
      window[id].sort_params = [obj];
      if ($(table).find(".search-result").length > 0){
        updatePage(table.attr('id'), table.data("currentPage"), table.data('currentPageSize'), $('#'+id).find('.table-row.search-result').length, clientSearch, "", window[id].sort_params);
      } else {
        updatePage(table.attr('id'), table.data("currentPage"), table.data('currentPageSize'), $('#'+id).find('.table-row').length, false, "", window[id].sort_params);
      }
      applyIcons(table.find('.header'));
      window[id].checkedRows = {}; // clear selected rows on sort // TODO: this is a bad idea, but it's the only way to prevent duplicates on export since the row indexs are recalculated on sort
      window[id].uncheckedRows = {};

      // Google Tag Manager
      window.dataLayer = window.dataLayer || [];
      window.dataLayer.push({
	'event': 'table_sort',
	'sortTable': $(table).data('tableCode'),
	'tableSortColumnOrder': $(this).attr("code") + ":" +  $(this).attr("order")
      });
    })
  );
});

async function client_sort(elem){
  var table = $(elem).parents('.elbat').eq(0);
  $(elem).siblings().attr("order", "");
  var rows = table.find('tr:gt(0)').toArray().sort(comparer($(elem).index(), $(elem).attr("order")));
  // update the sort_params object
  // console.log(window[table.attr('id')].sort_params);
  await updateSortPreferences(table.attr('id'), table.data('tableCode'), $(elem).attr("code"), $(elem).attr("order"));
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
  table.removeClass("loading");
}

const comparer = (idx, order) => (a, b) => ((v1, v2) => (order == "ascending") ?
                    v1 !== '' && v2 !== '' && !isNaN(v1) && !isNaN(v2) ? v1 - v2 : v1.toString().localeCompare(v2):
                    v1 !== '' && v2 !== '' && !isNaN(v1) && !isNaN(v2) ? v2 - v1 : v2.toString().localeCompare(v1))
                    (getCellValue(a, idx), getCellValue(b, idx));


const getCellValue = (row, index) => { 
    
    let td = $(row).children('td').eq(index);
    const cleanNum = td.text().replace(/[^\d.]/g, ''); // pull numbers out, allowing a decimal place
    const cleanLetters = td.text().replace(/[^a-zA-Z]+/g, ''); // pull letters out
    let date = new Date(td.text());
    if($(td).attr("class").some("checkmark-column", "x-column")) { return $(td).children().eq(0).children().eq(0).css("visibility")=="hidden"; } // needs a lot of work but gets the job done
    else if(td.text().includes('$')){ return Number(cleanNum); }
    else if(td.text().includes('%')){ return Number(cleanNum); }
    else if(td.text().includes('-')){ return td.text(); }
    else if(isNaN(td.text().replace(/[,.]/g, "")) && date && date.toString() !== "Invalid Date"){ return date.getTime(); } // assumes that dates are not convertable into numbers, but in the case where that is possible, sorting by number value should still be accurate
    else if(cleanNum.length > 0 && !isNaN(cleanNum) && cleanLetters.length == 0){ return Number(cleanNum); } 
    return td.text(); 
}


async function updateSortPreferences(id, table_code, column, order) {
  // for(let col in window[id].sort_params){
  //   if(col[column]) col[column] = order;
  //   else window[id].sort_params.push({}[column]=order);
  // }
  let obj = {};
  obj[column] = order;
  window[id].sort_params = [obj];
  $.ajax({
    method: "PUT",
    contentType: "application/json; charset=utf-8",
    data:JSON.stringify({'table_preferences':{'table_code': table_code,'sort': window[id].sort_params}}), //[{org_name:"ascending"}]
    url: "/users/table_preferences",
    dataType: "json"
  });
}

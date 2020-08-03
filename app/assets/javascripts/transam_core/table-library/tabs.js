$(document).on("click", ".tab", function(){
  $(this).siblings().removeClass("active");
  $(this).addClass("active");
  let tab_content = $(".elbat[data-table-code='" + $(this).attr("code") + "']").closest('.tab_content').addClass("active");
  if($(".elbat[data-table-code='" + $(this).attr("code") + "']").length > 1){
    // multiple tables with same code
    try {
      tab_content = $('#'+$(this).attr("table_id")).closest('.tab_content').addClass("active");
    } catch (e) {
      console.error("Error in generating tabbed tables: ", e);
    }
  }
  tab_content.siblings(".active").hide();
  tab_content.show();
  updateColumnsFlyout(tab_content);
});

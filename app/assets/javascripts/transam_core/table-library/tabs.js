$(document).on("click", ".tab", function(){
  $(this).siblings().removeClass("active");
  $(this).addClass("active");
  let tab_content = $(".elbat[data-table-code='" + $(this).attr("code") + "']").parent().parent().addClass("active");
  tab_content.siblings(".active").hide();
  tab_content.show();
});
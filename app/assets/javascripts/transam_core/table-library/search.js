function addSearch(id) {
    let searchbar = $('<input>').addClass("searchbar");

    $(searchbar).on("keyup", function(){
        let value = $(this).val().toLowerCase();

        if(value === "") {
            removeSearch(id);
            return;
        }

        $('#'+id +" .table-row").filter(function(){
            $(this).removeClass("search-result");
            if($(this).text().toLowerCase().indexOf(value) > -1){
                $(this).addClass("search-result").show();
            }
        });
        updatePage(id, 0, $('#'+id).data('currentPageSize'), true);
    });
    $('#'+id).parent().prepend(searchbar);
}

function removeSearch(id) {
    $('#'+id +" .table-row").removeClass("search-result");
    updatePage(id, 0, $('#'+id).data('currentPageSize'));
}
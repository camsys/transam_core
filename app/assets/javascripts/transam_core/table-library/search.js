function addSearch(id) {
    let searchbar = $("<div>").addClass("search-wrapper").append($('<i class="fas fa-search">')).append($('<input>').addClass("searchbar").attr('placeholder', "Search Table..."));

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
        updatePage_help(id, 0, $('#'+id).data('currentPageSize'), true);
    });
    $('#'+id).parent().find(".function_bar").append(searchbar);
}


function addSearchServer(id) {
    let searchbar = $("<div>").addClass("search-wrapper").append($('<i class="fas fa-search">')).append($('<input>').addClass("searchbar").attr('placeholder', "Search Table..."));

    $(searchbar).on("keyup", function(){
        let value = $(this).val().toLowerCase();

        if(value === "") {
            $('#' + id + " .table-row").remove();
            removeSearch(id);
            return;
        }
        $('#' + id + " .table-row").remove();
        updatePage(id, 0, $('#'+id).data('currentPageSize'),-1, false, $('#'+id).data('params'), value);
    });
    $('#'+id).parent().find(".function_bar").append(searchbar);
}

function removeSearch(id) {
    $('#'+id +" .table-row").removeClass("search-result");
    updatePage_help(id, 0, $('#'+id).data('currentPageSize'));
}

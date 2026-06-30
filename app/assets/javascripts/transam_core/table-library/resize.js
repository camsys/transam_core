$(document).ready(function() {
    let startingX = 0;
    let startingWidth = 0;
    let colHeader = undefined;

    function resizeAdjust(resizeE) {
        let calculatedWidth = startingWidth + resizeE.pageX - startingX;
        if (calculatedWidth >= 36) {
            $(colHeader).width(calculatedWidth);
        }
    }

    function resizeConfirm(mouseupE) {
        $(document).off("mousemove", resizeAdjust);
        $(document).off("mouseup", resizeConfirm);
    }

    $(document).on('mousedown', ".column-resize-handle", function(e) {
        e.stopPropagation();
        colHeader = e.target.closest("th");
        startingX = e.pageX;
        startingWidth = $(colHeader).width();

        $(document).on("mousemove", resizeAdjust);
        $(document).on("mouseup", resizeConfirm);
    });
});
// function closeFlyout() {
//     for(var elem of document.getElementsByClassName("closeFlyout")){
//         elem.addEventListener("click", function(){
//             this.form.reset();
//         });
//     }
// }


function createFlyout(elem, before, append) {
    $(document).ready(function(){
        before;
        $(elem + ":empty").append(append);
    });
}

function toggleExtend(trigger, elem, isRight) {
    if (isRight) {
        $(trigger).on('click', function() {$(elem).toggleClass( "extend-right" )});
    }  else {
        $(trigger).on('click', function() {$(elem).toggleClass( "extend-left" )});
        elem.scrollLeft = window.innerWidth;
    }
}
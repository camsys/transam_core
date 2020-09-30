// $(document).ready(function(){

  function add_flyout(button, title, content, classes){
      const flyout_html = $('<div class="flyout_wrapper close">').addClass(classes).append($('<div class="flyout-body">')
        .append($('<header><div class="panel-title">'+ title +'</div><button class="close-flyout button-clear button-icononly"><i class="fas fa-arrow-alt-to-right"/></button></header>'))
        .append($(content)));
                            
    
      // append in right place
      $(button).addClass("flyout_button")
        .before($(flyout_html));


      // put class on the button 

      $(document).on('click', ".flyout_button", function(event){
        event.stopPropagation();
        event.stopImmediatePropagation();
        // $(".flyout_wrapper").addClass("close");
        $(this).siblings(".flyout_wrapper").toggleClass("close");
      });

      $(document).on('click', ".close-flyout", function(event){
        event.stopPropagation();
        event.stopImmediatePropagation();
        $(this).closest(".flyout_wrapper").addClass("close");
      });
  }

  


    
    
// });
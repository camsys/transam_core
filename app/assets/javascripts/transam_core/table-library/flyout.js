// $(document).ready(function(){

  function add_flyout(button, title, content, classes){
      const flyout_html = $('<div class="flyout_wrapper close">').addClass(classes).append($('<div class="flyout-body">')
        .append($('<header><div class="panel-title">'+ title +'</div><button class="close-flyout button-clear button-icononly"><i class="fas fa-arrow-alt-to-right"/></button></header>'))
        .append($(content)));
                            
    
      // append in right place
      $(button).addClass("flyout_button_trigger")
        .before($(flyout_html));


      // put class on the button 

      $(document).on('click', ".flyout_button_trigger", function(event){
        event.stopPropagation();
        event.stopImmediatePropagation();
        // $(".flyout_wrapper").addClass("close");
        if($(this).siblings(".flyout_wrapper").length == 0) {
          $(this).parent().parent().find(".flyout_wrapper").toggleClass("close");
        } else {
          $(".flyout_wrapper").not($(this).siblings(".flyout_wrapper")).addClass("close");
          $(this).siblings(".flyout_wrapper").toggleClass("close");
        }
      });

      $(document).on('click', ".close-flyout", function(event){
        event.stopPropagation();
        event.stopImmediatePropagation();
        $(this).closest(".flyout_wrapper").addClass("close");
      });
  }


  function insert_flyout(button, title, content, classes) {
    if($(button).siblings(".flyout_wrapper").length == 0){
      add_flyout(button, title, content, classes);
      $(button).siblings('.flyout_wrapper.close').removeClass('close');
    }
  }

  


    
    
// });
//= require_tree .
function ajax_render_action(url, method) {
	$.ajax({
    	type: method,
      	url: url,
      	beforeSend:function(){
        	// this is where we append a loading image
    		//$('#ajax-panel').html('<div class="loading"><img src="/images/loading.gif" alt="Loading..." /></div>');
  		},
  		success:function(data){
		    // successful request; do something with the data
		    //$('#ajax-panel').empty();
		    //$(data).find('item').each(function(i){
		    //  $('#ajax-panel').append('<h4>' + $(this).find('title').text() + '</h4><p>' + $(this).find('link').text() + '</p>');
		    //});
		},
		error: function (data) {
      		show_alert("We are sorry but something went wrong. Please try again.");                
      	}
   	});  
};

// session based variable storage for UI key/value pairs

// get a key value, if the key does not exist the default value is returned  
function get_ui_key_value(key, default_val) {
    var value;
    try {
        value = window.sessionStorage.getItem(key);
    } catch(e) {
        value = default_val;
    }    
	//alert('getting value for ' + key + '; val = ' + value);
    return value;
};
// Set a key value. Keys must be unique strings
function set_ui_key_value(key, value) {
	//alert('setting value for ' + key + ' to ' + value);
    window.sessionStorage.setItem(key, value);
};

// Used to remove any existing banner messages
function remove_messages() {
	$('.alert').alert('close');
};

function click_to_nav(url) {
  alert('deprecated');
  document.location.href = url;
};

//
// Adds the first-in-row class to a list of thumbnails. Assumes that
// the view is using the standard 12 column bootstrap layout
// span_size is the size of the span* classes added to each
// thumbnail 
function fix_thumbnail_margins(span_size, class_name) {

	var counter = 12 / span_size;
	var selector = class_name == null ? '.thumbnail' : '.' + class_name;
	var i = 0;
	$(selector).each(function() {
		var remainder = i % counter;
		//alert('i = ' + i + ' remainder = ' + remainder);
		if (remainder == 0) {
			$(this).addClass('first-in-row');
		}
		i++;
	});	
};

function enable_date_pickers() {
	// Use jquery to render date pickers for all datepicker input classes
	$('.datepicker').datepicker({
		 format: 'yyyy-mm-dd'
	});
};

// Finds all the class elements on a page and sets the min-height css variable
// to the maximum height of all the containers
function make_same_height(class_name) {

	// remove any existing min-height attributes
	$(class_name).css({'min-height' : ''});
	
	// Set the form parts to equal height
	var max = -1;
	$(class_name).each(function() {
		var h = $(this).height(); 
		//alert(h);
		max = h > max ? h : max;
	});
	max += 10;
	$(class_name).css({'min-height': max});	
};

// Finds all elements marked as info icons and turns them into popups
function enable_info_popups(class_name) {
	$(class_name).popover({
		trigger: 'hover'
	});
};


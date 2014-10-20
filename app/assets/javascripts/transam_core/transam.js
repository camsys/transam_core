//
// Transam specific javascript
//
var transam = new function() {

	// disable an element
	this.disable_element = function(id) {
		$('#' + id).attr('disabled', 'disabled');
	};
	// enable an element
	this.enable_element = function(id) {
		$('#' + id).removeAttr('disabled');		
	};
	// test if an element is blank
	this.is_blank = function(elem_id) {
		var len = actual_string_length(elem_id);
		return len == 0;
	};
	
	// Fix the page footer to the bottom of the page
	this.fix_page_footer = function(footer_div) {

		var docHeight = $(window).height();
   		var footerHeight = $(footer_div).height();
   		var footerTop = $(footer_div).position().top + footerHeight;
   		//alert(docHeight + "," + footerHeight + "," + footerTop);
   		if (footerTop < docHeight) {
    		$(footer_div).css('margin-top', (docHeight - footerTop) + 'px');
   			//alert("Adjusted: " + docHeight + "," + footerHeight + "," + footerTop);
   		}	
	};
		
	// validate a file size
	this.validate_file_size = function(inputFile, max_file_size_mb) {
		var warning_message = "This file exceeds the maximum allowed file size (" + max_file_size_mb + " MB). Please select a smaller file.";
		var max_bytes = max_file_size_mb * 1048576;
	  	$.each(inputFile.files, function() {
	  		// alert('File Size = ' + this.size + ' Max File Size = ' + max_file_size);
	  		if (this.size && max_bytes && this.size > parseInt(max_bytes)) {
	  			// Show a warning message using the popup message provider
		    	show_popup_message('Warning', warning_message, 'warning');
		    	$(inputFile).val('');
	  		}
	  	});	 
	};
	// Show a popup message in the UI
	this.show_popup_message = function(title, message, type) {
		var class_name = 'alert alert-info';
		if (type == 'error') {
			class_name = 'alert alert-danger';
		} else if (type == 'warning') {
			class_name = 'alert alert-warning';			
		}
		$.gritter.add({
			title: title,
			class_name: class_name,
			text: message
		});
	};

	// Converts a table to a datatable
	this.render_data_table = function(div_id, filter) {
		$("#" + div_id).dataTable( {
			"bFilter" : filter,
			"bLengthChange" : true,
			"bProcessing" : true,
			"sDom": "<'row'<'col-xs-6'l><'col-xs-6'f>r>t<'row'<'col-xs-6'i><'col-xs-6'p>>",
			"sPaginationType": "bootstrap",
			"oLanguage": {
				"sLengthMenu": "_MENU_ records per page"
			},
			"fnDrawCallback": function( oSettings ) {
	      		transam.install_quick_link_handlers();
	    	}		
		} );		
	};
	
	// Draws a google char based on the chart data and chart options passed in
	this.draw_chart = function(div_id, chart_type, chart_options, chart_data) {

		var container = document.getElementById(div_id);
		if (container == null) {
			return;
		} 		
		var chart = null;
		if (chart_type === 'area') {
			chart = new google.visualization.AreaChart(container);
		} else if (chart_type === 'bar') {
			chart = new google.visualization.BarChart(container);
		} else if (chart_type === 'column') {
			chart = new google.visualization.ColumnChart(container);
		} else if (chart_type === 'combo') {
			chart = new google.visualization.ComboChart(document.getElementById(div_id));
		} else if (chart_type === 'histogram') {
			chart = new google.visualization.Histogram(document.getElementById(div_id));
		} else if (chart_type === 'line') {
			chart = new google.visualization.LineChart(document.getElementById(div_id));
		} else if (chart_type === 'pie') {
			chart = new google.visualization.PieChart(document.getElementById(div_id));
		} else if (chart_type === 'scatter') {
			chart = new google.visualization.ScatterChart(document.getElementById(div_id));
		}
		if (chart) {
			chart.draw(chart_data, chart_options);
		}
	};

  	// Load a block of html in the background
  	this.load_ajax_panel = function(div_id, url, method, loader_panel) {
    	$.ajax({
	    	type: method,
        	url: url,
        	cache: false,
        	beforeSend:function() {
          		if (loader_panel) {
            		$("#" + div_id).html(loader_panel);
          		}
        	},       
        	//success: function(html) {
          	//	$("#" + div_id).empty();
          	//	$("#" + div_id).append(html);
        	//},
			error: function (data) {
	      		show_error_message(div_id, "We are sorry but something went wrong. Please try again.");                
	      	}
    	});
  	};

	this.ajax_render_action = function(url, method) {
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

	//
	// session based variable storage for UI key/value pairs
	//
	// get a key value, if the key does not exist the default value is returned  
	this.get_ui_key_value = function(key, default_val) {
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
	this.set_ui_key_value = function(key, value) {
		//alert('setting value for ' + key + ' to ' + value);
	    window.sessionStorage.setItem(key, value);
	};

	// Used to remove any existing banner messages
	this.remove_messages = function() {
		$('.alert').alert('close');
	};

	this.enable_date_pickers = function() {
		// Use jquery to render date pickers for all datepicker input classes
		$('.datepicker').datepicker({
			 format: 'mm-dd-yyyy'
		});
	};

	// Finds all the class elements on a page and sets the min-height css variable
	// to the maximum height of all the containers
	this.make_same_height = function(jquery_selector) {
	
		// remove any existing min-height attributes
		$(jquery_selector).css({'height' : ''});
		
		// Set the form parts to equal height
		var max = -1;
		$(jquery_selector).each(function() {
			var h = $(this).height(); 
			//alert(h);
			max = h > max ? h : max;
		});
		max += 10;
		$(jquery_selector).css({'height': max});	
	};

	// Finds all elements marked as info icons and turns them into popups
	this.enable_info_popups = function(class_name) {
		$(class_name).popover({
			trigger: 'hover',
			container: 'body',
    		animation: 'true',
    		html: 'true'    
		});
	};

	this.install_quick_link_handlers = function() {
		// Enable the quick links
		$('[data-action-path]').click(function() {
			var url = $(this).data('action-path');
			document.location.href = url;
		});		
	};

	// Hides dropdown button if the dropdown is empty
	this.hide_empty_dropdown = function () {
		var btn = $("button.btn[data-toggle='dropdown']");
		var dropdown = btn.siblings("ul");
		if (dropdown.children().length === 0) {
			btn.hide();
		}
	}

	// Internal functions
	var show_error_message = function(div_id, message) {
		$("#" + div_id).empty();
        $("#" + div_id).append('<div class="alert alert-error">' + message + '</div>');		
	};
	var actual_string_length = function(elem_id) {
		var val = $("#" + elem_id).val();
		var len = $.trim(val).length;
		return len;
	};
};




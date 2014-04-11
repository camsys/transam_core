//
// Transam specific javascript
//
var transam = new function() {

	// validate a file size
	this.validate_file_size = function(inputFile, max_file_size_mb) {
		var warning_message = "This file exceeds the maximum allowed file size (" + max_file_size_mb + " MB). Please select a smaller file.";
		var max_bytes = max_file_size_mb * 1048576;
	  	$.each(inputFile.files, function() {
	  		// alert('File Size = ' + this.size + ' Max File Size = ' + max_file_size);
	  		if (this.size && max_bytes && this.size > parseInt(max_bytes)) {
	  			// Show a warning message using the popup message provider
		    	show_popup_message('Warning', warning_message);
		    	$(inputFile).val('');
	  		}
	  	});	 
	};
	// Show a popup message in the UI
	var show_popup_message = function(title, message) {
		$.gritter.add({
			title: title,
			text: message
		});
	};

	// Converts a table to a datatable
	this.render_data_table = function(div_id, filter) {
		$("#" + div_id).dataTable( {
			"bFilter" : filter,
			"bLengthChange" : true,
			"bProcessing" : true,
			"sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
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

	//
	// Adds the first-in-row class to a list of thumbnails. Assumes that
	// the view is using the standard 12 column bootstrap layout
	// span_size is the size of the span* classes added to each
	// thumbnail 
	this.fix_thumbnail_margins = function(span_size, class_name) {

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

	this.enable_date_pickers = function() {
		// Use jquery to render date pickers for all datepicker input classes
		$('.datepicker').datepicker({
			 format: 'yyyy-mm-dd'
		});
	};

	// Finds all the class elements on a page and sets the min-height css variable
	// to the maximum height of all the containers
	this.make_same_height = function(class_name) {
	
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
	this.enable_info_popups = function(class_name) {
		$(class_name).popover({
			trigger: 'hover'
		});
	};

	this.install_quick_link_handlers = function() {
		// Enable the quick links
		$('[data-action-path]').click(function() {
			var url = $(this).data('action-path');
			document.location.href = url;
		});		
	};

	// Internal functions
	var show_error_message = function(div_id, message) {
		$("#" + div_id).empty();
        $("#" + div_id).append('<div class="alert alert-error">' + message + '</div>');		
	};

};




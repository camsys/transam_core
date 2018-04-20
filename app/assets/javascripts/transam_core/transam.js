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
		return len === 0;
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

	// Activate server side processing of info popups
	this.activate_info_popups = function(class_name) {
		$(class_name).bind({
    	mouseenter: function() {
      	var el=$(this);
    		$.ajax({
    			type: "GET",
    			url: el.attr("data-url"),
    			dataType: "html",
    			success: function(data) {
	    			$(".popover").popover("hide");
      			el.attr("data-content", data);
      			el.popover('show');
    			}
				});
			},
	  	mouseleave: function() {
	    	var el=$(this);
	      el.popover('hide');
	   	}
		});
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
	// Show a rails-style flash message, but default to old-popup if messages-flash doesn't exist
	this.show_flash_message = function(message, classes){
		var $msg = $('#messages-flash');
		if($msg.length == 0){
			return this.show_popup_message('Information', message, classes);
		}
		classes = classes || 'alert alert-info';
		// push new mesage on top of messages, trigger scroll to update 'floating' js positioned elements (floating table header for example)
		$msg.prepend("<div class='"+classes+"'><a class='close' data-dismiss='alert'>×</a><div id='flash_notice'>"+message+"</div></div>");
		$(document).trigger('scroll');
		var updateTableHeader = function( second ){
		  //calling this will trigger 'scroll' event 2x, 220 ms apart, to make sure it actually runs on slower devices
		  setTimeout(function(){
				$(document).trigger('scroll');
				if(!second){
					updateTableHeader(true);
				}
			}, 220);
		};
		$msg.off('click').on('click', updateTableHeader );
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
      text: message,
      time: 5000,
      class_name: class_name,
      image: false,
      sticky: false
    });
	};

	// Converts a table to a datatable
	this.render_data_table = function(div_id, filter, sorting) {
		$("#" + div_id).dataTable( {
			"bFilter" : filter,
			"bLengthChange" : true,
			"bProcessing" : true,
			"bSort" : sorting,
			"sDom": "<'row'<'col-xs-6'l><'col-xs-6'f>r>t<'row'<'col-xs-6'i><'col-xs-6'p>>",
			"sPaginationType": "bootstrap",
			"oLanguage": {
				"sLengthMenu": "_MENU_ records per page"
			},
			"fnDrawCallback": function( oSettings ) {
	      		transam.install_quick_link_handlers();
	      		transam.activate_info_popups('.info-popup');
	    	}
		} );
	};

	// Draws a google chart based on the chart data and chart options passed in
	this.draw_chart = function(div_id, chart_type, chart_options, chart_data) {

		var container = document.getElementById(div_id);
		if (container === null) {
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
	// Remove a key value.
	this.remove_ui_key_value = function(key) {
    window.sessionStorage.removeItem(key);
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

	this.install_quick_link_handlers = function() {
		// Enable the quick links
		$(document).on('click', '[data-action-path]', function() {
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
	};

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

	// Popup a modal dialog to provide comments
	this.bootbox_comment_dialog = function(title, callback) {
	  title = title || "Enter Comments";
	  bootbox.prompt({
	    title: title,
	    inputType: 'textarea',
	    buttons: {
	      confirm: {
	          label: 'Submit'
	      }
	    },
	    callback: callback
	  });
	};

    this.make_fiscal_year = function(jquery_selector) {

        $(jquery_selector).change(function(){
            field_to_update = $(this).attr('for');

            // get fiscal year
            yr_input = parseInt($(this).val());
            if (yr_input >= 0) {
                $('#'+field_to_update).val(yr_input);
                yr_input += 1;
                $('span[for="'+field_to_update+'"]').text(' - '+ yr_input);
            } else {
                $('#'+field_to_update).val('');
                $('span[for="'+field_to_update+'"]').text(' - YYYY');
            }
        });

        $(jquery_selector).each(function(){
            $(this).change();
        })


    };
}();

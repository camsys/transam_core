(function($){
    $.fn.bootstrapTransfer = function(options) {
        var settings = $.extend({}, $.fn.bootstrapTransfer.defaults, options);
        var _this;
        /* #=============================================================================== */
        /* # Expose public functions */
        /* #=============================================================================== */
        this.populate = function(input) { _this.populate(input); };
        this.set_values = function(values) { _this.set_values(values); };
        this.get_values = function() { return _this.get_values(); };
        return this.each(function(){
            _this = $(this);
            /* #=============================================================================== */
            /* # Add widget markup */
            /* #=============================================================================== */
            _this.append($.fn.bootstrapTransfer.defaults.template);
            _this.addClass("bootstrap-transfer-container");
            /* #=============================================================================== */
            /* # Initialize internal variables */
            /* #=============================================================================== */
            _this.$filter_input = _this.find('.filter-input');
            _this.$remaining_select = _this.find('select.remaining');
            _this.$target_select = _this.find('select.target');
            _this.$add_btn = _this.find('.selector-add');
            _this.$remove_btn = _this.find('.selector-remove');
            _this.$choose_all_btn = _this.find('.selector-chooseall');
            _this.$clear_all_btn = _this.find('.selector-clearall');
            _this._remaining_list = [];
            _this._target_list = [];
            /* #=============================================================================== */
            /* # Apply settings */
            /* #=============================================================================== */
            /* target_id */
            if (settings.target_id != '') _this.$target_select.attr('id', settings.target_id);
            /* height */
            _this.find('select.remaining').css('height', settings.height + 'em');
            _this.find('select.target').css('height', settings.height + 4 + 'em');
            /* #=============================================================================== */
            /* # Wire internal events */
            /* #=============================================================================== */
            _this.$add_btn.click(function(){
                _this.move_elems(_this.$remaining_select.val(), false, true);
            });
            _this.$remove_btn.click(function(){
                _this.move_elems(_this.$target_select.val(), true, false);
            });
            _this.$choose_all_btn.click(function(){
                _this.move_all(false, true);
            });
            _this.$clear_all_btn.click(function(){
                _this.move_all(true, false);
            });
            _this.$filter_input.keyup(function(){
                _this.update_lists(true);
            });
            /* #=============================================================================== */
            /* # Implement public functions */
            /* #=============================================================================== */
            _this.populate = function(input) {
                // input: [{value:_, content:_}]
                _this.$filter_input.val('');
                for (var i in input) {
                    var e = input[i];
                    _this._remaining_list.push([{value:e.value, content:e.content}, true]);
                    _this._target_list.push([{value:e.value, content:e.content}, false]);
                }
                _this.update_lists(true);
            };
            _this.set_values = function(values) {
                _this.move_elems(values, false, true);
            };
            _this.get_values = function(){
                return _this.get_internal(_this.$target_select);
            };
            /* #=============================================================================== */
            /* # Implement private functions */
            /* #=============================================================================== */
            _this.get_internal = function(selector) {
                var res = [];
                selector.find('option').each(function() {
                    res.push($(this).val());
                })
                return res;
            };
            _this.to_dict = function(list) {
                var res = {};
                for (var i in list) res[list[i]] = true;
                return res;
            }
            _this.update_lists = function(force_hilite_off) {
                var old;
                if (!force_hilite_off) {
                    old = [_this.to_dict(_this.get_internal(_this.$remaining_select)),
                           _this.to_dict(_this.get_internal(_this.$target_select))];
                }
                _this.$remaining_select.empty();
                _this.$target_select.empty();
                var lists = [_this._remaining_list, _this._target_list];
                var source = [_this.$remaining_select, _this.$target_select];
                for (var i in lists) {
                    for (var j in lists[i]) {
                        var e = lists[i][j];
                        if (e[1]) {
                            var selected = '';
                            if (!force_hilite_off && settings.hilite_selection && !old[i].hasOwnProperty(e[0].value)) {
                                selected = 'selected="selected"';
                            }
                            source[i].append('<option ' + selected + 'value=' + e[0].value + '>' + e[0].content + '</option>');
                        }
                    }
                }
                _this.$remaining_select.find('option').each(function() {
                    var inner = _this.$filter_input.val().toLowerCase();
                    var outer = $(this).html().toLowerCase();
                    if (outer.indexOf(inner) == -1) {
                        $(this).remove();
                    }
                })
            };
            _this.move_elems = function(values, b1, b2) {
                for (var i in values) {
                    val = values[i];
                    for (var j in _this._remaining_list) {
                        var e = _this._remaining_list[j];
                        if (e[0].value == val) {
                            e[1] = b1;
                            _this._target_list[j][1] = b2;
                        }
                    }
                }
                _this.update_lists(false);
            };
            _this.move_all = function(b1, b2) {
                for (var i in _this._remaining_list) {
                    _this._remaining_list[i][1] = b1;
                    _this._target_list[i][1] = b2;
                }
                _this.update_lists(false);
            };
            _this.data('bootstrapTransfer', _this);
            return _this;
        });
    };
    $.fn.bootstrapTransfer.defaults = {
        'template':                                         
            '<div id="shuttleboxes">\
              <div class="row">\
                <div class="col-md-6">\
                  <div class="selector-available">\
                    <div class="row">\
                      <h3>Not Selected</h3>\
                    </div>\
                    <div class="row">\
                      <div class="selector-filter">\
                          <div class="form-group">\
                            <div class="input-group">\
                              <div class="input-group-addon">\
                                <i class="fa fa-search"></i>\
                              </div>\
                              <input class="form-control filter-input form-control" type="text" placeholder="Search..." />\
                            </div>\
                          </div>\
                      </div>\
                    </div>\
                    <div class="row">\
                      <select class="filtered remaining form-control" multiple=true></select>\
                    </div>\
                    <div class="row">\
                      <btn class="btn btn-default selector-chooseall">\
                        Choose All\
                        <i class="fa fa-fw fa-angle-double-right"></i>\
                      </btn>\
                    </div>\
                  </div>\
                </div>\
                <div class="col-md-1" id="movers">\
                  <div class="selector-chooser">\
                    <btn class="btn btn-default selector selector-add">\
                      <i class="fa fa-fw fa-2x fa-angle-right"></i>\
                    </btn>\
                    <btn class="btn btn-default selector selector-remove">\
                      <i class="fa fa-fw fa-2x fa-angle-left"></i>\
                    </btn>\
                  </div>\
                </div>\
                <div class="col-md-5">\
                  <div class="selector-chosen">\
                    <div class="row">\
                      <h3>Selected</h3>\
                    </div>\
                    <div class="row">\
                      <select class="filtered target form-control" multiple=true></select>\
                    </div>\
                    <div class="row">\
                        <btn class="btn btn-default selector-clearall">\
                          <i class="fa fa-fw fa-angle-double-left"></i>\
                          Clear All\
                        </btn>\
                    </div>\
                  </div>\
                </div>\
              </div>\
            </div>',
        'height': 15,
        'hilite_selection': true,
        'target_id': ''
    }
})(jQuery);
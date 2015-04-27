
var _typeahead_delay = 300;
var _typeahead_timeout;
var _typeahead_source_url;
var _typeahead_item_handler = _id_name_item_handler;

// Matches all returned items. Should be the default where items are filtered
// by the controller
function _match_all_matcher(obj) {
  return 1;
};

// No prioritization in sort order. Should be the default if prioritization is
// performed by the controller
function _no_sort_sorter(items) {
  return items;
};

function _id_name_item_handler(item) {
    var aItem = { id: item.id, name: item.name };
    return JSON.stringify(aItem);
};

function _typeahead_searcher(query, process) {
  if (_typeahead_timeout) {
    clearTimeout(_typeahead_timeout);
  }
  _typeahead_timeout = setTimeout(function() {
    return $.ajax({
      url: _typeahead_source_url,
      type: 'get',
      data: {
        query: query
      },
      dataType: 'json',
      success: function(result) {
        var resultList = result.map(_typeahead_item_handler);
        return process(resultList);
      }
    });
  },
  _typeahead_delay);
};

function _typeahead_matcher(obj) {
  var item = JSON.parse(obj);
  return ~item.name.toLowerCase().indexOf(this.query.toLowerCase())
};

function _typeahead_leftmost_sorter(items) {
  var beginswith = [], caseSensitive = [], caseInsensitive = [], item;
  while (aItem = items.shift()) {
    var item = JSON.parse(aItem);
    if (!item.name.toLowerCase().indexOf(this.query.toLowerCase()))
      beginswith.push(JSON.stringify(item));
    else if (~item.name.indexOf(this.query))
      caseSensitive.push(JSON.stringify(item));
    else caseInsensitive.push(JSON.stringify(item));
  }
  return beginswith.concat(caseSensitive, caseInsensitive)
};

function _typeahead_highlighter(obj) {
  var item = JSON.parse(obj);
  var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&');
  return item.name.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
    return '<strong>' + match + '</strong>'
  });
};

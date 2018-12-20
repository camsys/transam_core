//
// Javascript for saved query
//

function SavedQuery() {
  this._selected_output_field_ids = {};
  this._selected_filter_field_ids = {};
  this._query_filters = {};

  this.getSelectedOutputFieldIdsByCategory = function(category_id) {
    return this._selected_output_field_ids[category_id] || [];
  }

  this.getSelectedFilterFieldIdsByCategory = function(category_id) {
    return this._selected_filter_field_ids[category_id] || [];
  }

  this.setSelectedOutputFieldIdsByCategory = function(category_id, field_ids) {
    return this._selected_output_field_ids[category_id] = field_ids;
  }

  this.setSelectedFilterFieldIdsByCategory = function(category_id, field_ids) {
    return this._selected_filter_field_ids[category_id] = field_ids;
  }

  this.resetOutputColumns = function() {
    this._selected_output_field_ids = {};
  }

  this.resetFilters = function() {
    this._selected_filter_field_ids = {};
    this._query_filters = {};
  }

  this.reset = function() {
    this.resetOutputColumns();
    this.resetFilters();
  }
}
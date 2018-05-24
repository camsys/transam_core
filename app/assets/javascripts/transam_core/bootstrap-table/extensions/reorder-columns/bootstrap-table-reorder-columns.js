/**
 * @author: Dennis Hernández
 * @webSite: http://djhvscf.github.io/Blog
 * @version: v1.1.0
 */

$.getScript("https://cdnjs.cloudflare.com/ajax/libs/jqgrid/4.6.0/plugins/jquery.tablednd.js", function() {});

$.getScript("https://code.jquery.com/ui/1.11.4/jquery-ui.js", function() {});

$.getScript("https://rawgit.com/akottr/dragtable/master/jquery.dragtable.js", function() {});

$.getScript("https://cdn.rawgit.com/wenzhixin/bootstrap-table/d5ccd48950a03a3f7d684358bebf1899bec4d3b0/dist/extensions/reorder-columns/bootstrap-table-reorder-columns.js", function(){});

$('<link/>', {
    rel: 'stylesheet',
    type: 'text/css',
    href: 'https://rawgit.com/akottr/dragtable/master/dragtable.css'
}).appendTo('head');
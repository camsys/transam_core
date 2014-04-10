module DatatablesHelper
  
  def datatable(columns, opts={})
    sort_by = opts[:sort_by] || nil
    additional_data = opts[:additional_data] || {}
    search = opts[:search].present? ? opts[:search].to_s : "false"
    search_label = opts[:search_label] || "Search"
    processing = opts[:processing] || "Processing"
    persist_state = opts[:persist_state].present? ? opts[:persist_state].to_s : "true"
    table_dom_id = opts[:table_dom_id] ? "##{opts[:table_dom_id]}" : ".datatable"
    per_page = opts[:per_page] || opts[:display_length]|| 10
    no_records_message = opts[:no_records_message] || nil
    auto_width = opts[:auto_width].present? ? opts[:auto_width].to_s : "true"
    row_callback = opts[:row_callback] || nil

    append = opts[:append] || nil

    ajax_source = opts[:ajax_source] || nil
    server_side = opts[:ajax_source].present?

    additional_data_string = ""
    additional_data.each_pair do |name,value|
      additional_data_string = additional_data_string + ", " if !additional_data_string.blank? && value
      additional_data_string = additional_data_string + "{'name': '#{name}', 'value':'#{value}'}" if value
    end

    %Q{
    <script type="text/javascript">
    $(function() {
        oTable = $('#{table_dom_id}').dataTable({
          "oLanguage": {
            "sLengthMenu": "_MENU_ records per page",
            "sProcessing": '#{processing}'
          },
          "sPaginationType": "bootstrap",
          "sDom": "<'row'<'col-xs-6'l><'col-xs-6'f>r>t<'row'<'col-xs-6'i><'col-cs-6'p>>",
          "iDisplayLength": #{per_page},
          "bProcessing": true,
          "bServerSide": #{server_side},
          "bLengthChange": true,
          "bStateSave": #{persist_state},
          "bFilter": #{search},
          "bAutoWidth": #{auto_width},
          "aoColumns": [
            #{formatted_columns(columns)}
              ],          
          #{"'sAjaxSource': '#{ajax_source}'," if ajax_source}
          "fnDrawCallback": function( oSettings ) {
                transam.install_quick_link_handlers();
            },
          "fnRowCallback": function( nRow, aData, iDisplayIndex ) {
              var url = aData[0];
              $(nRow).attr("data-action-path", url);
              return nRow;
          },
          "fnServerData": function ( sSource, aoData, fnCallback ) {
            aoData.push( #{additional_data_string} );
            $.getJSON( sSource, aoData, function (json) {
              fnCallback(json);
            } );
          }            
        })#{append};
        oTable.fnSetColumnVis( 0, false );
    });
    </script>
    }
  end

  private
    def formatted_columns(columns)
      i = 0
      columns.map {|c|
        i += 1
        if c.nil? or c.empty?
          "null"
        else
          searchable = c[:searchable].to_s.present? ? c[:searchable].to_s : "true"
          sortable = c[:sortable].to_s.present? ? c[:sortable].to_s : "true"

          "{
          'sType': '#{c[:type] || "string"}',
          'bSortable':#{sortable},
          'bSearchable':#{searchable}
          #{",'sClass':'#{c[:class]}'" if c[:class]}
          }"
        end
      }.join(",")
    end
  
end
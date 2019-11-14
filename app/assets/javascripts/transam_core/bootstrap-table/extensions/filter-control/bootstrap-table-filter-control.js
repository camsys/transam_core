/**
 * @author: Dennis Hernández
 * @webSite: http://djhvscf.github.io/Blog
 * @version: v2.2.0
 */

($ => {
  const Utils = $.fn.bootstrapTable.utils
  const UtilsFilterControl = {
    getOptionsFromSelectControl (selectControl) {
      return selectControl.get(selectControl.length - 1).options
    },

    hideUnusedSelectOptions (selectControl, uniqueValues) {
      const options = UtilsFilterControl.getOptionsFromSelectControl(
        selectControl
      )

      for (let i = 0; i < options.length; i++) {
        if (options[i].value !== '') {
          if (!uniqueValues.hasOwnProperty(options[i].value)) {
            selectControl
              .find(Utils.sprintf('option[value=\'%s\']', options[i].value))
              .hide()
          } else {
            selectControl
              .find(Utils.sprintf('option[value=\'%s\']', options[i].value))
              .show()
          }
        }
      }
    },
    addOptionToSelectControl (selectControl, _value, text) {
      const value = $.trim(_value)
      const $selectControl = $(selectControl.get(selectControl.length - 1))
      if (
        !UtilsFilterControl.existOptionInSelectControl(selectControl, value)
      ) {
        $selectControl.append(
          $('<option></option>')
            .attr('value', value)
            .text(
              $('<div />')
                .html(text)
                .text()
            )
        )
      }
    },
    sortSelectControl (selectControl) {
      const $selectControl = $(selectControl.get(selectControl.length - 1))
      const $opts = $selectControl.find('option:gt(0)')

      $opts.sort((a, b) => {
        let aa = $(a).text().toLowerCase()
        let bb = $(b).text().toLowerCase()
        if ($.isNumeric(a) && $.isNumeric(b)) {
          // Convert numerical values from string to float.
          aa = parseFloat(aa)
          bb = parseFloat(bb)
        }
        return aa > bb ? 1 : aa < bb ? -1 : 0
      })

      $selectControl.find('option:gt(0)').remove()
      $selectControl.append($opts)
    },
    existOptionInSelectControl (selectControl, value) {
      const options = UtilsFilterControl.getOptionsFromSelectControl(
        selectControl
      )
      for (let i = 0; i < options.length; i++) {
        if (options[i].value === value.toString()) {
          // The value is not valid to add
          return true
        }
      }

      // If we get here, the value is valid to add
      return false
    },
    fixHeaderCSS ({ $tableHeader }) {
      $tableHeader.css('height', '77px')
    },
    getCurrentHeader ({ $header, options, $tableHeader }) {
      let header = $header
      if (options.height) {
        header = $tableHeader
      }

      return header
    },
    getCurrentSearchControls ({ options }) {
      let searchControls = 'select, input'
      if (options.height) {
        searchControls = 'table select, table input'
      }

      return searchControls
    },
    getCursorPosition (el) {
      if (Utils.isIEBrowser()) {
        if ($(el).is('input[type=text]')) {
          let pos = 0
          if ('selectionStart' in el) {
            pos = el.selectionStart
          } else if ('selection' in document) {
            el.focus()
            const Sel = document.selection.createRange()
            const SelLength = document.selection.createRange().text.length
            Sel.moveStart('character', -el.value.length)
            pos = Sel.text.length - SelLength
          }
          return pos
        }
        return -1

      }
      return -1
    },
    setCursorPosition (el) {
      $(el).val(el.value)
    },
    copyValues (that) {
      const header = UtilsFilterControl.getCurrentHeader(that)
      const searchControls = UtilsFilterControl.getCurrentSearchControls(that)

      that.options.valuesFilterControl = []

      header.find(searchControls).each(function () {
        that.options.valuesFilterControl.push({
          field: $(this)
            .closest('[data-field]')
            .data('field'),
          value: $(this).val(),
          position: UtilsFilterControl.getCursorPosition($(this).get(0)),
          hasFocus: $(this).is(':focus')
        })
      })
    },
    setValues (that) {
      let field = null
      let result = []
      const header = UtilsFilterControl.getCurrentHeader(that)
      const searchControls = UtilsFilterControl.getCurrentSearchControls(that)

      if (that.options.valuesFilterControl.length > 0) {
        //  Callback to apply after settings fields values
        let fieldToFocusCallback = null
        header.find(searchControls).each(function (index, ele) {
          field = $(this)
            .closest('[data-field]')
            .data('field')
          result = that.options.valuesFilterControl.filter(valueObj => valueObj.field === field)

          if (result.length > 0) {
            $(this).val(result[0].value)
            if (result[0].hasFocus) {
              // set callback if the field had the focus.
              fieldToFocusCallback = ((fieldToFocus, carretPosition) => {
                // Closure here to capture the field and cursor position
                const closedCallback = () => {
                  fieldToFocus.focus()
                  UtilsFilterControl.setCursorPosition(fieldToFocus, carretPosition)
                }
                return closedCallback
              })($(this).get(0), result[0].position)
            }
          }
        })

        // Callback call.
        if (fieldToFocusCallback !== null) {
          fieldToFocusCallback()
        }
      }
    },
    collectBootstrapCookies () {
      const cookies = []
      const foundCookies = document.cookie.match(/(?:bs.table.)(\w*)/g)

      if (foundCookies) {
        $.each(foundCookies, (i, _cookie) => {
          let cookie = _cookie
          if (/./.test(cookie)) {
            cookie = cookie.split('.').pop()
          }

          if ($.inArray(cookie, cookies) === -1) {
            cookies.push(cookie)
          }
        })
        return cookies
      }
    },
    escapeID (id) {
      return String(id).replace(/(:|\.|\[|\]|,)/g, '\\$1')
    },
    isColumnSearchableViaSelect ({ filterControl, searchable }) {
      return filterControl &&
        filterControl.toLowerCase() === 'select' &&
        searchable
    },
    isFilterDataNotGiven ({ filterData }) {
      return filterData === undefined ||
        filterData.toLowerCase() === 'column'
    },
    hasSelectControlElement (selectControl) {
      return selectControl && selectControl.length > 0
    },
    initFilterSelectControls (that) {
      const data = that.data
      const itemsPerPage = that.pageTo < that.options.data.length ? that.options.data.length : that.pageTo
      const z = that.options.pagination
        ? that.options.sidePagination === 'server'
          ? that.pageTo
          : that.options.totalRows
        : that.pageTo

      $.each(that.header.fields, (j, field) => {
        const column = that.columns[that.fieldsColumnsIndex[field]]
        const selectControl = $(`.bootstrap-table-filter-control-${UtilsFilterControl.escapeID(column.field)}`)

        if (
          UtilsFilterControl.isColumnSearchableViaSelect(column) &&
          UtilsFilterControl.isFilterDataNotGiven(column) &&
          UtilsFilterControl.hasSelectControlElement(selectControl)
        ) {
          if (selectControl.get(selectControl.length - 1).options.length === 0) {
            // Added the default option
            UtilsFilterControl.addOptionToSelectControl(selectControl, '', column.filterControlPlaceholder)
          }

          const uniqueValues = {}
          for (let i = 0; i < z; i++) {
            // Added a new value
            const fieldValue = data[i][field]
            const formattedValue = Utils.calculateObjectValue(that.header, that.header.formatters[j], [fieldValue, data[i], i], fieldValue)

            uniqueValues[formattedValue] = fieldValue
          }

          // eslint-disable-next-line guard-for-in
          for (const key in uniqueValues) {
            UtilsFilterControl.addOptionToSelectControl(selectControl, uniqueValues[key], key)
          }

          UtilsFilterControl.sortSelectControl(selectControl)

          if (that.options.hideUnusedSelectOptions) {
            UtilsFilterControl.hideUnusedSelectOptions(selectControl, uniqueValues)
          }
        }
      })

      that.trigger('created-controls')
    },
    getFilterDataMethod (objFilterDataMethod, searchTerm) {
      const keys = Object.keys(objFilterDataMethod)
      for (let i = 0; i < keys.length; i++) {
        if (keys[i] === searchTerm) {
          return objFilterDataMethod[searchTerm]
        }
      }
      return null
    },
    createControls (that, header) {
      let addedFilterControl = false
      let isVisible
      let html

      $.each(that.columns, (i, column) => {
        isVisible = 'hidden'
        html = []

        if (!column.visible) {
          return
        }

        if (!column.filterControl) {
          html.push('<div class="no-filter-control"></div>')
        } else {
          html.push('<div class="filter-control">')

          const nameControl = column.filterControl.toLowerCase()
          if (column.searchable && that.options.filterTemplate[nameControl]) {
            addedFilterControl = true
            isVisible = 'visible'
            html.push(
              that.options.filterTemplate[nameControl](
                that,
                column.field,
                isVisible,
                column.filterControlPlaceholder
                  ? column.filterControlPlaceholder
                  : '',
                `filter-control-${i}`
              )
            )
          }
        }

        $.each(header.children().children(), (i, tr) => {
          const $tr = $(tr)
          if ($tr.data('field') === column.field) {
            $tr.find('.fht-cell').append(html.join(''))
            return false
          }
        })

        if (
          column.filterData !== undefined &&
          column.filterData.toLowerCase() !== 'column'
        ) {
          const filterDataType = UtilsFilterControl.getFilterDataMethod(
            /* eslint-disable no-use-before-define */
            filterDataMethods,
            column.filterData.substring(0, column.filterData.indexOf(':'))
          )
          let filterDataSource
          let selectControl

          if (filterDataType !== null) {
            filterDataSource = column.filterData.substring(
              column.filterData.indexOf(':') + 1,
              column.filterData.length
            )
            selectControl = $(
              `.bootstrap-table-filter-control-${UtilsFilterControl.escapeID(column.field)}`
            )

            UtilsFilterControl.addOptionToSelectControl(selectControl, '', column.filterControlPlaceholder)
            filterDataType(filterDataSource, selectControl)
          } else {
            throw new SyntaxError(
              'Error. You should use any of these allowed filter data methods: var, json, url.' +
              ' Use like this: var: {key: "value"}'
            )
          }

          let variableValues
          let key
          // eslint-disable-next-line default-case
          switch (filterDataType) {
            case 'url':
              $.ajax({
                url: filterDataSource,
                dataType: 'json',
                success (data) {
                  // eslint-disable-next-line guard-for-in
                  for (const key in data) {
                    UtilsFilterControl.addOptionToSelectControl(selectControl, key, data[key])
                  }
                  UtilsFilterControl.sortSelectControl(selectControl)
                }
              })
              break
            case 'var':
              variableValues = window[filterDataSource]
              // eslint-disable-next-line guard-for-in
              for (key in variableValues) {
                UtilsFilterControl.addOptionToSelectControl(selectControl, key, variableValues[key])
              }
              UtilsFilterControl.sortSelectControl(selectControl)
              break
            case 'jso':
              variableValues = JSON.parse(filterDataSource)
              // eslint-disable-next-line guard-for-in
              for (key in variableValues) {
                UtilsFilterControl.addOptionToSelectControl(selectControl, key, variableValues[key])
              }
              UtilsFilterControl.sortSelectControl(selectControl)
              break
          }
        }
      })

      if (addedFilterControl) {
        header.off('keyup', 'input').on('keyup', 'input', (event, obj) => {
          // Simulate enter key action from clear button
          event.keyCode = obj ? obj.keyCode : event.keyCode

          if (that.options.searchOnEnterKey && event.keyCode !== 13) {
            return
          }

          if ($.inArray(event.keyCode, [37, 38, 39, 40]) > -1) {
            return
          }

          const $currentTarget = $(event.currentTarget)

          if ($currentTarget.is(':checkbox') || $currentTarget.is(':radio')) {
            return
          }

          clearTimeout(event.currentTarget.timeoutId || 0)
          event.currentTarget.timeoutId = setTimeout(() => {
            that.onColumnSearch(event)
          }, that.options.searchTimeOut)
        })

        header.off('change', 'select').on('change', 'select', event => {
          if (that.options.searchOnEnterKey && event.keyCode !== 13) {
            return
          }

          if ($.inArray(event.keyCode, [37, 38, 39, 40]) > -1) {
            return
          }

          clearTimeout(event.currentTarget.timeoutId || 0)
          event.currentTarget.timeoutId = setTimeout(() => {
            that.onColumnSearch(event)
          }, that.options.searchTimeOut)
        })

        header.off('mouseup', 'input').on('mouseup', 'input', function (event) {
          const $input = $(this)
          const oldValue = $input.val()

          if (oldValue === '') {
            return
          }

          setTimeout(() => {
            const newValue = $input.val()

            if (newValue === '') {
              clearTimeout(event.currentTarget.timeoutId || 0)
              event.currentTarget.timeoutId = setTimeout(() => {
                that.onColumnSearch(event)
              }, that.options.searchTimeOut)
            }
          }, 1)
        })

        if (header.find('.date-filter-control').length > 0) {
          $.each(that.columns, (i, { filterControl, field, filterDatepickerOptions }) => {
            if (
              filterControl !== undefined &&
              filterControl.toLowerCase() === 'datepicker'
            ) {
              header
                .find(
                  `.date-filter-control.bootstrap-table-filter-control-${field}`
                )
                .datepicker(filterDatepickerOptions)
                .on('changeDate', ({ currentTarget }) => {
                  $(currentTarget).val(
                    currentTarget.value
                  )
                  // Fired the keyup event
                  $(currentTarget).keyup()
                })
            }
          })
        }
      } else {
        header.find('.filterControl').hide()
      }
    },
    getDirectionOfSelectOptions (_alignment) {
      const alignment = _alignment === undefined ? 'left' : _alignment.toLowerCase()

      switch (alignment) {
        case 'left':
          return 'ltr'
        case 'right':
          return 'rtl'
        case 'auto':
          return 'auto'
        default:
          return 'ltr'
      }
    }
  }
  const filterDataMethods = {
    var (filterDataSource, selectControl) {
      const variableValues = window[filterDataSource]
      // eslint-disable-next-line guard-for-in
      for (const key in variableValues) {
        UtilsFilterControl.addOptionToSelectControl(selectControl, key, variableValues[key])
      }
      UtilsFilterControl.sortSelectControl(selectControl)
    },
    url (filterDataSource, selectControl) {
      $.ajax({
        url: filterDataSource,
        dataType: 'json',
        success (data) {
          // eslint-disable-next-line guard-for-in
          for (const key in data) {
            UtilsFilterControl.addOptionToSelectControl(selectControl, key, data[key])
          }
          UtilsFilterControl.sortSelectControl(selectControl)
        }
      })
    },
    json (filterDataSource, selectControl) {
      const variableValues = JSON.parse(filterDataSource)
      // eslint-disable-next-line guard-for-in
      for (const key in variableValues) {
        UtilsFilterControl.addOptionToSelectControl(selectControl, key, variableValues[key])
      }
      UtilsFilterControl.sortSelectControl(selectControl)
    }
  }

  const bootstrap = {
    3: {
      icons: {
        clear: 'glyphicon-trash icon-clear'
      }
    },
    4: {
      icons: {
        clear: 'fa-trash icon-clear'
      }
    }
  }[Utils.bootstrapVersion]

  $.extend($.fn.bootstrapTable.defaults, {
    filterControl: false,
    onColumnSearch (field, text) {
      return false
    },
    onCreatedControls () {
      return true
    },
    filterShowClear: false,
    alignmentSelectControlOptions: undefined,
    filterTemplate: {
      input (that, field, isVisible, placeholder) {
        return Utils.sprintf(
          '<input type="text" class="form-control bootstrap-table-filter-control-%s" style="width: 100%; visibility: %s" placeholder="%s">',
          field,
          isVisible,
          placeholder
        )
      },
      select ({ options }, field, isVisible) {
        return Utils.sprintf(
          '<select class="form-control bootstrap-table-filter-control-%s" style="width: 100%; visibility: %s" dir="%s"></select>',
          field,
          isVisible,
          UtilsFilterControl.getDirectionOfSelectOptions(
            options.alignmentSelectControlOptions
          )
        )
      },
      datepicker (that, field, isVisible) {
        return Utils.sprintf(
          '<input type="text" class="form-control date-filter-control bootstrap-table-filter-control-%s" style="width: 100%; visibility: %s">',
          field,
          isVisible
        )
      }
    },
    disableControlWhenSearch: false,
    searchOnEnterKey: false,
    // internal variables
    valuesFilterControl: []
  })

  $.extend($.fn.bootstrapTable.columnDefaults, {
    filterControl: undefined,
    filterData: undefined,
    filterDatepickerOptions: undefined,
    filterStrictSearch: false,
    filterStartsWithSearch: false,
    filterControlPlaceholder: ''
  })

  $.extend($.fn.bootstrapTable.Constructor.EVENTS, {
    'column-search.bs.table': 'onColumnSearch',
    'created-controls.bs.table': 'onCreatedControls'
  })

  $.extend($.fn.bootstrapTable.defaults.icons, {
    clear: bootstrap.icons.clear
  })

  $.extend($.fn.bootstrapTable.locales, {
    formatClearFilters () {
      return 'Clear Filters'
    }
  })

  $.extend($.fn.bootstrapTable.defaults, $.fn.bootstrapTable.locales)

  $.fn.bootstrapTable.methods.push('triggerSearch')
  $.fn.bootstrapTable.methods.push('clearFilterControl')

  $.BootstrapTable = class extends $.BootstrapTable {
    init () {
      // Make sure that the filterControl option is set
      if (this.options.filterControl) {
        const that = this

        // Make sure that the internal variables are set correctly
        this.options.valuesFilterControl = []

        this.$el
          .on('reset-view.bs.table', () => {
            // Create controls on $tableHeader if the height is set
            if (!that.options.height) {
              return
            }

            // Avoid recreate the controls
            if (
              that.$tableHeader.find('select').length > 0 ||
              that.$tableHeader.find('input').length > 0
            ) {
              return
            }

            UtilsFilterControl.createControls(that, that.$tableHeader)
          })
          .on('post-header.bs.table', () => {
            UtilsFilterControl.setValues(that)
          })
          .on('post-body.bs.table', () => {
            if (that.options.height) {
              UtilsFilterControl.fixHeaderCSS(that)
            }
          })
          .on('column-switch.bs.table', () => {
            UtilsFilterControl.setValues(that)
          })
          .on('load-success.bs.table', () => {
            that.EnableControls(true)
          })
          .on('load-error.bs.table', () => {
            that.EnableControls(true)
          })
      }

      super.init()
    }

    initToolbar () {
      this.showToolbar =
        this.showToolbar ||
        (this.options.filterControl && this.options.filterShowClear)

      super.initToolbar()

      if (this.options.filterControl && this.options.filterShowClear) {
        const $btnGroup = this.$toolbar.find('>.btn-group')
        let $btnClear = $btnGroup.find('.filter-show-clear')

        if (!$btnClear.length) {
          $btnClear = $(
            [
              Utils.sprintf(
                '<button class="btn btn-%s filter-show-clear" ',
                this.options.buttonsClass
              ),
              Utils.sprintf(
                'type="button" title="%s">',
                this.options.formatClearFilters()
              ),
              Utils.sprintf(
                '<i class="%s %s"></i> ',
                this.options.iconsPrefix,
                this.options.icons.clear
              ),
              '</button>'
            ].join('')
          ).appendTo($btnGroup)

          $btnClear
            .off('click')
            .on('click', $.proxy(this.clearFilterControl, this))
        }
      }
    }

    initHeader () {
      super.initHeader()

      if (!this.options.filterControl) {
        return
      }
      UtilsFilterControl.createControls(this, this.$header)
    }
    initBody () {
      super.initBody()

      UtilsFilterControl.initFilterSelectControls(this)
    }

    initSearch () {
      const that = this
      const fp = $.isEmptyObject(that.filterColumnsPartial)
        ? null
        : that.filterColumnsPartial

      if (fp === null || Object.keys(fp).length <= 1) {
        super.initSearch()
      }

      if (this.options.sidePagination === 'server') {
        return
      }

      if (fp === null) {
        return
      }

      // Check partial column filter
      that.data = fp
        ? that.options.data.filter((item, i) => {
          const itemIsExpected = []
          Object.keys(item).forEach((key, index) => {
            const thisColumn = that.columns[that.fieldsColumnsIndex[key]]
            const fval = (fp[key] || '').toLowerCase()
            let value = item[key]

            if (fval === '') {
              itemIsExpected.push(true)
            } else {
              // Fix #142: search use formated data
              if (thisColumn && thisColumn.searchFormatter) {
                value = $.fn.bootstrapTable.utils.calculateObjectValue(
                  that.header,
                  that.header.formatters[$.inArray(key, that.header.fields)],
                  [value, item, i],
                  value
                )
              }

              if ($.inArray(key, that.header.fields) !== -1) {
                if (typeof value === 'string' || typeof value === 'number') {
                  if (thisColumn.filterStrictSearch) {
                    if (value.toString().toLowerCase() === fval.toString().toLowerCase()) {
                      itemIsExpected.push(true)
                    } else {
                      itemIsExpected.push(false)
                    }
                  } else if (thisColumn.filterStartsWithSearch) {
                    if ((`${value}`).toLowerCase().indexOf(fval) === 0) {
                      itemIsExpected.push(true)
                    } else {
                      itemIsExpected.push(false)
                    }
                  } else {
                    if ((`${value}`).toLowerCase().includes(fval)) {
                      itemIsExpected.push(true)
                    } else {
                      itemIsExpected.push(false)
                    }
                  }
                }
              }
            }
          })

          return !itemIsExpected.includes(false)
        })
        : that.data
    }

    initColumnSearch (filterColumnsDefaults) {
      UtilsFilterControl.copyValues(this)

      if (filterColumnsDefaults) {
        this.filterColumnsPartial = filterColumnsDefaults
        this.updatePagination()

        // eslint-disable-next-line guard-for-in
        for (const filter in filterColumnsDefaults) {
          this.trigger('column-search', filter, filterColumnsDefaults[filter])
        }
      }
    }

    onColumnSearch (event) {
      if ($.inArray(event.keyCode, [37, 38, 39, 40]) > -1) {
        return
      }

      UtilsFilterControl.copyValues(this)
      const text = $.trim($(event.currentTarget).val())
      const $field = $(event.currentTarget)
        .closest('[data-field]')
        .data('field')

      if ($.isEmptyObject(this.filterColumnsPartial)) {
        this.filterColumnsPartial = {}
      }
      if (text) {
        this.filterColumnsPartial[$field] = text
      } else {
        delete this.filterColumnsPartial[$field]
      }

      // if the searchText is the same as the previously selected column value,
      // bootstrapTable will not try searching again (even though the selected column
      // may be different from the previous search).  As a work around
      // we're manually appending some text to bootrap's searchText field
      // to guarantee that it will perform a search again when we call this.onSearch(event)
      this.searchText += 'randomText'

      this.options.pageNumber = 1
      this.EnableControls(false)
      this.onSearch(event)
      this.trigger('column-search', $field, text)
    }

    clearFilterControl () {
      if (this.options.filterControl && this.options.filterShowClear) {
        const that = this
        const cookies = UtilsFilterControl.collectBootstrapCookies()
        const header = UtilsFilterControl.getCurrentHeader(that)
        const table = header.closest('table')
        const controls = header.find(UtilsFilterControl.getCurrentSearchControls(that))
        const search = that.$toolbar.find('.search input')
        let hasValues = false
        let timeoutId = 0

        $.each(that.options.valuesFilterControl, (i, item) => {
          hasValues = hasValues ? true : item.value !== ''
          item.value = ''
        })

        UtilsFilterControl.setValues(that)

        // clear cookies once the filters are clean
        clearTimeout(timeoutId)
        timeoutId = setTimeout(() => {
          if (cookies && cookies.length > 0) {
            $.each(cookies, (i, item) => {
              if (that.deleteCookie !== undefined) {
                that.deleteCookie(item)
              }
            })
          }
        }, that.options.searchTimeOut)

        // If there is not any value in the controls exit this method
        if (!hasValues) {
          return
        }

        // Clear each type of filter if it exists.
        // Requires the body to reload each time a type of filter is found because we never know
        // which ones are going to be present.
        if (controls.length > 0) {
          this.filterColumnsPartial = {}
          $(controls[0]).trigger(
            controls[0].tagName === 'INPUT' ? 'keyup' : 'change', { keyCode: 13 }
          )
        } else {
          return
        }

        if (search.length > 0) {
          that.resetSearch()
        }

        // use the default sort order if it exists. do nothing if it does not
        if (
          that.options.sortName !== table.data('sortName') ||
          that.options.sortOrder !== table.data('sortOrder')
        ) {
          const sorter = header.find(
            Utils.sprintf(
              '[data-field="%s"]',
              $(controls[0])
                .closest('table')
                .data('sortName')
            )
          )
          if (sorter.length > 0) {
            that.onSort({ type: 'keypress', currentTarget: sorter })
            $(sorter)
              .find('.sortable')
              .trigger('click')
          }
        }
      }
    }

    triggerSearch () {
      const header = UtilsFilterControl.getCurrentHeader(this)
      const searchControls = UtilsFilterControl.getCurrentSearchControls(this)

      header.find(searchControls).each(function () {
        const el = $(this)
        if (el.is('select')) {
          el.change()
        } else {
          el.keyup()
        }
      })
    }

    EnableControls (enable) {
      if (
        this.options.disableControlWhenSearch &&
        this.options.sidePagination === 'server'
      ) {
        const header = UtilsFilterControl.getCurrentHeader(this)
        const searchControls = UtilsFilterControl.getCurrentSearchControls(this)

        if (!enable) {
          header.find(searchControls).prop('disabled', 'disabled')
        } else {
          header.find(searchControls).removeProp('disabled')
        }
      }
    }
  }
})(jQuery)

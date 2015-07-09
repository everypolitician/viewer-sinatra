(function ($) {

  $.fn.fixedThead = function() {

    // Call this on a <thead> element and it'll stay attached
    // to the top of the window when you scroll down.

    var calculateCloneDimensions = function calculateCloneDimensions($originalThead, $cloneThead){
      $cloneThead.css({
        width: $originalThead.outerWidth()
      });

      $('tr', $originalThead).each(function(tr_index, tr){
        $('th', tr).each(function(th_index, th){
          $cloneThead.find('tr:eq(' + tr_index + ') th:eq(' + th_index + ')').css({
            width: $(th).outerWidth()
          });
        });
      });
    }

    var showOrHideClone = function showOrHideClone($table, $cloneThead){
      var bounds = $table[0].getBoundingClientRect();

      // First we detect whether *any* of the table is visible,
      // then, if it is, we position the fixed thead so that it
      // never extends outside of the table bounds even when the
      // visible portion of the table is shorter than the thead.

      if(bounds.top <= 0 && bounds.bottom >= 0){
        $cloneThead.show();

        var rowHeight = $cloneThead.outerHeight();
        if(bounds.bottom < rowHeight){
          $cloneThead.css({
            top: (rowHeight - bounds.bottom) * -1
          });
        } else {
          $cloneThead.css({
            top: 0
          });
        }

      } else {
        $cloneThead.hide();
      }
    }

    return this.each(function() {
      var $originalThead = $(this);
      var $table = $originalThead.parent('table');
      var $cloneThead = $originalThead.clone().removeClass('js-fixed-thead').addClass('js-fixed-thead__clone');

      $cloneThead.insertAfter($originalThead);
      $cloneThead.hide();

      calculateCloneDimensions($originalThead, $cloneThead);
      showOrHideClone($table, $cloneThead);

      $(window).resize(function(){
        calculateCloneDimensions($originalThead, $cloneThead);
        showOrHideClone($table, $cloneThead);
      });

      $(window).scroll(function(){
        showOrHideClone($table, $cloneThead);
      });
    });

  };

}(jQuery));

(function ($) {

  $.fn.sortable = function() {

    // Call this on a <table> and it'll make all the columns sortable.

    var sortTable = function sortTable($table, columnIndex){
      // Find the rows to sort, and their parent
      var $tbody = $table.children('tbody');
      if($tbody.length == 0){ $tbody = $table; }
      var $trs = $tbody.children('tr');

      if(!$table.data('unrowspanned')){
        undoRowspans($table, $trs);
      }

      // Sort the right way, based on the state stored in $table.data
      var currentSortOrder = $table.data('sortOrder');
      if(columnIndex == $table.data('sortedOnColumnIndex')){
        if(currentSortOrder == 'a-z'){
          sortRows($tbody, $trs, columnIndex, 'z-a');
          showSortOrder($table, columnIndex, 'z-a');
          $table.data('sortOrder', 'z-a');
        } else if(currentSortOrder == 'z-a'){
          restoreOriginalSortOrder($tbody, $trs);
          showSortOrder($table);
          $table.removeData('sortOrder');
          $table.removeData('sortedOnColumnIndex');
        }
      } else {
        sortRows($tbody, $trs, columnIndex, 'a-z');
        showSortOrder($table, columnIndex, 'a-z');
        $table.data('sortOrder', 'a-z');
        $table.data('sortedOnColumnIndex', columnIndex);
      }
    }

    var undoRowspans = function undoRowspans($table, $trs){
      // Loop through each row, finding rowspanned cells
      $trs.each(function(row_index){
        var $tr = $(this);
        $tr.children('td[rowspan]').each(function(){
          var $td = $(this);
          var span = parseInt($td.attr('rowspan'));
          var col_index = $td.prevAll().length;
          if(span > 1){
            // Found one! Unrowspan it, and insert clones of the cell
            // in the same position on subsequent rows.
            $td.removeAttr('rowspan');
            $tr.nextAll().slice(0, span - 1).each(function(){
              var $newTr = $(this);
              var $clone = $td.clone(); // creates a new clone for each row
              $clone.insertBefore($newTr.children('td').eq(col_index));
            });
          }
        })
      });
      $table.data('unrowspanned', true);
    }

    var sortRows = function sortRows($tbody, $trs, columnIndex, sortOrder){
      $trs.detach().sort(function(rowA, rowB){
        var valueA = $(rowA).children('td').eq(columnIndex).text();
        var valueB = $(rowB).children('td').eq(columnIndex).text();

        var moveUp = 1;
        var moveDown = -1;
        if(sortOrder == 'z-a'){
          var moveUp = -1;
          var moveDown = 1;
        }

        if(valueA > valueB) {
          return moveUp;
        } else if(valueA < valueB){
          return moveDown;
        } else {
          return 0;
        }
      }).appendTo($tbody);
    }

    var restoreOriginalSortOrder = function restoreOriginalSortOrder($tbody, $trs){
      $trs.detach().sort(function(rowA, rowB){
        var valueA = $(rowA).data('originalSortOrder');
        var valueB = $(rowB).data('originalSortOrder');

        if(valueA > valueB) {
          return 1;
        } else if(valueA < valueB){
          return -1;
        } else {
          return 0;
        }
      }).appendTo($tbody);
    }

    var showSortOrder = function showSortOrder($table, columnIndex, sortOrder){
      $table.find('th').removeClass('sortedUp sortedDown');

      if(typeof columnIndex !== 'undefined'){
        // For compatibility with $.fixedThead() we
        // can't assume there is only row of thead cells.
        var $ths = $table.find('th:nth-child(' + (columnIndex+1) + ')');

        if(sortOrder == 'a-z'){
          $ths.addClass('sortedDown');
        } else if(sortOrder == 'z-a'){
          $ths.addClass('sortedUp');
        }
      }
    }

    var saveOriginalSortOrder = function saveOriginalSortOrder($table){
      $table.find('tr').each(function(i){
        $(this).data('originalSortOrder', i);
      });
    }

    return this.each(function() {
      var $table = $(this);

      saveOriginalSortOrder($table);

      $table.on('click', 'thead th', function(){
        var eq = $(this).prevAll().length;
        sortTable($table, eq);
      });
    });

  };

}(jQuery));

$(function(){
  $('.js-fixed-thead').fixedThead();

  $('.js-sortable').sortable();

  $('.js-navigation-menu').on('change', function(){
    window.location.href = $(this).val();
  });

  $('html').removeClass('no-js');

  // http://baymard.com/labs/country-selector
  $('.js-select-to-autocomplete').selectToAutocomplete().on('change', function(){
    // Assumes the <option>'s `value` attribute is a URL slug for the country
    window.location.href = '/' + $(this).val() + '/';
  }).on('focus', function(){
    $(this).next().trigger("focus");
  });

  $('label[for="country-selector"]').on('click', function(e){
    e.preventDefault();
    $('#country-selector').siblings('.ui-autocomplete-input').focus();
  });
});
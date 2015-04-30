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

$(function(){
  $('.js-fixed-thead').fixedThead();
});
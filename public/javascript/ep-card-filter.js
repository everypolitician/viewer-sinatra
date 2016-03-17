(function ($) {
  $.fn.containsText = function(searchFor) {
    var found = false;
    this.each(function() {
      // :TODO: .text() here will include any content inside <noscript> elements!!
      if( $(this).text().toUpperCase().indexOf(searchFor.toUpperCase()) > -1 ){
        found = true;
      }
    });
    return found;
  }
}(jQuery));

$(document).ready(function() {
  $('.js-filter-input').show().on('keyup', function(e) {
    var searchFor = $(this).val();

    if( searchFor === '' ){
      // They've emptied the search input,
      // so we reset back to default state.
      $('.js-filter-target--hidden').removeClass('js-filter-target--hidden');
      $('.js-person-card__section--visible').removeClass('js-person-card__section--visible');

    } else {
      // They've entered some search text,
      // so we show/hide each target on the page.
      $('.js-filter-target').each(function(){
        var $target = $(this);
        if( $target.containsText(searchFor) ){
          $target.removeClass('js-filter-target--hidden');
        } else {
          $target.addClass('js-filter-target--hidden');
        }

        // Person cards contain sections, which might be hidden.
        // We want to temporarily reveal sections which contain
        // the search text, if those sections exist.
        $target.find('.person-card__section').each(function(){
          var $section = $(this);
          if( $section.containsText(searchFor) ){
            $section.addClass('js-person-card__section--visible');
          } else {
            $section.removeClass('js-person-card__section--visible');
          }
        });
      });
    }

    // Other scripts might want to do something special once they know
    // the page has been filtered (eg: might want to check the viewport
    // for new images to be lazy-loaded).
    $(document).trigger('js-filter-input:complete');
  });
});

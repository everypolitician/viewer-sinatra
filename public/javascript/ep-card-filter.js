$(document).ready(function() {
  $('.js-filter-input').show().on('keyup', function(e) {
    var searchFor = $(this).val();
    if( searchFor === '' ){
        $('.js-filter-target--hidden').removeClass('js-filter-target--hidden');
    } else {
        $('.js-filter-target').each(function(){
            if( $(this).text().toUpperCase().indexOf(searchFor.toUpperCase()) < 0 ){
                $(this).addClass('js-filter-target--hidden');
            } else {
                $(this).removeClass('js-filter-target--hidden');
            }
        });
    }
    // Other scripts might want to do something special once they know
    // the page has been filtered (eg: might want to check the viewport
    // for new images to be lazy-loaded).
    $(document).trigger('js-filter-input:complete');
  });
});

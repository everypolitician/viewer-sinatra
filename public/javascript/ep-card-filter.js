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

  // Inverse of $.param()
  // http://stackoverflow.com/a/26849194/3096375
  $.deparam = function(str) {
    return str.split('&').reduce(function(params, param) {
      var paramSplit = param.split('=').map(function (value) {
        return decodeURIComponent(value.replace('+', ' '));
      });
      params[paramSplit[0]] = paramSplit[1];
      return params;
    }, {});
  }
}(jQuery));


var CardFilter = function(){

  // When the UI is in its default position,
  // this is what the state should look like.
  var defaultState = {
    facet: "bio",
    search: undefined,
    party: undefined
  }

  // Private object to store the current state.
  var state = {}

  // For debug purposes only!!
  this._getState = function(){
    return state;
  }

  // Get state from the URL hash, and fall back to
  // the defaultState if values are missing.
  // Note: This will erase all internally stored state!
  this._loadState = function(){
    state = {};
    $.extend(
      true,
      state,
      defaultState,
      $.deparam( window.location.hash.substr(1) )
    );
  }

  // Update the URL hash to reflect the
  // internal state, minus any defaults.
  this.saveState = function(){

    // Construct a version of the internal state,
    // with all the default values removed.
    // (Makes for cleaner URL fragments!)
    var copyOfState = $.extend(
      true,
      {},
      state
    );
    $.each(copyOfState, function(key, value){
      if( defaultState[key] == value ){
        delete copyOfState[key];
      }
    });

    // If there is any state left after the defaults
    // have been removed, construct a hash fragment.
    if( ! $.isEmptyObject(copyOfState) ){
      var newFragment = '#' + $.param(copyOfState);
    } else {
      var newFragment = '';
    }

    if (history.pushState) {
      if(newFragment){
        window.history.pushState(null, null, newFragment);
      } else {
        window.history.pushState(null, null, window.location.pathname + window.location.search);
      }
    } else {
      window.location.hash = newFragment;
    }
  }

  // Update the UI based on the current state.
  // Should be completely idempotent and shouldn't assume any existing UI state.
  this._updateUI = function(){

    $('[data-active-section]').attr('data-active-section', state.facet);
    $('.js-show-facet').val(state.facet);

    if( typeof state.search === 'undefined' ){
      $('.js-filter-target--hidden').removeClass('js-filter-target--hidden');
      $('.js-person-card__section--visible').removeClass('js-person-card__section--visible');
      $('.js-filter-input').val('');

    } else {
      $('.js-filter-target').each(function(){
        var $target = $(this);
        if( $target.containsText(state.search) ){
          $target.removeClass('js-filter-target--hidden');
        } else {
          $target.addClass('js-filter-target--hidden');
        }

        // Person cards contain sections, which might be hidden.
        // We want to temporarily reveal sections which contain
        // the search text, if those sections exist.
        $target.find('.person-card__section').each(function(){
          var $section = $(this);
          if( $section.containsText(state.search) ){
            $section.addClass('js-person-card__section--visible');
          } else {
            $section.removeClass('js-person-card__section--visible');
          }
        });
      });

      $('.js-filter-input').val(state.search);
    }

    // Other scripts might want to do something special once they know
    // the page has been filtered (eg: might want to check the viewport
    // for new images to be lazy-loaded).
    $(document).trigger('js-card-filter:updated');
  }

  this.setFacet = function(newFacet, autoSave){
    state.facet = newFacet;
    if(autoSave != false){
      this.saveState();
    }
    this._updateUI();
  }

  this.setSearch = function(newSearch, autoSave){
    if($.trim(newSearch) == ''){
      // Empty search string acts like no search at all
      newSearch = undefined;
    }
    state.search = newSearch;
    if(autoSave != false){
      this.saveState();
    }
    this._updateUI();
  }

  this.setParty = function(newParty, autoSave){
    state.party = newParty;
    if(autoSave != false){
      this.saveState();
    }
    this._updateUI();
  }

  // Do intial setup, the first time `new CardFilter()` is created.
  this._loadState();
  this._updateUI();

  // Listen for changes to the URL hash.
  var _this = this;
  window.onhashchange = function(){
    _this._loadState();
    _this._updateUI();
  }

}


$(document).ready(function(){

  if( $('.person-card').length ){
    window.cards = new CardFilter();

    $('.js-filter-input').show().on('keyup', function(e) {
      // We pass `false` into setSearch to update the UI and internal state
      // without saving the state to the URL hash (since we don't want a new
      // history state for each letter the user types).
      window.cards.setSearch( $(this).val(), false );
    }).on('blur', function(){
      // Now they have finished typing, we manually tell the cardFilter to
      // save its state to the URL hash, creating a new history entry.
      window.cards.saveState();
    });

    $('.js-show-facet').on('change', function(){
      var section = $(this).val();
      window.cards.setFacet(section);
    });
  }

});

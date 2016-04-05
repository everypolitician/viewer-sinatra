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

    // Unhide all the cards.
    $('.js-filter-target--hidden').removeClass('js-filter-target--hidden');

    // Remove any section visibility overrides from the previous search filter.
    $('.js-person-card__section--visible').removeClass('js-person-card__section--visible');

    // Reset the facet toggle triggers.
    $('[data-section-toggle]').removeClass('section-toggle--selected');
    $('[data-section-toggle="' + state.facet + '"]').addClass('section-toggle--selected');

    // Reset the party filter triggers.
    $('[data-party-filter-active]').removeAttr('data-party-filter-active');
    if( typeof state.party !== 'undefined' ){
      $('[data-party-filter="' + state.party + '"]').attr('data-party-filter-active', true);
    }

    // Reset the search text input.
    if( typeof state.search === 'undefined' ){
      $('.js-filter-input').val('');
    } else {
      $('.js-filter-input').val(state.search);
    }

    // Switch on correct facet (ie: the light green section on each person card).
    $('[data-active-section]').attr('data-active-section', state.facet);

    // Hide cards if they don't match the current state.party or state.search.
    $('.js-filter-target').each(function(){
      var $target = $(this);

      if( typeof state.party !== 'undefined' ){
        var partyIDs = $target.attr('data-parties').split(' ');
        if( partyIDs.indexOf(state.party) < 0 ){
          $target.addClass('js-filter-target--hidden');
          return true; // Tell $.each() to move on to the next card.
        }
      }

      if( typeof state.search !== 'undefined' ){
        if( ! $target.containsText(state.search) ){
          $target.addClass('js-filter-target--hidden');
          return true; // Tell $.each() to move on to the next card.
        }

        // This person card matches the search text! Temporarily reveal
        // any hidden person card sections containing the search text.
        $target.find('.person-card__section').each(function(){
          if( $(this).containsText(state.search) ){
            $(this).addClass('js-person-card__section--visible');
          }
        });
      }
    });

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

var scrollToTheCards = function scrollToTheCards(){
  var scrollTop = $('.js-filter-target').parents('.page-section').position().top;
  $('html, body').animate({ scrollTop: scrollTop });
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

    $('[data-section-toggle]').on('click', function(){
      var section = $(this).attr('data-section-toggle');
      window.cards.setFacet(section);
      scrollToTheCards();
    });

    $('[data-party-filter]').on('click', function(){
      var alreadyActive = $(this).is('[data-party-filter-active]');
      if(alreadyActive){
        window.cards.setParty(undefined);
      } else {
        var partyID = $(this).attr('data-party-filter');
        window.cards.setParty(partyID);
      }
      scrollToTheCards();
    });

  }

});


// via https://css-tricks.com/snippets/jquery/make-jquery-contains-case-insensitive/
$.expr[":"].case_insensitive_contains = $.expr.createPseudo(function(arg) {
  return function( elem ) {
    return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
  };
});


$(document).ready(function() {
  $("input#card-filter").show().keyup(function(e) { 
    var searchFor = $(this).val();
    $(".person-card").hide();
    $(".person-card:case_insensitive_contains('" + searchFor + "')").show();
  });
});



$(document).ready(function() {
	function trackEvent(str){
		console.log("Tracking event: "+str)
	}

	$("#term-navigation__prev, #term-navigation__next, #term-table-download-button").click(function(event){
		trackTermTableEvent(String(event.target.id))
	})

	// TODO: how the hell do I get the IDs of these?

	$("#section-toggle-social").click(function(){
		trackTermTableEvent('#section-toggle-social')
	})

	$("#section-toggle-bio").click(function(){
		trackTermTableEvent('#section-toggle-social')
	})

	$("#section-toggle-contacts").click(function(event){
		trackTermTableEvent('#section-toggle-contacts')
	})

	$("#section-toggle-identifiers").click(function(event){
		trackTermTableEvent('#section-toggle-identifiers')
	})

	$('#term-navigation__menu').change(function() {
		trackTermTableEvent('#term-navigation__menu')
	})

	// $('#filter-input').change(function() {
	// 	alert('Filter box!')
	// })

	function trackTermTableEvent(label){
		alert('Tracking event!')
		// ga('send', {
		//   hitType: 'event',
		//   eventCategory: 'User interaction',
		//   eventAction: 'click - term table',
		//   eventLabel: label
		// })
	}
})
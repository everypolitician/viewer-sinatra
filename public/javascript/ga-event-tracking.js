$(document).ready(function() {
	$('[data-ga-track-click]').on('click', function(){ 
		trackClick( $(this).attr('data-ga-track-click') ) 
	})
})

function trackClick(eventDescription){
	eventDescription = eventDescription || 'Undescribed event.'
	ga('send', 'event', 'user interaction', eventDescription, document.title)
}
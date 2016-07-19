$(document).ready(function() {
	var elements = document.getElementsByClassName("track-event")
	for (var i = 0; i < elements.length; i++) {
		(function(i){
			elements[i].addEventListener('click', function(){
				trackEvent(elements[i].getAttribute('ga-description'))
			})
		})(i)
	}
})

function trackEvent(eventDescription){
	eventDescription = eventDescription || 'Undescribed event.'
	ga('send', 'event', 'user interaction', eventDescription, document.title)
}
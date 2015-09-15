markers = [];

function mapLocation(startingLat, startingLng, type) {
	mapOptions = {
		center: new google.maps.LatLng(startingLat, startingLng),
		zoom: 15
	};

	map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

	var input = document.getElementById('activity_location');

	var autocomplete = new google.maps.places.Autocomplete(input);

	infowindow = new google.maps.InfoWindow();

	markPlaces(type)


	google.maps.event.addListener(autocomplete, 'place_changed', function () {
		var place = autocomplete.getPlace();

  	var marker = new google.maps.Marker({
  		map: map,
  		anchorPoint: new google.maps.Point(0,-29)
  	})
    markers.push(marker);
		marker.setVisible(false);

		if (!place.geometry) {
			console.log("No geometry")
			return
		}

		if (place.geometry.viewport) {
			map.fitBounds(place.geometry.viewport)
		} else {
			map.setCenter(place.geometry.location);
			map.setZoom(17);
		}

		marker.setIcon(/** @type {google.maps.Icon} */({
			url: place.icon,
			size: new google.maps.Size(71, 71),
      origin: new google.maps.Point(0, 0),
      anchor: new google.maps.Point(17, 34),
      scaledSize: new google.maps.Size(35, 35)
		}));
		marker.setPosition(place.geometry.location);
		marker.setVisible(true);
		$('#activity_latitude').val(place.geometry.location.lat());
		$('#activity_longitude').val(place.geometry.location.lng());
	})
}

$(document).on('click', '.suggested button', function() {
	var item = $(this);

  var service = new google.maps.places.PlacesService(map)

  service.getDetails({
    placeId: item.data().placeid
  }, function (place, status) {
    if (status === google.maps.places.PlacesServiceStatus.OK) {
      var marker = new google.maps.Marker({
        map: map,
        position: place.geometry.location
      });
      markers.push(marker)

      if (place.geometry.viewport) {
        map.fitBounds(place.geometry.viewport)
      } else {
        map.setCenter(place.geometry.location);
        map.setZoom(17);
      }

      marker.setIcon(/** @type {google.maps.Icon} */({
        url: place.icon,
        size: new google.maps.Size(71, 71),
        origin: new google.maps.Point(0, 0),
        anchor: new google.maps.Point(17, 34),
        scaledSize: new google.maps.Size(35, 35)
      }));

      $('#activity_location').val(place.name)
    	$('#activity_latitude').val(place.geometry.location.lat());
    	$('#activity_longitude').val(place.geometry.location.lat());
    }
  })
})

function markPlaces(type) {
	var request = {
		location: mapOptions.center,
		types: [type],
    minPriceLevel: 1,
    maxPriceLevel: 2,
    radius: '800',
		rankBy: google.maps.places.RankBy.DISTANCE
	}

	var service = new google.maps.places.PlacesService(map);

	service.radarSearch(request, function(results, status){
		if (status == google.maps.places.PlacesServiceStatus.OK) {
			for (var i = 0; i < results.length; i++) {
				createMarker(results[i], service)
			}

      for (var i = 0; i < 3; i++) {
        service.getDetails(results[randomNum(results.length)], function (result, status) {
          var location = result.geometry.location
          $('#spots').append('<li class="list-group-item suggested"><button type="button" class="btn btn-primary name" data-placeid="' + result.place_id + '">' + result.name + '</button></li>')
        })
      }
		}
	})
}

$(document).on('click', '.place-type', function () {
    $('.suggested').remove()
    clearMarkers()
    map.setZoom(15)
    markPlaces($(this).data().type);
})

function createMarker(place, service) {
	var placeLoc = place.geometry.location;
	var marker = new google.maps.Marker({
		map: map,
		position: place.geometry.location,
    icon: {
    url: 'http://maps.gstatic.com/mapfiles/circle.png',
    anchor: new google.maps.Point(10, 10),
    scaledSize: new google.maps.Size(10, 17)
    }
	})
  markers.push(marker)

	google.maps.event.addListener(marker, 'click', function() {
		service.getDetails(place, function(result, status) {
		  if (status !== google.maps.places.PlacesServiceStatus.OK) {
		    console.error(status)
        return;
		  }

      infowindow.setContent(result.name);
  		infowindow.open(map, marker);
  		document.getElementById('activity_location').value = result.name;
  		document.getElementById('activity_longitude').value = result.geometry.location.lng()
  		document.getElementById('activity_latitude').value = result.geometry.location.lat()
		})
	})
}

function setMapOnAll(map) {
  for (var i = 0; i < markers.length; i++) {
    markers[i].setMap(map);
  }
}

function clearMarkers() {
  setMapOnAll(null);
}

function randomNum(limit) {
  return Math.floor((Math.random() * limit) + 1)
}

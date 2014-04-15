$ ->
    log = $('.log')
    input = $('.user_input')
    table = $('.closest_schools table')
    lat = long = zipcode = null
    apikey = 'AIzaSyBxpvIsI9BxdiKRXF7DjZGCKT3mGadMqt8'
    base = 'https://maps.googleapis.com/maps/api/geocode/json?'
    schools = {}

    getUserLocation = () ->
        log.text 'Please allow the browser to access your current location so I can help you search for schools!'

        # If the user has geolocation, use it to find the current zipcode, lat, and long

        if window.navigator.geolocation
            success = (position) ->
                lat = position.coords.latitude
                long = position.coords.longitude
                latlongstring = "#{ lat },#{ long }"

                # Zipcode is found using Google's Geocoding API

                query = "#{ base }latlng=#{ latlongstring }&result_type=postal_code&sensor=true&key=#{ apikey }"
                log.text 'One moment please. I am looking up your current zip code!'
                $.getJSON query, (data) ->
                    if data.status is 'OK'
                        zipcode = data.results[0].address_components[0].long_name
                        log.text "Your zip code is #{ zipcode }!"
                        getSchools()
                    else
                        input.fadeIn(1500)
                        log.text 'Sorry, there was an error in retrieving your zip code. Please enter it manually below.'
            failure = (message) ->
                # If the geolocation service failed, allow the user to manually input their zip code.

                if message.code is 1
                    input.fadeIn(1500)
                    log.text 'You can enter your zip code manually below!'
                else if message.code is 2
                    input.fadeIn(1500)
                    log.text 'Sorry, but your zipcode is unavailable! Try entering it manually below!'
                else if message.code is 3
                    input.fadeIn(1500)
                    log.text 'The Geolocation feature of your device has timed out! Please enter your zip code manually below!'
            log.text 'One moment please. I am looking up your current location.'
            navigator.geolocation.getCurrentPosition success, failure
        else
            # If the geolocation service is not available on the device, allow the user to manually input their zipcode.

            input.fadeIn(1500)
            log.text 'Geolocation is not supported by your device! Please enter your zip code manually below.'
        input.on 'keypress', (e) ->
            if e.which is 13
                zipcode = input.val()
                if !isNaN(zipcode) and zipcode.length is 5
                    # Zipcode's lat and long are found using Google's Geocoding API

                    query = "#{ base }address=#{ zipcode }&result_type=postal_code&sensor=false&key=#{ apikey }"
                    log.text 'One moment please. I am looking up your current latitude and longitude!'
                    $.getJSON query, (data) ->
                        if data.status is 'OK'
                            log.text "Your zip code is #{ zipcode }!"
                            lat = data.results[0].geometry.location.lat
                            long = data.results[0].geometry.location.lng
                            input.fadeOut(1500)
                            getSchools()
                        else
                            log.text 'Sorry, there was an error in determining your latitude and longitude. Please try again later.'

                else
                    zipcode = null
                    log.text 'Please enter a valid zipcode!'

    # Gets the provided JSON data file

    getSchools = () ->
        query = 'http://srikarg.github.io/school-finder/data/schools.json'
        $.ajax {
            type: 'GET'
            dataType: 'json'
            url: query
            success: (data) ->
                schools = data
                displayNearestSchools 3
        }

    # Displays the nearest x schools where x is passed into the function

    displayNearestSchools = (numSchools) ->
        # For each school, the haversine distance, or the shortest distance between the school and the user's zipcode in terms of spherical distance, is calculated

        for school in schools
            school.haversine = haversine(lat, long, school.lat, school.lon)

        # The schools are sorted based on least haversine distance to greatest haversine distance

        schools.sort (a, b) ->
            return a.haversine - b.haversine
        log.empty()
        log.fadeOut(1500)

        # The first x schools of the sorted array are displayed, where x is passed into the function

        for i in [0...numSchools]
            table.append """
                         <tr>
                            <td>#{ schools[i].name }</td>
                            <td>#{ schools[i].street }<br>#{ schools[i].city }, #{ schools[i].state } #{ schools[i].zip }</td>
                            <td>#{ parseInt(schools[i].haversine) } miles</td>
                         </tr>
                         """
        table.parent().fadeIn(1500)

    toRadians = (num) ->
        return num * Math.PI / 180

    # Function that calculates the haversine distance between a certain school and the user's zipcode using the Haversine Formula, found here: http://en.wikipedia.org/wiki/Haversine_formula.

    haversine = (lat1, long1, lat2, long2) ->
        r = 3958.75587
        dLat = toRadians lat2 - lat1
        dLong = toRadians long2 - long1
        lat1 = toRadians lat1
        lat2 = toRadians lat2

        a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.sin(dLong/2) * Math.sin(dLong/2) * Math.cos(lat1) * Math.cos(lat2);
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
        return r * c

    init = () ->
        getUserLocation()
    init()

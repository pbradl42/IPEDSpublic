$(document).ready(function() {
    $('select').niceSelect();

    $.get( "https://ipeds-api.onrender.com/directory?years=2023&surveys=All Surveys&format=html", function( data ) {
      $( ".directory-table" ).html( data );
    });

    $('.option').on('click', function() {
      setTimeout(function() {
        var survey = $('.survey-select').children('.current').text()
        var start = $('.start-year').children('.current').text()
        var end = $('.end-year').children('.current').text()

        var request = "https://ipeds-api.onrender.com/directory?years=" + start.toString() + "&surveys=" + survey.toString() + "format=html"
        console.log(request)

        $.get( "https://ipeds-api.onrender.com/directory?years=" + start.toString() + "&surveys=" + survey.toString() + "&format=html", function( data ) {
          $( ".directory-table" ).html( data );
        });
      }, 1);

    })
});
$(document).ready(function() {
    $('select').niceSelect();

    $.get( "https://ipeds-api.onrender.com/directory?startYear=2023&endYear=2023&surveys=All Surveys&format=html", function( data ) {
      $( ".directory-table" ).html( data );
    });

    $('.option').on('click', function() {
      setTimeout(function() {
        var survey = $('.survey-select').children('.current').text()
        var start = $('.start-year').children('.current').text()
        var end = $('.end-year').children('.current').text()

        $.get( "https://ipeds-api.onrender.com/directory?startYear=" + start.toString() + "&endYear=" + end.toString() + "&surveys=" + survey.toString() + "&format=html", function( data ) {
          $( ".directory-table" ).html( data );
        });
      }, 1);

    })
});
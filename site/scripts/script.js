function updateTable() {
    var survey = $('.survey-select').children('.current').text()
    var start = $('.start-year').children('.current').text()
    var end = $('.end-year').children('.current').text()

    var query = $('.search').val()
    query = query.replace(' ',',')

    $.get("https://ipeds-api.onrender.com/directory?startYear=" + start.toString() + "&endYear=" + end.toString() + "&surveys=" + survey.toString() + "&q=" + query + "&format=html", function( data ) {
      $( ".directory-table" ).html( data );
    });
}


$(document).ready(function() {
    $('select').niceSelect();

    $.get( "https://ipeds-api.onrender.com/directory?startYear=2023&endYear=2023&surveys=All Surveys&format=html", function( data ) {
      $( ".directory-table" ).html( data );
    });

    $('.option').on('click', function() {
      setTimeout(function() {
        updateTable()
      }, 1);

    })

    $('#search-button').on('click', function() {
      updateTable()
    })

    $('.search').bind('enterKey', function(e) {
      updateTable()
    })

    $('.search').keyup(function(e){
      if(e.keyCode == 13) {
        $(this).trigger("enterKey");
      }
    });

});


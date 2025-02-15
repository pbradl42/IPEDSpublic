function updateTable() {
    var survey = $('.survey-select').children('.current').text()
    var start = $('.start-year').children('.current').text()
    var end = $('.end-year').children('.current').text()
    var returnType = $('.return-format').children('.current').text()
    if (returnType == 'Stata') {
      returnType = 'STATA_DATA,STATA'
    }

    var query = $('.search').val()
    query = query.replace(' ',',')

    var request = "https://ipeds-api.onrender.com/directory?startYear=" + start.toString() + "&endYear=" + end.toString() + "&surveys=" + survey.toString() + "&q=" + query + "&download=" + returnType + "&format=html"
    console.log(request)

    $.get(request, function( data ) {
      $( ".directory-table" ).html( data );
    });
}


$(document).ready(function() {
    $('select').niceSelect();

    updateTable()

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


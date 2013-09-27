// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
  $(function() {
    $( "#selectable" ).selectable({
      stop: function() {
        var result = $( "#select-result" ).empty();
        $( ".ui-selected", this ).each(function() {
          var index = $( "#selectable li" ).index( this );
          var namex = $(this).attr('id')
          result.append( namex );
          showhide(namex+"_component")
          showhidealter(namex+"_alternatives")
        });
      }
    });
  });
  function showhide(showdl) {
    var ele = document.getElementById(showdl);
    var all_dls = document.getElementsByClassName("div_component");
    for(var x=0; x<all_dls.length; x++){
      all_dls[x].style.display = 'none';
    }
     if (ele != null) {ele.style.display = "block";}
  }

  function showhidealter(showdl) {
    var ele = document.getElementById(showdl);
    if (ele == null) {
      ele = document.getElementById('no_op_alternative');
    }
    var all_dls = document.getElementsByClassName("div_alternative");
    for(var x=0; x<all_dls.length; x++){
      all_dls[x].style.display = 'none';
    }
    ele.style.display = "block";
  }

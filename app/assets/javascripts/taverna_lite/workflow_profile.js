// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
  $(function() {
    $( "#selectable" ).selectable({
      stop: function() {
        var result = $( "#select-result" ).empty();
        $( ".ui-selected", this ).each(function() {
          var index = $( "#selectable li" ).index( this );
          var namex = $(this).attr('id')
          result.append('Edit ').append( namex );
          showcomp(namex+"_component")
          showcompalter(namex+"_alternatives")
        });
      }
    });
  });
  function showcomp(showdl) {
    var ele = document.getElementById(showdl);
    var all_dls = document.getElementsByClassName("div_component");
    for(var x=0; x<all_dls.length; x++){
      all_dls[x].style.display = 'none';
    }
    if (ele != null)  ele.style.display = "block";
  }

  function showcompalter(showdl) {
    var ele = document.getElementById(showdl);
    if (ele == null) {
      ele = document.getElementById('no_op_alternative');
    }
    var all_dls = document.getElementsByClassName("div_alternative");
    for(var x=0; x<all_dls.length; x++){
      all_dls[x].style.display = 'none';
    }
    if (ele != null) ele.style.display = "block";
  }
  function toggle_view(full_content, snip_content, toggle_link) {
	var ele = document.getElementById(full_content);
        var ele2 = document.getElementById(snip_content);
	var button = document.getElementById(toggle_link);
    if(ele.style.display == "block") {
      ele.style.display = "none";
      ele2.style.display = "block"
      button.innerHTML = "<img alt='Bullet_arrow_down' src='/assets/taverna_lite/bullet_arrow_down.png' />";
      button.title = "show all";
      button.alt = "show all";   	}
    else {
      ele.style.display = "block";
      ele2.style.display = "none"
      button.innerHTML = "<img alt='Bullet_arrow_down' src='/assets/taverna_lite/bullet_arrow_up.png' />";
      button.title = "show less";
      button.alt = "show less";
    }
  }
  function hide_show_div(div_content, toggle_link) {
    var ele = document.getElementById(div_content);
    var button = document.getElementById(toggle_link);
    if(ele.style.display == "block") {
      ele.style.display = "none";
      button.innerHTML = "<img alt='Bullet_arrow_down' src='/assets/taverna_lite/bullet_arrow_down.png' />";
      button.title = "show advanced options";
      button.alt = "show advanced options";   	}
    else {
      ele.style.display = "block"
      button.innerHTML = "<img alt='Bullet_arrow_down' src='/assets/taverna_lite/bullet_arrow_up.png' />";
      button.title = "hide advanced options";
      button.alt = "hide advanced options";
    }
  }

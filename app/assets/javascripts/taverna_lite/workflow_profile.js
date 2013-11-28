// Copyright (c) 2012-2013 Cardiff University, UK.
// Copyright (c) 2012-2013 The University of Manchester, UK.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// * Neither the names of The University of Manchester nor Cardiff University nor
//   the names of its contributors may be used to endorse or promote products
//   derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Authors
//     Abraham Nieva de la Hidalga
//
// Synopsis
//
// BioVeL Taverna Lite  is a prototype interface to Taverna Server which is
// provided to support easy inspection and execution of workflows.
//
// For more details see http://www.biovel.eu
//
// BioVeL is funded by the European Commission 7th Framework Programme (FP7),
// through the grant agreement number 283359.
// -----------------------------------------------------------------------------
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
  $(function() {
    $( "#selectable" ).selectable({
      stop: function() {
        var result = $( "#select-result" ).empty();
        $( ".ui-selected:first", this ).each(function() {
          $(this).siblings().removeClass("ui-selected");
          var index = $( "#selectable li" ).index( this );
          var namex = $(this).attr('id');
          result.append('Edit ').append( namex );
          showcomp(namex+"_component");
          showcompalter(namex+"_alternatives");
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
      ele = document.getElementById('annotation_alternatives');
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
      button.innerHTML = "<img alt='Bullet_arrow_down' src='/assets/taverna_lite/unfold.png' />";
      button.title = "show all";
      button.alt = "show all";   	}
    else {
      ele.style.display = "block";
      ele2.style.display = "none"
      button.innerHTML = "<img alt='Bullet_arrow_down' src='/assets/taverna_lite/fold.png' />";
      button.title = "show less";
      button.alt = "show less";
    }
  }
  function hide_show_div(div_content, toggle_link) {
    var ele = document.getElementById(div_content);
    var button = document.getElementById(toggle_link);
    if(ele.style.display == "block") {
      ele.style.display = "none";
      button.innerHTML = "<img alt='Bullet_arrow_down' src='/assets/taverna_lite/unfold.png' />";
      button.title = "show advanced options";
      button.alt = "show advanced options";   	}
    else {
      ele.style.display = "block"
      button.innerHTML = "<img alt='Bullet_arrow_down' src='/assets/taverna_lite/fold.png' />";
      button.title = "hide advanced options";
      button.alt = "hide advanced options";
    }
  }

  function validate_name(text){    //Allow only letters, numbers and underscore
    //alert("Validating now " + text);
    var element = document.getElementById(text);
    var ele_value = element.value;
    var patt = new RegExp("^[a-zA-Z0-9_]+$");
    var res = patt.test(ele_value);
    var errmsg_id="error_for_"+text;
    var err_el = document.getElementById(errmsg_id);
    if (!res) {

//      alert(newDiv_id)
//      if (document.contains(newDiv_id)){
//        var alert_msg = "Name can only contain letters (a-z,A-Z)" +
//          ", numbers (0-9) and underscore(_)"
//        var newDiv = document.createElement("div");
//        newDiv.id=newDiv_id;
//        var newContent = document.createTextNode(alert_msg);
//        newDiv.appendChild(newContent); //add the text node to the newly created div.
//        element.parentNode.appendChild(newDiv);
//      }
      err_el.style.display = "block";
      return false;
      }
    else{
      err_el.style.display = "none";
    }
    return true;
  }
//  function validate_name(text){    //Only letters and numbers allowed
//    //alert("Validating now " + text);
//    var patt = new RegExp("^[a-zA-Z0-9_]+$");
//    var res = patt.test(text);
//    if (!res) {
//      alert("name can only contain letters, numbers and underscore");
//        return false;
//      }
//    return true;
//  }
//  function validate_name(evt){    //Only letters and numbers allowed
//    evt = (evt) ? evt : event;
//    var charCode = (evt.charCode) ? evt.charCode : ((evt.keyCode) ? evt.keyCode :
//           ((evt.which) ? evt.which : 0));
//    if (charCode > 31 && (charCode < 48 || charCode > 57) && charCode!=95) {
//      alert("Enter numerals only in this field.");alert(charCode);
//        return false;
//      }
//    return true;
//  }
//  function validate_name(){    //Only letters and numbers allowed
//    var text = this.innerHTML
//    allowedevt = (evt) ? evt : event;
//    var charCode = (evt.charCode) ? evt.charCode : ((evt.keyCode) ? evt.keyCode :
//           ((evt.which) ? evt.which : 0));
//        if (charCode > 31 && (charCode < 48 || charCode > 57) &&
//          charCode != 95 && (charCode < 65 || charCode > 90) &&
//          (charCode < 97 || charCode > 122)) {
//           alert("Use only leters, numbers and underscore");
//           return false;
//          }
//           return true;
//  }

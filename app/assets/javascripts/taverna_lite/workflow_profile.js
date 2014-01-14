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
          result.append( namex );
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

  function validate_name(input_field_name,used_names){
    x = validate_string(input_field_name);
    y = validate_unique(input_field_name,used_names);
    var errmsg_id="error_for_"+input_field_name;
    var err_el = document.getElementById(errmsg_id);
    if (!(x && y)){
      err_el.style.display = "block";
      return false;}
    else {
      err_el.style.display = "none";
      return true;
    }
  }

  function validate_string(input_field_name){ //Allow only letters, numbers and underscore
    var element = document.getElementById(input_field_name);
    var ele_value = element.value;
    var patt = new RegExp("^[a-zA-Z0-9_]+$");
    var res = patt.test(ele_value);
    var errmsg_id="error_for_"+input_field_name;
    var err_el = document.getElementById(errmsg_id);
    if (!res) {
      //err_el.style.display = "block";
      err_el.innerHTML = "Name can only contain letters (a-z, A-Z)" +
                   ", numbers (0-9), and underscore (_)" ;
      return false;
    }
    else{
      //err_el.style.display = "none";
      return true;
    }
  }
  function validate_unique(input_field,used_names){//Prevent duplicated names
    if (used_names==""||used_names==null) return true;
    var names = used_names.split(",");
    var element = document.getElementById(input_field);
    var ele_value = element.value;
    var repeated = names.indexOf(ele_value);
    var errmsg_id = "error_for_" + input_field;
    var err_el = document.getElementById(errmsg_id);
    if (repeated > -1) {
      err_el.innerHTML = "Name must be unique";
      //err_el.style.display = "block";
      return false;
    }
    else{
      //err_el.style.display = "none";
      return true;
    }
  }

  function ValidateForm(){
  var cusid_ele = document.getElementsByClassName('warning_message');
    for (var i = 0; i < cusid_ele.length; ++i) {
      var item = cusid_ele[i];
      if (item.style.display == "block"){
        return false;
      }
    }
    return true;
  }

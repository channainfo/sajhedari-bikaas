// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require_tree .

function updateModalPaging(id, offset) {
	$.ajax({
		url: '/reporters/getReporterCasesPagination',
		type: "get",
		data: "id="+id+"&offset="+offset,
		success: function(data) {
			$("#mytable > tbody").html("");
			$("#mytable > tbody").append(data["table_row"]);
			if ($("#paginate_report")[0]) {
				$("#reporter_case")[0].removeChild($("#paginate_report")[0]);
			}
			$("#reporter_case").append(data["paging"]);
		}
	})
}

function exportExcel(){
    $.ajax({
        url: '/trends/downloadCSV.csv',
        type: "get",
        data: "data=",
        success: function(data) {}
    })
}

function generateGraphData() {
    var case_inten = [];
    var array_checkbox = $(".checkboxes:checked");
    var select = document.getElementById("frequently");
    var from = document.getElementById("from").value;
    var to = document.getElementById("to").value;
    for (var i=0; i<array_checkbox.size(); i++) {
        case_inten.push(array_checkbox[i].value);
    }
    var frequently = select.options[select.selectedIndex].text;
    $.ajax({
        url: '/trends/fetchCaseForGraph',
        type: "get",
        data: "data="+case_inten.join(",")+"&from="+from+"&to="+to+"&frequently="+frequently,
        success: function(data) {
          
          var graph_data = google.visualization.arrayToDataTable(data[0][0]);

          var options = {
            title: '',
            legend: {position: 'none'},
            colors: data[1],
            vAxis: {format: '0', minValue: 0, maxValue: data[0][1]},
            width: 850
            // vAxis: {format: '0', minValue:0,maxValue:5,gridlines:{count:6}}
          };

          if (data[0][0].length <= 2)
            var chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
          else
            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
          chart.draw(graph_data, options); 
            }
    })
}

var indexCondition = 2;
function addCondition(){
    conditionHtml =                 '<div id="condition' + indexCondition.toString() + '" class="controls navbar-inner" style="padding-top:10px; margin-bottom:20px">';
    conditionHtml = conditionHtml +     '<div class="row-fluid">';
    conditionHtml = conditionHtml +         '<div class="span4">';
    conditionHtml = conditionHtml +             '<select class="input-block-level" id="conflict-info' + indexCondition.toString() + '" name="type[]">';
    conditionHtml = conditionHtml +             '</select>';
    conditionHtml = conditionHtml +         '</div>';
    conditionHtml = conditionHtml +         '<div class="span1" style="min-width:70px;padding-top:5px;">';
    conditionHtml = conditionHtml +             'is equal to';
    conditionHtml = conditionHtml +         '</div>';
    conditionHtml = conditionHtml +         '<div class="span5" style="min-width:330px">';
    conditionHtml = conditionHtml +             '<select class="input-block-level" id="select-item' + indexCondition.toString() + '" name="item[]">';
    conditionHtml = conditionHtml +             '</select>';
    conditionHtml = conditionHtml +         '</div>';
    conditionHtml = conditionHtml +         '<div class="span1">';
    conditionHtml = conditionHtml +            '<a href="javascript:void(0)" class="btn btn-danger" id="rmbtn' + indexCondition.toString() + '" refdata="' + indexCondition.toString() + '" onclick="removeCondition(this)">'
    conditionHtml = conditionHtml +                 '<i class="icon-minus-sign"></i>';
    conditionHtml = conditionHtml +             '</a>';
    conditionHtml = conditionHtml +         '</div>';
    conditionHtml = conditionHtml +     '</div>';
    conditionHtml = conditionHtml + '</div>';
    $("#conditions").append(conditionHtml);
    ajaxRequestIndicators(indexCondition);
    handleConditionCombo(indexCondition);   
    indexCondition = indexCondition + 1;
}

function removeCondition(el){
    index = el.attributes.refdata.value;
    $("#condition" + index.toString()).fadeOut();
    setTimeout(function() {
        $("#condition" + index.toString()).remove();
    }, 1000);
}

function handleConditionCombo(indexCondition){
	$("#conflict-info" + indexCondition.toString()).change(function(el) {
		field = el.target.value;
		ajaxRequestField(indexCondition, field);
	});
}

function ajaxRequestField(indexCondition, field_code){
    $.ajax({
        url: '/conflict_cases/get_field_options.json',
        type: "get",
        data: "field=" + field_code,
        success: function(data) {
            $("#select-item" + indexCondition.toString()).empty();
            for(i=0; i<data.length; i++){
                $("#select-item" + indexCondition.toString())[0].options.add(new Option(data[i]["label"], data[i]["id"]));
            }
        }
    })
}

function ajaxRequestIndicators(indexCondition){
    $.ajax({
        url: '/conflict_cases/get_indicator_options.json',
        type: "get",
        success: function(data) {
            $("#conflict-info" + indexCondition.toString()).empty();
            for(i=0; i<data.length; i++){
                $("#conflict-info" + indexCondition.toString())[0].options.add(new Option(data[i]["label"], data[i]["id"]));
            }
            ajaxRequestField(indexCondition, data[0]["id"]);
        }
    })
}

function addToMessage(txt){
    $('#alert_message').val($('#alert_message').val() + txt); 
}

function showReporterInfo(first_name, last_name, sex, dob, cast, phone, address){
    $("#first_name").html(": " + first_name);
    $("#last_name").html(": " + last_name);
    $("#phone_number").html(": " + phone);
    $("#dob").html(": " + dob);
    $("#address").html(": " + address);
    $("#cast_ethnicity").html(": " + cast);
    $("#gender").html(": " + sex);
}

function showMessageInfo(country, channel, from, to, message_text, message_reply){
    $("#country").html(": " + country);
    $("#channel").html(": " + channel);
    $("#from").html(": " + from);
    $("#to").html(": " + to);
    $("#message_text").html(": " + message_text);
    $("#message_reply").html(": " + message_reply);
}
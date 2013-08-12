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

var indexCondition = 1;
function addCondition(){
    conditionHtml =                 '<div id="condition' + indexCondition.toString() + '" class="controls navbar-inner" style="padding-top:10px; margin-bottom:20px">';
    conditionHtml = conditionHtml +     '<div class="row-fluid">';
    conditionHtml = conditionHtml +         '<div class="span4">';
    conditionHtml = conditionHtml +             '<select class="input-block-level" id="conflict-info' + indexCondition.toString() + '">';
    conditionHtml = conditionHtml +                 '<option value="con_type">Violent type</option>';
    conditionHtml = conditionHtml +                 '<option value="con_intensity">Violent intensity</option>';
    conditionHtml = conditionHtml +                 '<option value="con_state">Violent state</option>';
    conditionHtml = conditionHtml +             '</select>';
    conditionHtml = conditionHtml +         '</div>';
    conditionHtml = conditionHtml +         '<div class="span1" style="min-width:70px;padding-top:5px;">';
    conditionHtml = conditionHtml +             'is equal to';
    conditionHtml = conditionHtml +         '</div>';
    conditionHtml = conditionHtml +         '<div class="span5" style="min-width:330px">';
    conditionHtml = conditionHtml +             '<select class="input-block-level">';
    conditionHtml = conditionHtml +                 '<option>2013</option>';
    conditionHtml = conditionHtml +                 '<option>...</option>';
    conditionHtml = conditionHtml +                 '<option>2015</option>';
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
    handleConditionCombo(indexCondition)    
    indexCondition = indexCondition + 1;
}

function removeCondition(el){
    index = el.attributes.refdata.value;
    $("#condition" + index.toString()).fadeOut();
}

function handleConditionCombo(indexCondition){
	$("#conflict-info" + indexCondition.toString()).change(function(el) {
		field = el.target.value;
		$.ajax({
			url: '/conflict_cases/get_field_options.json',
			type: "get",
			data: "field=" + field,
			success: function(data) {
				
			}
		})
	});
}
(function($) {

    $(document).ready(function() {

        var authenticity_token = $('meta[name=csrf-token]').attr('content');

        $("#user_id").val($("#user_id option[selected]").val()); // Reset dropdown after refresh

        var updateCalendar = function(year, month, user_id) {
            var url = "/company_calendar/:year/:month?user_id=:user_id";
            url = url.replace(":year", year);
            url = url.replace(":month", month);
            url = url.replace(":user_id", user_id);

            $(".dim-screen").show();
            $(".calendar-placeholder").load(url, { user_id: $("#user_id").val(), authenticity_token: authenticity_token }, function() {
                $(".dim-screen").hide();
                recalculateWorktime();
            });
        };

        var changeStatus = function(self, status) {
	    //same attr data-date is placed in containing cell
	    //refactor to make use of it insted of this data-date
            var date = self.attr("data-date");
            var month = $("#current_month").val();
            var url = "/company_calendar/set_status";

            self.closest("td").load(url, { date: date, month: month, user_id: $("#user_id").val(), status: status, authenticity_token: authenticity_token }, function() {
                recalculateWorktime();
            });
        };

        var formatNumber = function(i) {
            return i.toFixed(2).toString().replace(/[0]+$/g, "").replace(/\.$/g, "");
        }

        var recalculateWorktime = function() {
            $("td.worktime-per-week").each(function() {
                var row = $(this).closest("tr");
                var worktimes = $(".cell[data-worktime]", row).map(function(index, elem) {
                    return $(elem).attr("data-worktime");
                });
                var totalWorktime = $.sum(worktimes, function(i) { return parseFloat(i); });
                $(this).text("= " + formatNumber(totalWorktime) + " hrs");
            });

            var totalWorktime = $(".cell.workday").not(".other-month").length * 8;
            $("td.worktime-per-month .total-worktime").text("from " + formatNumber(totalWorktime) + " hrs");

            var worktimes = $(".cell.workday").not(".other-month").map(function(index, elem) {
                return $(elem).attr("data-worktime");
            });
            var currentWorktime = $.sum(worktimes, function(i) { return parseFloat(i); });
            var percent = Math.round((currentWorktime / totalWorktime) * 100);  
            $("td.worktime-per-month .current-worktime").text("= " + formatNumber(currentWorktime) + " hrs (" + formatNumber(percent) + "%)");
        };

        recalculateWorktime();

        $(".navigation-link").live("click", function() {
            var year = $(this).attr("data-year");
            var month = $(this).attr("data-month");
            var user_id = $("#user_id").val();

            updateCalendar(year, month, user_id)
        });

        $("#user_id").change(function() {
            var year = $("#current_year").val();
            var month = $("#current_month").val();
            var user_id = $("#user_id").val();

            updateCalendar(year, month, user_id)
        });

        $(".set-weekend").live("click", function() {
            changeStatus($(this), 0);
	    return false;
        });

        $(".set-workday").live("click", function() {
            changeStatus($(this), 1);
	    return false;
        });

        $(".set-vacation").live("click", function() {
            changeStatus($(this), 2);
    	    return false;	    
        });

        $(".set-sick-leave").live("click", function() {
            changeStatus($(this), 4);
	    return false;
        });

        $(".set-leave-without-pay").live("click", function() {
            changeStatus($(this), 8);
	    return false;
        });

        $(".undo").live("click", function() {
            changeStatus($(this), -1);
    	    return false;
        });

	$(".cell").live("click", function() {
	    var user_id = $("#user_id").val();
	    if (user_id == 0) return false;
            var url = "/company_calendar/tt/?user_id=:user_id&date=:date";
            url = url.replace(":date", $(this).attr("data-date"));
            url = url.replace(":user_id", user_id);
	    $(".dim-screen").show();
            $(".tt-placeholder").load(url, { user_id: user_id, authenticity_token: authenticity_token }, function() {
		$(".tt-placeholder").show();
            });
	});
	
	$(".tt-placeholder .tt-popup .buttons_panel #close").live("click", function() {
	    $(".dim-screen").hide();
	    $(".tt-placeholder").hide();
	    return false;
	});

	function TTInputErrors() {
	    this.errors = [];
	}
	TTInputErrors.prototype.textRequired = function(e) {
	    if (this.errors.indexOf(e) < 0) {
		this.errors.push(e);
		$(e).addClass("text-required");
	    }
	}
	TTInputErrors.prototype.remove = function(e) {
	    var idx = this.errors.indexOf(e);
	    if (idx >= 0) {
		this.errors.splice(idx, 1);
		$(e).removeClass("text-required");
	    }
	}
	TTInputErrors.prototype.hasErrors = function() {
	    return this.errors.length > 0;
	}
	var ttInputErrors = new TTInputErrors();	
	
	$(".tt-placeholder .tt-popup .buttons_panel #submit").live("click", function() {
	    var noErrors = !ttInputErrors.hasErrors();
	    if (noErrors) {
		$(".tt-placeholder").hide();
		$(".dim-screen").hide();
   		$(".tt-placeholder .tt-popup #tt_form").submit();
	    }
	    return noErrors;
	});

	function TTValidator() {
	}
	TTValidator.fromTT = function(tt) {
	    var validator = new TTValidator();
	    validator.tt = tt;
	    validator.comment = $("input.comment", $(tt).parent().next())[0];
	    return validator;
	}
	TTValidator.fromComment = function(comment) {
	    var validator = new TTValidator();
	    validator.tt = $("input.hours", $(comment).parent().prev())[0];
	    validator.comment = comment;
	    return validator;
	}
	TTValidator.prototype.validate = function(errors){
	    if (this.ok()) {
		errors.remove(this.comment);
	    } else if (this.ttValue() > 0){
		errors.textRequired(this.comment);
	    }
	}
	TTValidator.prototype.ok = function() {
	    return this.ttValue() > 0 && this.commentValue() != ""
		|| this.ttValue() == 0;
	}
		TTValidator.prototype.commentValue = function() {
	    return $.trim($(this.comment).val());
	}
	TTValidator.prototype.ttValue = function() {
	    return parseInt($(this.tt).val());
	}

	function ttChanged(){
	    var validator = TTValidator.fromTT(this);
	    validator.validate(ttInputErrors);
	}
	$(".tt-placeholder .tt-popup input.hours")
	    .live("keyup", ttChanged)
	    .live("change", ttChanged);

	function ttCommentChanged() {
	    var validator = TTValidator.fromComment(this);
	    validator.validate(ttInputErrors);
	}
	$(".tt-placeholder .tt-popup input.comment")
	    .live("keyup", ttCommentChanged)
	    .live("change", ttCommentChanged);
    });

})(jQuery);

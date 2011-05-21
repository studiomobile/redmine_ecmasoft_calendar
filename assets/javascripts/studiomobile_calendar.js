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
            var date = self.attr("data-date");
            var month = $("#current_month").val();
            var url = "/company_calendar/set_status";

            self.closest("td").load(url, { date: date, month: month, user_id: $("#user_id").val(), status: status, authenticity_token: authenticity_token }, function() {
                recalculateWorktime();
            });
        };

        var recalculateWorktime = function() {
            $("td.worktime-per-week").each(function() {
                var row = $(this).closest("tr");
                var worktimes = $(".cell[data-worktime]", row).map(function(index, elem) {
                    return $(elem).attr("data-worktime");
                });
                var totalWorktime = $.sum(worktimes);
                $(this).text("= " + totalWorktime + " hrs");
            });

            var totalWorktime = $(".cell.workday").not(".other-month").length * 8;
            $("td.worktime-per-month .total-worktime").text("from " + totalWorktime + " hrs");

            var worktimes = $(".cell.workday").not(".other-month").map(function(index, elem) {
                return $(elem).attr("data-worktime");
            });
            var currentWorktime = $.sum(worktimes);
            var percent = Math.round((currentWorktime / totalWorktime) * 100);  
            $("td.worktime-per-month .current-worktime").text("= " + currentWorktime + " hrs (" + percent + "%)");
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
        });

        $(".set-workday").live("click", function() {
            changeStatus($(this), 1);
        });

        $(".set-vacation").live("click", function() {
            changeStatus($(this), 2);
        });

        $(".set-sick-leave").live("click", function() {
            changeStatus($(this), 4);
        });

        $(".set-leave-without-pay").live("click", function() {
            changeStatus($(this), 8);
        });

        $(".undo").live("click", function() {
            changeStatus($(this), -1);
        });
    });

})(jQuery);

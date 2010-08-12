(function($) {

    $(document).ready(function() {
        var update_calendar = function(year, month, user_id) {
            var url = "/ecmasoft_calendar/:year/:month?user_id=:user_id";
            url = url.replace(":year", year)
            url = url.replace(":month", month)
            url = url.replace(":user_id", user_id)

            $(".dim-screen").show();
            $(".calendar-placeholder").load(url, { user_id: $("#user_id").val() }, function() {
                $(".dim-screen").hide();
            });
        };

        var change_status = function(self, status) {
            var date = self.attr("data-date");
            var month = $("#current_month").val();
            var url = "/ecmasoft_calendar/set_status";

            self.closest("td").load(url, { date: date, month: month, user_id: $("#user_id").val(), status: status })
        };


        $(".navigation-link").live("click", function() {
            var year = $(this).attr("data-year");
            var month = $(this).attr("data-month");
            var user_id = $("#user_id").val();

            update_calendar(year, month, user_id)
        });

        $("#user_id").change(function() {
            var year = $("#current_year").val();
            var month = $("#current_month").val();
            var user_id = $("#user_id").val();

            update_calendar(year, month, user_id)
        });

        $(".set-weekend").live("click", function() {
            change_status($(this), 0);
        });

        $(".set-workday").live("click", function() {
            change_status($(this), 1);
        });

        $(".set-vacation").live("click", function() {
            change_status($(this), 2);
        });

        $(".set-sick-leave").live("click", function() {
            change_status($(this), 4);
        });

        $(".undo").live("click", function() {
            change_status($(this), -1);
        });

    });

})(jQuery);

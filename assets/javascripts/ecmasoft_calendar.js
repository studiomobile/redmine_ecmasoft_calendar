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
        }

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
            var date = $(this).attr("data-date");
            var url = "/ecmasoft_calendar/set_status";

            $(this).closest("td").load(url, { date: date, user_id: $("#user_id").val(), status: 0 });
        });

        $(".set-workday").live("click", function() {
            var date = $(this).attr("data-date");
            var url = "/ecmasoft_calendar/set_status";

            $(this).closest("td").load(url, { date: date, user_id: $("#user_id").val(), status: 1 })
        });

        $(".set-vacation").live("click", function() {
            var date = $(this).attr("data-date");
            var url = "/ecmasoft_calendar/set_status";

            $(this).closest("td").load(url, { date: date, user_id: $("#user_id").val(), status: 2 });
        });

        $(".set-sick-leave").live("click", function() {
            var date = $(this).attr("data-date");
            var url = "/ecmasoft_calendar/set_status";

            $(this).closest("td").load(url, { date: date, user_id: $("#user_id").val(), status: 4 });
        });

        $(".undo").live("click", function() {
            var date = $(this).attr("data-date");
            var url = "/ecmasoft_calendar/undo";

            $(this).closest("td").load(url, { date: date, user_id: $("#user_id").val() });
        });

    });

})(jQuery);

(function($) {

  $(document).ready(function() {
      var update_calendar = function(year, month, user_id) {
        var url = "/ecmasoft_calendar/:year/:month?user_id=:user_id"
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
  });

})(jQuery);

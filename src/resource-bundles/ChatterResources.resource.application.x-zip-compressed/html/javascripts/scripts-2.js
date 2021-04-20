$(document).ready(function() {

  //Sets width of topics UL to content
  var width = 0;
  $(".channel-topics ul li").each(function() {
    width += $(this).outerWidth( true );
  });
  $(".channel-topics ul").css('width', width + 0);

  // Adds or removes following class and checkmark div
  $('.topic-block').click(function() {
    if($(this).hasClass('following')){
      $(this).removeClass('following');
      $(this).find('.checkmark').remove();
    } else {
      $(this).addClass("following");
      $('.following').append('<div class="checkmark"></div>');
    }

  });

  // Kills anchor binding
  $('a.topic-block').bind("click", function (e) {
        e.preventDefault();
    });
  
  // $('.topic-block').popover();

// $('#popoverOption').popover({ trigger: "hover" });

$('.popover-markup > .trigger').popover({
    trigger: "hover",
    html : true,
    title: function() {
      return $(this).parent().find('.head').html();
    },
    content: function() {
      return $(this).parent().find('.content').html();
    },
    container: 'body',
    placement: 'bottom'
});

});

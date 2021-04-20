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
      $(this).append('<div class="checkmark"></div>');
    }

  });


  // Expands TD width on sidebar collapse

if( $("#sidebarCell").hasClass("sidebarCollapsed")){
      $(".oRight").css("width", "100%");
    } else {
      $(".oRight").css("width", "calc(100% - 250px)");
    }

  $("a.handlebarContainer").click(function() {
    if($("#sidebarCell").hasClass("sidebarCollapsed")){
      $(".oRight").css("width", "100%");
    } else {
      $(".oRight").css("width", "calc(100% - 250px)");
    }
  });
  

  // Kill anchor binding
  $('a.topic-block').bind("click", function (e) {
    e.preventDefault();
  });

  $('a.scroll-left').bind("click", function (e) {
    e.preventDefault();
  });

  $('a.scroll-right').bind("click", function (e) {
    e.preventDefault();
  });

  // Expands TD width on sidebar collapse
  $("a.handlebarContainer").click(function() {
    if($("#sidebarCell").hasClass("sidebarCollapsed")){
      $(".oRight").css("width", "calc(100% - 250px)");
    } else {
      $(".oRight").css("width", "100%");
    }
  });


  //Popover Script
  $('.popover-item > .topic-block').popover({
    trigger: "click",
    delay: { "show": 1550, "hide": 50 },
    html : true,
    title: function() {
      return $(this).parent().find('.head').html();
    },
    content: function() {
      return $(this).parent().find('.content').html();
    },
    container: 'body',
    placement: 'right'
  });

  (function($) {
    var oldHide = $.fn.popover.Constructor.prototype.hide;

    $.fn.popover.Constructor.prototype.hide = function() {
      if (this.options.trigger === "hover" && this.tip().is(":hover")) {
        var that = this;
            // try again after what would have been the delay
            setTimeout(function() {
              return that.hide.call(that, arguments);
            }, that.options.delay.hide);
            return;
          }
          oldHide.call(this, arguments);
        };
      })(jQuery);
      

// Scroll buttons
$('.scroll-left').click(function () {
  var leftPos = $(this).closest ('div.channel-topics').scrollLeft();
  $(this).closest ("div.channel-topics").animate({
    scrollLeft: leftPos - 600
  }, 800);
});

$('.scroll-right').click(function () {
  var leftPos = $(this).closest ('div.channel-topics').scrollLeft();
  $(this).closest ("div.channel-topics").animate({
    scrollLeft: leftPos + 600
  }, 800);
});


});

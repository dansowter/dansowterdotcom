`  function getNav() {
    var mobileNav = $('#nav').append('<select></select>');

    mobileNav.children('select').append('<option value="">Navigate&hellip;</option>');

    $('ul[role=main-navigation]').addClass('main-navigation');
    $('ul.main-navigation a').each(function() {
      var link = $(this);
      var href = link.attr('href');
      mobileNav.children('select').append('<option value="'+href+'">&raquo; '+link.html()+'</option>');
    });

    mobileNav.children('select').bind('change', function(event) {
      if (event.target.value) { window.location.href = event.target.value; }
    });
  }

  $(document).ready(function() {

    $('#content section').each(function(index) {
      var titleContent = $(this).find('h2').html(),
                 count = index + 1

      // console.log(titleContent.html());
      $(this).find('h2').attr('id', 'section-' + count + '-title');

      $('#sidebar ul').append('<li><a href="#section-' + count + '-title">' + titleContent + '</a></li>');

      if ($(this).find('h5').length > 0) {
        $(this).find('h5').each(function(index) {
          var subtitleContent = $(this).html(),
                        count = index + 1;

          $(this).attr('id', 'section-' + count + '-subtitle');

          $('#sidebar ul').append('<li class="sub-item"><a href="#section-' + count + '-subtitle">' + subtitleContent + '</a></li>');
        });
      }
    });


    window.setTimeout(function() {
      getNav();
      $('#sidebar').scrollspy()
    }, 400);

  });`
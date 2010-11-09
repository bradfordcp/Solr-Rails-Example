var solr = {
  params: {
    server: "http://127.0.0.1:8080",
    page: 1,
    start: 0,
    rows: 10,
    query: unescape($.url.param("q").replace("+", " ")),
    facet: true,
    "facet.field": "tags",
    performing: false,
    type: false,
    max_page: 1
  }
};

solr.init = function (e) {
  // Setup the appropriate values if we came here with a page number
  if ($.url.param("page")) {
    solr.params.page = Math.floor(Number($.url.param("page")) - 1);
    solr.params.start = solr.params.page * solr.params.rows;
  }
  if ($.url.param("type")) {
    solr.params.type = $.url.param("type");
  }

  // Perform the query
  if (solr.params.query != "") {
    solr.execute(solr.params.query);

    // Add the query to the page
    $("input[name=q]").val(solr.params.query);
    $("#term").html(solr.params.query);
  }

  // Capture scroll events, 
  $(window).scroll(solr.scrolled);
}

solr.scrolled = function(e) {
  if (!solr.params.performing && ((solr.params.page < solr.params.max_page && $(document).height() - ($(window).height() + $(this).scrollTop()) < 100) || ($(window).height() == $(document).height()))) {
        solr.params.start = solr.params.page * solr.params.rows;
        
        solr.execute(solr.params.query);
      }
}

solr.execute = function(query) {
  solr.params.performing = true;
  $("#search_results #loading").show();
  
  var params = {
    q: query,
    version: 2.2,
    start: solr.params.start,
    rows: solr.params.rows,
    wt: 'json',
    facet: solr.params.facet,
    "facet.field": solr.params["facet.field"]
  };
  
  if (solr.params.type) {
    params.facet = true;
    params["facet.field"] = "{!ex=type_tag}" + solr.params["facet.field"];
    params.fq = "{!tag=type_tag}" + solr.params["facet.field"] + ":" + $.url.param("type");
  }
  
  $.ajax(
    {
      data: params,
      dataType: 'jsonp',
      error: solr.error,
      jsonp: 'json.wrf',
      success: solr.success,
      type: 'GET',
      url: solr.params.server + '/select/'
    }
  );
}

solr.error = function (request, status, error) {
  solr.params.performing = false;
  $("#search_results #loading").hide();
  
  var error_msg = '<li class="error">An error has occured, please try your search again later.</li>';
  
  $("#search_results ol").append(error_msg);
}

solr.success = function (data, text_status, request) {
  solr.params.performing = false;
  $("#search_results #loading").hide();
  
  var current_page = Math.floor(data.response.start / data.responseHeader.params.rows);
  solr.params.page = current_page + 1;
  
  var max_page = Math.floor(data.response.numFound / data.responseHeader.params.rows) + ((data.response.numFound / data.responseHeader.params.rows) == 0 ? 0 : 1);
  solr.params.max_page = max_page;
  
  // Add the stats to the page
  var stats = "<strong>"+ data.response.numFound + "</strong> results found in " + (data.responseHeader.QTime / 1000) + " seconds."
  $("#stats").html(stats);
  $("#search_results ol").attr("start", (data.responseHeader.params.rows * current_page) + 1);
  
  // Empty the facets
  $(".tags ul").html('');
  
  var query = $.url.param("q");  
  $("#term").html(query.replace("+", " "));
  
  // Add the facets
  var facets = {};
  var total = 0;
  var raw_facets = data.facet_counts.facet_fields[solr.params["facet.field"]];
  for (var i = 0; i < raw_facets.length; i += 2) {
    facets[raw_facets[i]] = raw_facets[i+1];
  }
  for (var key in facets) {
    var facet = '<li class='+ key +'><a href="/posts/search?q=' + data.responseHeader.params.q + '&type=' + key + '">' + key + ' (' + facets[key] + ')</a></li>';
    $(".tags ul").append(facet);
    total += facets[key];
  }
  
  var facet = '<li class="everything"><a href="/posts/search?q=' + data.responseHeader.params.q + '">everything</a></li>';
  $(".tags ul").prepend(facet);
  
  // Empty the results
  var type = solr.params.type;
  
  if (type) {
      $("#facets").find('li.' + type + ' a').addClass('active');
  } else {
      $("#facets").find('li.everything a').addClass('active');
  }
  
  // Add the results
  var page_li = '<li class="clearfix page"><a href="/posts/search?q=' + data.responseHeader.params.q + '&page=' + (current_page + 1) + (solr.params.type ? "&type=" + solr.params.type : "" ) + '">Page ' + (current_page + 1) + '</a></li>';
  $("#search_results ol").append(page_li);
  for (var i in data.response.docs) {
    var doc = data.response.docs[i];
    
    var result = '<li class="clearfix"><a href="/posts/' + doc.id + '" class="title">' + doc.title + '</a><br />' + doc.tidy_body + '...</li>';
    $("#search_results ol").append(result);
  }
  
  // Auto request if the doc isn't tall enough
  if ($(window).height() == $(document).height()) {
    $(window).scroll();
  }
}

$(document).ready(solr.init);
(function(){
  function presentContent(content) {
    var list = document.querySelector(".til-list");

    content.forEach(function(item) {
      var li = document.createElement("li");
      var link = document.createElement("a");
      link.innerText = item.title;
      link.setAttribute("href", item.url);
      li.appendChild(link);
      list.appendChild(li);
    });

    document.querySelector(".til")
            .style.setProperty("display", "block");
  }

  var request = new XMLHttpRequest();
  request.open("GET", "https://www.todayilearned.fyi/by/odlp.json");
  request.onload = function() {
    if (request.status == 200) {
      var json = JSON.parse(request.responseText);
      presentContent(json.data);
    }
  };

  request.send();
})();

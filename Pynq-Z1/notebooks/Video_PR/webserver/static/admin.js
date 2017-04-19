addEventListener("DOMContentLoaded", function() {
    var filterButtons = document.querySelectorAll(".filter");
    for(var i=0, l=filterButtons.length; i<l; i++) {
        var button = filterButtons[i];
        button.addEventListener("click", function(e) {
            e.preventDefault();
            var clickedButton = e.target;
            var filter = clickedButton.value;
            var request = new XMLHttpRequest();
            request.open("GET", "/" + filter, true);
            request.send();
        });
    }
}, true);

addEventListener("DOMContentLoaded", function() {
    var commandButtons = document.querySelectorAll(".command");
    for(var i=0, l=commandButtons.length; i<l; i++) {
        var button = commandButtons[i];
        button.addEventListener("click", function(e) {
            e.preventDefault();
            var clickedButton = e.target;
            var player = clickedButton.name;
            var command = clickedButton.value;
            var request = new XMLHttpRequest();
            request.open("GET", "/" + player + "/" + command, true);
            request.send();
        });
    }
}, true);

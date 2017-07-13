(function () {
    let executed = false;
    let widgets = document.getElementsByClassName("share-widget-details");
    let isSupportTemplate = 'content' in document.createElement('template');
    if (isSupportTemplate) {
        for (let i = 0, len = widgets.length; i < len; ++i) {
            widgets[i].addEventListener("click", function () {
                if (!executed) {
                    let template = document.getElementsByClassName("share-widget-template")[0];
                    for (let j = 0, len = widgets.length; j < len; ++j) {
                        widgets[j].appendChild(document.importNode(template.content, true));
                    }
                    executed = true;
                }
            });
        }
    }
})();
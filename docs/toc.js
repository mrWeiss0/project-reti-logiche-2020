/**
 * Builds a table of contents for the document
 * scanning all h* tags inside the #content element
 * and appends it to the #toc element.
 * Each item is linked to its title in the document
 * with an anchor with an incremental name.
 *
 * The enerated table of contents has this structure:
 * <div id="toc>
 *   <ul>
 *     <li><a href="#0">Title 1</a></li>
 *       <ul>
 *         <li><a href="#1">Section 1.1</a></li>
 *       </ul>
 *     <li><a href="#2">Title 2</a></li>
 *   </ul>
 * </div>
 * 
 * <div id="content">
 *   <h1><a name="0">Title 1</a></h1>
 *   <h2><a name="1">Section 1.1</a></h2>
 *   <h1><a name="2">Title 2</a></h1>
 * </div>
 */
function toc(){
    var header = document.getElementById("content")
        .querySelectorAll("h1,h2,h3,h4,h5,h6");
    var curLevel = 0;
    var curElem = document.getElementById("toc");
    for(var i = 0; i < header.length; i++){
        var h = header[i];
        var level = +h.tagName[1];
        var d = level - curLevel;
        curLevel = level;
        if(d < 0)
            for(var j = 0; j < -d; j++)
                curElem = curElem.parentNode;
        else
            for(var j = 0; j < d; j++)
                curElem = curElem.appendChild(document.createElement("ul"));
        var item = curElem.appendChild(document.createElement("li"));
        var link = item.appendChild(document.createElement("a"));
        link.textContent = h.textContent;
        link.href = "#" + i;
        var anchor = document.createElement("a");
        anchor.name = i;
        while(h.childNodes.length)
            anchor.appendChild(h.firstChild);
        h.appendChild(anchor);
    }
}

addEventListener("load", toc);
